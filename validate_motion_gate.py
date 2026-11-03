"""
Motion Gate A/B Validation Harness
====================================
Quantifies how often SmartVideoDecoder's motion-gating decision (thumbnail
produced by a single-pass libswscale resize+convert straight from the
decoder's native YUV planes) disagrees with the original inline algorithm
(full 1920x1080 BGR24 decode -> cv2.resize down to 160x120) that
integrated_pipeline.py has always used, before relying on the new decoder
in production.

Both thumbnails are computed from the SAME decoded AVFrame each iteration
-- this isolates exactly one variable (the resize/convert code path) and
rules out any decode-order or timing nondeterminism between two separate
video opens.

Each algorithm maintains its OWN reference-frame state using the pipeline's
actual reference-update rule (the "previous" thumbnail only advances when
that algorithm's own ratio crosses ITS threshold; the very first frame is
always forced to MOTION) -- exactly mirroring integrated_pipeline.py's
inline block and SmartVideoDecoder respectively.

Outputs:
  - motion_gate_validation_results.json  (summary + every disagreement)
  - motion_gate_validation_frames.csv    (per-frame decision log)
  - <out-dir>/example_*.png              (side-by-side thumbnail comparisons
                                           for a sample of disagreements)

Usage:
    python validate_motion_gate.py [video_path] [--frames N] [--out-dir DIR] [--examples K]
"""

import os
import sys
import csv
import json
import argparse
import time
from typing import Optional

import cv2
import numpy as np

sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from ai.gpu_decoder import _get_av, _motion_ratio_bgr

# NOTE: these mirror integrated_pipeline.py's own config parsing (lines
# ~74-83). Duplicated here rather than importing integrated_pipeline
# because that module pulls in ultralytics/torch at import time, which this
# lightweight decode-only tool has no need for. Objective 2's shared
# PipelineConfig should collapse this duplication.
try:
    from config.settings import cfg as _cfg
except ImportError:
    _cfg = {}

_motion_cfg = _cfg.get("motion_gating", {})
MOTION_THRESHOLD_RATIO = float(_motion_cfg.get("threshold_ratio", 0.01))
MOTION_PIXEL_DIFF_THRESH = int(_motion_cfg.get("pixel_diff_threshold", 25))
_ds = _motion_cfg.get("downscale_size", [160, 120])
MOTION_DOWNSCALE_SIZE = (int(_ds[0]), int(_ds[1])) if isinstance(_ds, (list, tuple)) else (160, 120)

DEFAULT_VIDEO = os.path.join(
    os.path.dirname(__file__), "data", "raw", "attendance",
    "200.0.0.25_ch5_20260825185502_20260825190459.mp4",
)


