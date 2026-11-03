"""
Annotated-video HUD rendering, NVENC/CPU video writer, and video path
resolution. Moved from integrated_pipeline.py verbatim, except:

  - create_video_writer's SAVE_ANNOTATED_VIDEO check is now an explicit
    ``save_annotated_video`` parameter instead of a module-level global,
    since that value now comes from PipelineConfig.
  - release_video_writer had a duplicate, unreachable
    ``except Exception: pass`` clause (two except blocks catching the same
    exception type on one try) -- removed as dead code, no behavior change.
"""

from __future__ import annotations

import os
import shutil
import subprocess
from typing import Any, Optional

import cv2
import numpy as np

from pipeline.logging_setup import get_logger

logger = get_logger("video_io")


def draw_hud(
    frame: np.ndarray,
    video_record: Any,
    folder_type: str,
    real_timestamp: str,
    width: int,
    active_tracks: Optional[dict[int, list[int]]] = None,
    track_recognition_cache: Optional[dict[int, dict[str, Any]]] = None,
) -> np.ndarray:
    """
    Renders visual bounding boxes, identity tags, and a top-right real-world
    HUD banner. Can be called from both active inference frames and
    motion-gated/skipped frames.
    """
    if frame is None:
        return frame

    h, w = frame.shape[:2]

    if active_tracks and track_recognition_cache:
        for track_id, bbox in active_tracks.items():
            if len(bbox) != 4:
                continue
            x1, y1, x2, y2 = map(int, bbox)
            x1, y1 = max(0, min(w - 1, x1)), max(0, min(h - 1, y1))
            x2, y2 = max(0, min(w, x2)), max(0, min(h, y2))

            cache = track_recognition_cache.get(track_id, {})
            status = cache.get("status")
            emp_name = cache.get("emp_name", f"Person #{track_id}")
            conf = float(cache.get("conf", 0.0))
            conf_pct = int(conf * 100)

            if status == "recognized":
                box_color = (0, 220, 0)
                label = f"[#{track_id}] {emp_name} ({conf_pct}%)"
            elif status == "ambiguous":
                box_color = (0, 255, 255)
                label = f"[#{track_id}] REVIEW: {emp_name} ({conf_pct}%)"
            elif status == "unrecognized":
                box_color = (0, 0, 255)
                label = f"[#{track_id}] UNRECOGNIZED"
            else:
                box_color = (0, 165, 255)
                label = f"[#{track_id}] DETECTING..."

            cv2.rectangle(frame, (x1, y1), (x2, y2), box_color, 3)
            corner_len = min(25, (x2 - x1) // 4, (y2 - y1) // 4)
            cv2.line(frame, (x1, y1), (x1 + corner_len, y1), box_color, 5)
            cv2.line(frame, (x1, y1), (x1, y1 + corner_len), box_color, 5)
            cv2.line(frame, (x2, y1), (x2 - corner_len, y1), box_color, 5)
            cv2.line(frame, (x2, y1), (x2, y1 + corner_len), box_color, 5)
            cv2.line(frame, (x1, y2), (x1 + corner_len, y2), box_color, 5)
            cv2.line(frame, (x1, y2), (x1, y2 - corner_len), box_color, 5)
            cv2.line(frame, (x2, y2), (x2 - corner_len, y2), box_color, 5)
            cv2.line(frame, (x2, y2), (x2, y2 - corner_len), box_color, 5)

            (w_text, h_text), _ = cv2.getTextSize(label, cv2.FONT_HERSHEY_SIMPLEX, 0.70, 2)
            text_y = max(y1 - 12, 28)
            cv2.rectangle(frame, (x1, text_y - h_text - 6), (x1 + w_text + 10, text_y + 6), (0, 0, 0), -1)
            cv2.rectangle(frame, (x1, text_y - h_text - 6), (x1 + w_text + 10, text_y + 6), box_color, 1)
            cv2.putText(frame, label, (x1 + 5, text_y), cv2.FONT_HERSHEY_SIMPLEX, 0.70, box_color, 2)

    camera_name = getattr(video_record, "camera_name", None) or f"{folder_type.capitalize()} Camera"
    hud_w, hud_h = 360, 95
    hud_x1 = width - hud_w - 15
    hud_y1 = 15
    cv2.rectangle(frame, (hud_x1, hud_y1), (hud_x1 + hud_w, hud_y1 + hud_h), (20, 20, 20), -1)
    cv2.rectangle(frame, (hud_x1, hud_y1), (hud_x1 + hud_w, hud_y1 + hud_h), (200, 200, 200), 1)

    cv2.putText(frame, f"ROLE: {folder_type.upper()}", (hud_x1 + 10, hud_y1 + 25), cv2.FONT_HERSHEY_SIMPLEX, 0.55, (0, 255, 255), 1)
    cv2.putText(frame, f"TIME: {real_timestamp}", (hud_x1 + 10, hud_y1 + 50), cv2.FONT_HERSHEY_SIMPLEX, 0.55, (255, 255, 255), 1)
    cv2.putText(frame, f"CAM:  {camera_name}", (hud_x1 + 10, hud_y1 + 75), cv2.FONT_HERSHEY_SIMPLEX, 0.50, (180, 180, 180), 1)

    return frame


def get_ffmpeg_executable() -> str:
    """Finds available FFmpeg binary (local directory, explicit path, system PATH, or imageio_ffmpeg)."""
    local_paths = [
        os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "ffmpeg.exe"),
        r"D:\ffmpeg\bin\ffmpeg.exe",
        r"C:\ffmpeg\bin\ffmpeg.exe",
    ]
    for path in local_paths:
        if os.path.exists(path):
            return path

    ffmpeg_cmd = shutil.which("ffmpeg")
    if ffmpeg_cmd:
        return ffmpeg_cmd

    try:
        import imageio_ffmpeg
        return imageio_ffmpeg.get_ffmpeg_exe()
    except Exception:
        return "ffmpeg"