def fmt_timestamp(frame_idx: int, fps: float) -> str:
    total_sec = (frame_idx - 1) / fps
    h = int(total_sec // 3600)
    m = int((total_sec % 3600) // 60)
    s = total_sec % 60
    return f"{h:02d}:{m:02d}:{s:06.3f}"


def make_comparison_image(
    old_thumb: np.ndarray,
    new_thumb: np.ndarray,
    frame_idx: int,
    timestamp: str,
    old_ratio: float,
    new_ratio: float,
    old_decision: str,
    new_decision: str,
    threshold: float,
    scale: int = 4,
) -> np.ndarray:
    """Side-by-side OLD | NEW | |OLD-NEW| panel, upscaled for legibility."""
    h, w = old_thumb.shape[:2]
    up = lambda img: cv2.resize(img, (w * scale, h * scale), interpolation=cv2.INTER_NEAREST)

    diff = cv2.absdiff(old_thumb, new_thumb)
    diff_amp = np.clip(diff.astype(np.int32) * 4, 0, 255).astype(np.uint8)

    panels = []
    labels = [
        f"OLD (full decode + cv2.resize)  ratio={old_ratio:.4f}  -> {old_decision}",
        f"NEW (SmartVideoDecoder thumb)  ratio={new_ratio:.4f}  -> {new_decision}",
        "abs diff (x4 amplified)",
    ]
    for img, label in zip([up(old_thumb), up(new_thumb), up(diff_amp)], labels):
        panel = img.copy()
        cv2.rectangle(panel, (0, 0), (panel.shape[1] - 1, 24), (20, 20, 20), -1)
        cv2.putText(panel, label, (6, 17), cv2.FONT_HERSHEY_SIMPLEX, 0.42, (255, 255, 255), 1, cv2.LINE_AA)
        panels.append(panel)

    gap = np.full((panels[0].shape[0], 6, 3), 40, dtype=np.uint8)
    row = np.hstack([panels[0], gap, panels[1], gap, panels[2]])

    header = np.full((28, row.shape[1], 3), 15, dtype=np.uint8)
    header_text = f"Frame {frame_idx}  |  t={timestamp}  |  threshold={threshold}"
    cv2.putText(header, header_text, (8, 19), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 200, 255), 1, cv2.LINE_AA)

    return np.vstack([header, row])


def run_validation(video_path: str, max_frames: int, out_dir: str, num_examples: int):
    av_mod = _get_av()
    if av_mod is None:
        print("[VALIDATE] PyAV ('av') is not installed -- cannot run.")
        return None

    from av.video.reformatter import VideoReformatter

    if not os.path.exists(video_path):
        print(f"[VALIDATE] Video not found: {video_path}")
        return None

    os.makedirs(out_dir, exist_ok=True)

    print("=" * 80)
    print("  Motion Gate A/B Validation -- OLD (full decode+cv2.resize) vs NEW (SmartVideoDecoder)")
    print("=" * 80)
    print(f"  Video:              {video_path}")
    print(f"  Downscale size:     {MOTION_DOWNSCALE_SIZE}")
    print(f"  Threshold ratio:    {MOTION_THRESHOLD_RATIO}")
    print(f"  Pixel diff thresh:  {MOTION_PIXEL_DIFF_THRESH}")
    print(f"  Max frames:         {max_frames}")

    container = av_mod.open(video_path, options={'c:v': 'h264_cuvid'})
    stream = container.streams.video[0]
    fps = float(stream.average_rate or 25.0)
    gen = container.decode(video=0)

    full_reformatter = VideoReformatter()
    thumb_reformatter = VideoReformatter()

    old_prev: Optional[np.ndarray] = None
    new_prev: Optional[np.ndarray] = None

    dw, dh = MOTION_DOWNSCALE_SIZE

    rows = []
    disagreements = []
    frame_idx = 0

    wall_start = time.perf_counter()

    for av_frame in gen:
        frame_idx += 1
        if frame_idx > max_frames:
            break

        full_bgr = full_reformatter.reformat(av_frame, format="bgr24").to_ndarray()
        old_thumb = cv2.resize(full_bgr, (dw, dh))
        new_thumb = thumb_reformatter.reformat(av_frame, width=dw, height=dh, format="bgr24").to_ndarray()

        if old_prev is None:
            old_ratio, old_motion = 1.0, True
        else:
            old_ratio = _motion_ratio_bgr(old_prev, old_thumb, MOTION_PIXEL_DIFF_THRESH)
            old_motion = old_ratio >= MOTION_THRESHOLD_RATIO

        if new_prev is None:
            new_ratio, new_motion = 1.0, True
        else:
            new_ratio = _motion_ratio_bgr(new_prev, new_thumb, MOTION_PIXEL_DIFF_THRESH)
            new_motion = new_ratio >= MOTION_THRESHOLD_RATIO

        if old_motion:
            old_prev = old_thumb
        if new_motion:
            new_prev = new_thumb

        agree = old_motion == new_motion
        row = {
            "frame_idx": frame_idx,
            "timestamp": fmt_timestamp(frame_idx, fps),
            "old_ratio": round(float(old_ratio), 5),
            "new_ratio": round(float(new_ratio), 5),
            "old_decision": "MOTION" if old_motion else "STATIC",
            "new_decision": "MOTION" if new_motion else "STATIC",
            "agree": agree,
        }
        rows.append(row)

        if not agree:
            disagreements.append({**row, "old_thumb": old_thumb, "new_thumb": new_thumb})

        if frame_idx % 1000 == 0:
            print(f"  [VALIDATE] {frame_idx}/{max_frames} frames  |  disagreements so far: {len(disagreements)}")

    container.close()
    wall_total = time.perf_counter() - wall_start

    total = len(rows)
    n_disagree = len(disagreements)
    agreement_rate = 100.0 * (total - n_disagree) / total if total else 0.0

    print(f"\n[VALIDATE] Done in {wall_total:.2f}s -- {total} frames compared")
    print(f"  Agreement rate:     {agreement_rate:.3f}%")
    print(f"  Disagreements:      {n_disagree} ({100.0 * n_disagree / total:.3f}%)")

    # ---- example thumbnail images: earliest, largest-delta, smallest-delta ----
    examples = []
    if disagreements:
        by_time = sorted(disagreements, key=lambda d: d["frame_idx"])
        by_delta_desc = sorted(disagreements, key=lambda d: -abs(d["new_ratio"] - d["old_ratio"]))
        by_delta_asc = sorted(disagreements, key=lambda d: abs(d["new_ratio"] - d["old_ratio"]))

        k = max(1, num_examples // 3)
        picked_idx = set()
        for pool, tag in [(by_time, "earliest"), (by_delta_desc, "largest_delta"), (by_delta_asc, "borderline")]:
            count = 0
            for d in pool:
                if d["frame_idx"] in picked_idx:
                    continue
                examples.append((tag, d))
                picked_idx.add(d["frame_idx"])
                count += 1
                if count >= k:
                    break

        for tag, d in examples:
            img = make_comparison_image(
                d["old_thumb"], d["new_thumb"], d["frame_idx"], d["timestamp"],
                d["old_ratio"], d["new_ratio"], d["old_decision"], d["new_decision"],
                MOTION_THRESHOLD_RATIO,
            )
            fname = f"example_{tag}_frame{d['frame_idx']:05d}.png"
            cv2.imwrite(os.path.join(out_dir, fname), img)
            d["example_file"] = fname
            d["example_tag"] = tag

    # ---- write outputs ----
    csv_path = os.path.join(os.path.dirname(__file__), "motion_gate_validation_frames.csv")
    with open(csv_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=["frame_idx", "timestamp", "old_ratio", "new_ratio", "old_decision", "new_decision", "agree"])
        writer.writeheader()
        writer.writerows(rows)

    disagreement_summary = [
        {k: v for k, v in d.items() if k not in ("old_thumb", "new_thumb")}
        for d in disagreements
    ]

    result = {
        "video": os.path.basename(video_path),
        "fps": fps,
        "downscale_size": MOTION_DOWNSCALE_SIZE,
        "threshold_ratio": MOTION_THRESHOLD_RATIO,
        "pixel_diff_thresh": MOTION_PIXEL_DIFF_THRESH,
        "total_frames_compared": total,
        "disagreement_count": n_disagree,
        "agreement_rate_pct": round(agreement_rate, 4),
        "wall_time_sec": round(wall_total, 2),
        "disagreements": disagreement_summary,
        "example_images_dir": out_dir,
    }

    json_path = os.path.join(os.path.dirname(__file__), "motion_gate_validation_results.json")
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(result, f, indent=2)

    print(f"\n[VALIDATE] Per-frame CSV:  {csv_path}")
    print(f"[VALIDATE] Summary JSON:   {json_path}")
    print(f"[VALIDATE] Example images: {out_dir}")
    print("=" * 80)

    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Motion gate A/B validation harness")
    parser.add_argument("video_path", nargs="?", default=DEFAULT_VIDEO)
    parser.add_argument("--frames", type=int, default=5000)
    parser.add_argument("--out-dir", type=str, default=os.path.join(os.path.dirname(__file__), "validation_output", "motion_gate_ab"))
    parser.add_argument("--examples", type=int, default=9)
    args = parser.parse_args()

    run_validation(args.video_path, args.frames, args.out_dir, args.examples)