def create_nvenc_writer(output_path: str, width: int, height: int, fps: float) -> subprocess.Popen:
    """Creates an FFmpeg subprocess streaming raw BGR24 frames directly to NVIDIA NVENC H.264 GPU encoder."""
    ffmpeg_exe = get_ffmpeg_executable()
    cmd = [
        ffmpeg_exe, "-y",
        "-f", "rawvideo",
        "-vcodec", "rawvideo",
        "-s", f"{width}x{height}",
        "-pix_fmt", "bgr24",
        "-r", str(fps),
        "-i", "-",
        "-c:v", "h264_nvenc",
        "-preset", "p1",
        "-tune", "ll",
        "-b:v", "5M",
        "-maxrate", "10M",
        "-bufsize", "10M",
        "-pix_fmt", "yuv420p",
        output_path,
    ]
    return subprocess.Popen(cmd, stdin=subprocess.PIPE, stderr=subprocess.DEVNULL)


def create_video_writer(
    output_path: str,
    width: int,
    height: int,
    fps: float,
    save_annotated_video: bool,
    force_gpu: bool = True,
) -> tuple[Any, str]:
    """Creates an NVENC hardware GPU video writer, or skips entirely in Option B Fast Event-Driven Mode."""
    if not save_annotated_video:
        return None, "NONE (Option B: Fast Event-Driven Mode)"

    if force_gpu:
        try:
            proc = create_nvenc_writer(output_path, width, height, fps)
            test_frame = np.zeros((height, width, 3), dtype=np.uint8)
            if proc.stdin and proc.poll() is None:
                proc.stdin.write(test_frame.tobytes())
                proc.stdin.flush()
                return proc, "NVENC"
        except Exception as e:
            logger.warning("NVENC initialization failed (%s), falling back to CPU writer.", e)

    fourcc = cv2.VideoWriter_fourcc(*"mp4v")  # type: ignore[attr-defined]  # present at runtime; missing from cv2's bundled stubs
    writer = cv2.VideoWriter(output_path, fourcc, fps, (width, height))
    return writer, "CPU"


def write_video_frame(writer: Any, enc_mode: str, frame: np.ndarray) -> None:
    """Writes a single frame to the NVENC stdin pipe or an OpenCV VideoWriter."""
    if enc_mode == "NVENC":
        try:
            if writer and writer.stdin and writer.poll() is None:
                writer.stdin.write(frame.tobytes())
            elif not getattr(writer, "_err_logged", False):
                logger.warning("NVENC session closed or unavailable, continuing silently.")
                setattr(writer, "_err_logged", True)
        except Exception as e:
            if not getattr(writer, "_err_logged", False):
                logger.warning("NVENC pipe error: %s", e)
                setattr(writer, "_err_logged", True)
    elif writer:
        writer.write(frame)


def release_video_writer(writer: Any, enc_mode: str) -> None:
    """Releases the NVENC pipe or OpenCV VideoWriter."""
    if writer is None:
        return
    if enc_mode == "NVENC":
        try:
            if writer.stdin:
                try:
                    writer.stdin.close()
                except Exception:
                    pass
            writer.wait(timeout=2)
        except Exception:
            pass
    else:
        try:
            writer.release()
        except Exception:
            pass


def resolve_video_input_path(video_record: Any, backend_dir: str) -> str:
    """Resolves the physical file path of a video record across standard folders."""
    file_path = getattr(video_record, "file_path", None)
    filename = getattr(video_record, "filename", "")
    folder_type = getattr(video_record, "folder_type", "") or ""

    if file_path and os.path.exists(file_path):
        return os.path.abspath(file_path)

    base_dirs = [
        os.path.join(backend_dir, "data", "raw"),
        os.path.join(backend_dir, "..", "data", "raw"),
        os.path.join(backend_dir, "raw"),
        os.path.join(backend_dir, "..", "raw"),
        backend_dir,
    ]

    for bdir in base_dirs:
        candidate1 = os.path.join(bdir, folder_type, filename)
        if os.path.exists(candidate1):
            return os.path.abspath(candidate1)
        candidate2 = os.path.join(bdir, filename)
        if os.path.exists(candidate2):
            return os.path.abspath(candidate2)

    return file_path or filename


def resolve_video_output_path(video_record: Any, backend_dir: str, output_base_dir: Optional[str] = None) -> str:
    """Constructs the output annotated video path: data/processed/<role>/<original_name>_annotated.mp4"""
    filename = getattr(video_record, "filename", "output.mp4")
    folder_type = getattr(video_record, "folder_type", "general") or "general"
    stem, _ = os.path.splitext(filename)
    annotated_filename = f"{stem}_annotated.mp4"

    if output_base_dir:
        target_dir = os.path.join(output_base_dir, folder_type)
    else:
        target_dir = os.path.join(backend_dir, "data", "processed", folder_type)
        if not os.path.exists(os.path.join(backend_dir, "data")):
            target_dir = os.path.join(backend_dir, "processed", folder_type)

    os.makedirs(target_dir, exist_ok=True)
    return os.path.abspath(os.path.join(target_dir, annotated_filename))
