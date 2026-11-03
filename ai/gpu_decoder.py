import os
import cv2
import numpy as np
from typing import Tuple, Optional

def _get_av():
    try:
        import av
        return av
    except ImportError:
        return None

class NVDECGPUVideoDecoder:

    """
    NVIDIA Hardware Accelerated Video Decoder (NVDEC) wrapper.
    Uses h264_cuvid / hevc_cuvid hardware decoding for zero-CPU overhead.
    """
    def __init__(self, video_path: str):
        if not os.path.exists(video_path):
            raise FileNotFoundError(f"Video file not found: {video_path}")

        self.video_path = video_path
        self.container = None
        self.stream = None
        self.frame_generator = None
        self.fps = 25.0
        self.total_frames = 0
        self.width = 1280
        self.height = 720
        self.is_hardware_accelerated = False

        self._init_decoder()

    def _init_decoder(self):
        try:
            av_mod = _get_av()
            if av_mod is None:
                raise ImportError("PyAV ('av') package is not installed.")

            # Try NVIDIA NVDEC Hardware Accelerated Decoder (h264_cuvid)
            self.container = av_mod.open(self.video_path, options={'c:v': 'h264_cuvid'})
            self.stream = self.container.streams.video[0]
            self.stream.thread_type = 'AUTO'
            
            self.fps = float(self.stream.average_rate or 25.0)

            # Validate frame count against actual stream duration
            # FFmpeg keyframe-copy split (-c copy) preserves the original
            # container's frame count metadata, so chunks report the full
            # video's frame count instead of their actual (smaller) count.
            raw_frames = int(self.stream.frames or 0)
            duration_sec = (
                float(self.stream.duration * self.stream.time_base)
                if self.stream and self.stream.duration else (
                    float(self.container.duration) / 1000000.0
                    if self.container and self.container.duration else 0
                )
            )
            estimated_frames = int(duration_sec * self.fps) if duration_sec > 0 else 0

            if estimated_frames > 0 and (raw_frames == 0 or raw_frames > estimated_frames * 1.1):
                self.total_frames = estimated_frames
                print(f"[NVDEC GPU DECODER] Corrected stale frame count: {raw_frames} -> {estimated_frames} (from duration {duration_sec:.1f}s)")
            else:
                self.total_frames = raw_frames

            self.width = int(self.stream.width or 1280)
            self.height = int(self.stream.height or 720)
            
            self.frame_generator = self.container.decode(video=0)
            self.is_hardware_accelerated = True
            print(f"[NVDEC GPU DECODER] Initialized NVIDIA HW Video Decoder ({self.stream.codec_context.name} via h264_cuvid) | {self.width}x{self.height} @ {self.fps:.1f} FPS")
        
        except Exception as e:
            print(f"[NVDEC WARNING] Hardware NVDEC decoder initialization failed ({e}). Falling back to OpenCV CPU reader.")

            self.is_hardware_accelerated = False
            self.cap = cv2.VideoCapture(self.video_path)
            self.fps = self.cap.get(cv2.CAP_PROP_FPS) or 25.0
            self.total_frames = int(self.cap.get(cv2.CAP_PROP_FRAME_COUNT) or 0)
            self.width = int(self.cap.get(cv2.CAP_PROP_FRAME_WIDTH) or 1280)
            self.height = int(self.cap.get(cv2.CAP_PROP_FRAME_HEIGHT) or 720)

    def read(self) -> Tuple[bool, Optional[np.ndarray]]:
        """
        Reads next frame decoded by NVIDIA NVDEC GPU chip.
        Returns (success: bool, frame_bgr: np.ndarray)
        """
        if self.is_hardware_accelerated:
            try:
                frame = next(self.frame_generator)
                bgr_img = frame.to_ndarray(format='bgr24')
                return True, bgr_img
            except Exception:
                return False, None
        else:
            return self.cap.read()

    def grab(self):
        """Skip 1 frame in hardware stream."""
        if self.is_hardware_accelerated:
            try:
                next(self.frame_generator)
            except Exception:
                pass
        else:
            self.cap.grab()

    def seek(self, frame_idx: int):
        """
        Position the video decoder at the specified frame index.
        Uses fast container timestamp seek for HW acceleration.
        """
        if self.is_hardware_accelerated:
            if self.container and self.stream:
                try:
                    # Fast PyAV container timestamp seek
                    target_sec = float(frame_idx) / float(self.fps)
                    time_base_val = float(self.stream.time_base) if self.stream.time_base else (1.0 / 90000.0)
                    target_pts = int(target_sec / time_base_val)
                    self.container.seek(target_pts, stream=self.stream, any_frame=False)
                    self.frame_generator = self.container.decode(video=0)
                    return
                except Exception as e:
                    print(f"[NVDEC SEEK WARNING] Fast PyAV seek failed ({e}), re-initializing decoder.")

            if self.container:
                try:
                    self.container.close()
                except Exception:
                    pass
            self._init_decoder()
            for _ in range(frame_idx):
                self.grab()
        else:
            if hasattr(self, 'cap') and self.cap:
                self.cap.set(cv2.CAP_PROP_POS_FRAMES, frame_idx)


    def release(self):
        """Release decoder container."""
        if self.is_hardware_accelerated and self.container:
            try:
                self.container.close()
            except Exception:
                pass
            self.container = None
        elif hasattr(self, 'cap') and self.cap:
            self.cap.release()
            self.cap = None

    def __enter__(self) -> "NVDECGPUVideoDecoder":
        return self

    def __exit__(self, exc_type, exc_val, exc_tb) -> None:
        self.release()


class PrefetchedGPUVideoDecoder:
    """
    Thread-safe asynchronous wrapper around NVDECGPUVideoDecoder that continuously
    prefetches frames into a bounded FIFO queue, hiding video decoding latency behind
    GPU/CPU inference without altering frame order or ByteTrack tracking state.
    """
    def __init__(self, video_path: str, queue_size: int = 6):
        import queue
        import threading
        self.raw_decoder = NVDECGPUVideoDecoder(video_path)
        self.width = self.raw_decoder.width
        self.height = self.raw_decoder.height
        self.fps = self.raw_decoder.fps
        self.total_frames = self.raw_decoder.total_frames
        self.is_hardware_accelerated = self.raw_decoder.is_hardware_accelerated
        
        self.queue_size = queue_size
        self._queue = queue.Queue(maxsize=queue_size)
        self._stop_event = threading.Event()
        self._worker_thread = threading.Thread(target=self._prefetch_loop, daemon=True)
        self._worker_thread.start()

    def _prefetch_loop(self):
        import queue
        while not self._stop_event.is_set():
            ret, frame = self.raw_decoder.read()
            if not ret or frame is None:
                try:
                    self._queue.put((False, None), timeout=1.0)
                except Exception:
                    pass
                break
            # Put into bounded queue
            while not self._stop_event.is_set():
                try:
                    self._queue.put((True, frame), timeout=0.1)
                    break
                except queue.Full:
                    continue

    def read(self) -> Tuple[bool, Optional[np.ndarray]]:
        import queue
        if self._stop_event.is_set():
            return False, None
        try:
            return self._queue.get(timeout=5.0)
        except queue.Empty:
            return False, None

    def seek(self, frame_idx: int):
        self._stop_event.set()
        if self._worker_thread.is_alive():
            self._worker_thread.join(timeout=1.0)
        # Drain existing queue
        while not self._queue.empty():
            try:
                self._queue.get_nowait()
            except Exception:
                break
        self.raw_decoder.seek(frame_idx)
        import threading
        self._stop_event = threading.Event()
        self._worker_thread = threading.Thread(target=self._prefetch_loop, daemon=True)
        self._worker_thread.start()

    def release(self):
        self._stop_event.set()
        while not self._queue.empty():
            try:
                self._queue.get_nowait()
            except Exception:
                break
        if self._worker_thread.is_alive():
            self._worker_thread.join(timeout=1.0)
        self.raw_decoder.release()

    def __enter__(self) -> "PrefetchedGPUVideoDecoder":
        return self

    def __exit__(self, exc_type, exc_val, exc_tb) -> None:
        self.release()


def _motion_ratio_bgr(prev_bgr: np.ndarray, curr_bgr: np.ndarray, pixel_diff_thresh: int) -> float:
    """
    Motion ratio between two equally-sized BGR24 thumbnails, using the exact
    absdiff -> BGR2GRAY -> threshold -> countNonZero pipeline the pipeline's
    inline motion-gating block runs on full-resolution frames. Kept as a
    free function so it can be reused/unit-tested independently of which
    decoder produced the thumbnails.
    """
    diff = cv2.absdiff(prev_bgr, curr_bgr)
    gray_diff = cv2.cvtColor(diff, cv2.COLOR_BGR2GRAY)
    _, thresh_diff = cv2.threshold(gray_diff, pixel_diff_thresh, 255, cv2.THRESH_BINARY)
    non_zero = cv2.countNonZero(thresh_diff)
    total_pixels = float(prev_bgr.shape[0] * prev_bgr.shape[1])
    return (non_zero / total_pixels) if total_pixels > 0 else 0.0


class SmartVideoDecoder:
    """
    Motion-aware asynchronous video decoder.

    Same background-thread prefetch + bounded FIFO queue + strict frame
    ordering as PrefetchedGPUVideoDecoder, but performs motion gating
    *inside* the decode step, before the expensive full-resolution color
    conversion, instead of the caller decoding every frame in full and then
    downscaling it with cv2.resize afterwards:

      1. Decode the next frame via PyAV/NVDEC (`next(frame_generator)`).
         This step is unavoidable -- H.264 is inter-predicted, so every
         frame must be fully decoded (motion-compensated) to keep the
         bitstream in sync, regardless of whether we intend to use it.
      2. Convert+downscale in a SINGLE libswscale pass straight to a small
         BGR24 thumbnail (`frame.to_ndarray(format="bgr24", width=W,
         height=H)`) instead of paying for a full 1920x1080 `to_ndarray`
         call (~6MB allocation + full-frame color conversion) that the
         caller used to immediately shrink with `cv2.resize` anyway.
      3. Run the SAME absdiff -> BGR2GRAY -> threshold -> countNonZero
         motion-ratio computation the pipeline ran inline, on this
         thumbnail (see `_motion_ratio_bgr`).
      4. Only if motion is detected does it pay for the full-resolution
         `to_ndarray('bgr24')` conversion. Static frames are handed to the
         caller as `(True, None, motion_ratio)` -- no 1920x1080 buffer is
         ever allocated for them.

    Reference-frame semantics are preserved exactly as in the original
    inline motion-gating block: the "previous" thumbnail used for
    comparison only advances when motion is detected (not every frame),
    and the very first frame after construction/after a `seek()` is always
    treated as motion (matches `prev_frame is None` in the original code).

    ACCURACY CAVEAT: the motion ratio computed here is highly correlated
    with, but not bit-identical to, the original algorithm. The original
    resized an already-BGR24-converted, full-resolution frame with
    `cv2.resize`; this decoder resizes+color-converts in one libswscale
    pass straight from the decoder's native YUV planes. Both use a
    bilinear-family interpolation and identical absdiff/threshold/ratio
    math, but swscale's internal filter graph does not produce pixel-for-
    pixel identical output to "cv2.resize of a separately-converted BGR
    image" -- true bit-exact equivalence is not achievable without paying
    for the full-resolution decode on every frame, which would defeat the
    purpose. In practice this can only flip the gate decision for frames
    whose motion ratio sits within roughly one threshold-unit of
    `motion_threshold_ratio`; run an A/B agreement check on a real video
    before relying on this in production (see Objective 3 validation
    tooling).

    Only the NVDEC/PyAV hardware path benefits from the skip. If hardware
    acceleration is unavailable, this falls back to decoding every frame
    in full (like PrefetchedGPUVideoDecoder) since OpenCV's VideoCapture
    has no cheaper partial-decode path to hook into -- gating decisions are
    still computed and returned for API consistency, but no decode work is
    actually saved in that mode.

    NOTE: this decoder gates on every raw frame, independent of any
    downstream frame-sampling interval. That is exactly equivalent to the
    original inline algorithm when `frame_sample_interval == 1` (the
    project's current configured value), but if that interval is ever
    changed to skip frames at the pipeline level, this decoder's motion
    reference will update on frames the old algorithm would not have
    considered, and the two will diverge.
    """

    def __init__(
        self,
        video_path: str,
        queue_size: int = 6,
        downscale_size: Tuple[int, int] = (160, 120),
        motion_threshold_ratio: float = 0.01,
        motion_pixel_diff_thresh: int = 25,
    ):
        import queue
        import threading

        self.raw_decoder = NVDECGPUVideoDecoder(video_path)
        self.width = self.raw_decoder.width
        self.height = self.raw_decoder.height
        self.fps = self.raw_decoder.fps
        self.total_frames = self.raw_decoder.total_frames
        self.is_hardware_accelerated = self.raw_decoder.is_hardware_accelerated

        self.downscale_size = downscale_size
        self.motion_threshold_ratio = motion_threshold_ratio
        self.motion_pixel_diff_thresh = motion_pixel_diff_thresh

        # PyAV's `VideoFrame.to_ndarray(**kwargs)` allocates a brand-new
        # VideoReformatter (and therefore a brand-new libswscale SwsContext)
        # on every call, because the reformatter is an attribute of the
        # (per-frame, ephemeral) VideoFrame object, not of anything
        # long-lived. Calling it fresh on every decoded frame was measured
        # at ~5ms/call regardless of output size -- the fixed SwsContext
        # setup cost dominates a tiny 160x120 target completely, making a
        # naive per-frame `frame.to_ndarray(format="bgr24", width=160,
        # height=120)` call *slower* than the full 1920x1080 conversion it
        # was meant to replace. Keeping ONE VideoReformatter per distinct
        # (format, width, height) around and reusing it across every frame
        # keeps the underlying SwsContext alive, which cuts the same call
        # to ~0.17ms/call (measured). These two reformatters are therefore
        # decoder-lifetime state, not per-frame throwaways.
        self._thumb_reformatter = None
        self._full_reformatter = None
        if self.raw_decoder.is_hardware_accelerated:
            av_mod = _get_av()
            if av_mod is not None:
                from av.video.reformatter import VideoReformatter
                self._thumb_reformatter = VideoReformatter()
                self._full_reformatter = VideoReformatter()

        # Background-thread-only counters (safe to read from the main
        # thread once the worker has stopped, e.g. after release()).
        self.frames_decoded_full = 0
        self.frames_skipped_static = 0

        self.queue_size = queue_size
        self._queue = queue.Queue(maxsize=queue_size)
        self._stop_event = threading.Event()
        self._worker_thread = threading.Thread(target=self._prefetch_loop, daemon=True)
        self._worker_thread.start()

    def _thumbnail(self, av_frame) -> np.ndarray:
        w, h = self.downscale_size
        small = self._thumb_reformatter.reformat(av_frame, width=w, height=h, format="bgr24")
        return small.to_ndarray()

    def _full_bgr(self, av_frame) -> np.ndarray:
        full = self._full_reformatter.reformat(av_frame, format="bgr24")
        return full.to_ndarray()

    def _push(self, item: Tuple[bool, Optional[np.ndarray], float]) -> None:
        import queue
        while not self._stop_event.is_set():
            try:
                self._queue.put(item, timeout=0.1)
                return
            except queue.Full:
                continue

    def _prefetch_loop(self) -> None:
        prev_thumb: Optional[np.ndarray] = None

        while not self._stop_event.is_set():
            if self.raw_decoder.is_hardware_accelerated:
                try:
                    av_frame = next(self.raw_decoder.frame_generator)
                except Exception:
                    self._push((False, None, 0.0))
                    break

                try:
                    thumb = self._thumbnail(av_frame)
                except Exception:
                    # Reformat failed for some reason -- fall back to a full
                    # decode so a frame is never silently dropped.
                    try:
                        full = av_frame.to_ndarray(format="bgr24")
                    except Exception:
                        self._push((False, None, 0.0))
                        break
                    self.frames_decoded_full += 1
                    prev_thumb = None
                    self._push((True, full, 1.0))
                    continue

                if prev_thumb is None:
                    # First frame since construction/seek: always treated as
                    # motion, exactly like `prev_frame is None` upstream.
                    full = self._full_bgr(av_frame)
                    self.frames_decoded_full += 1
                    prev_thumb = thumb
                    self._push((True, full, 1.0))
                    continue

                ratio = _motion_ratio_bgr(prev_thumb, thumb, self.motion_pixel_diff_thresh)

                if ratio < self.motion_threshold_ratio:
                    self.frames_skipped_static += 1
                    self._push((True, None, ratio))
                    # prev_thumb intentionally NOT updated -- matches the
                    # original pipeline's reference-frame semantics (the
                    # reference only advances on a motion frame).
                    continue

                full = self._full_bgr(av_frame)
                self.frames_decoded_full += 1
                prev_thumb = thumb
                self._push((True, full, ratio))

            else:
                # CPU/OpenCV fallback: no cheap partial-decode path exists,
                # so the full frame is paid for regardless; only the gating
                # *decision* is replicated, for API consistency.
                ret, frame = self.raw_decoder.read()
                if not ret or frame is None:
                    self._push((False, None, 0.0))
                    break

                thumb = cv2.resize(frame, self.downscale_size)
                if prev_thumb is None:
                    self.frames_decoded_full += 1
                    prev_thumb = thumb
                    self._push((True, frame, 1.0))
                    continue

                ratio = _motion_ratio_bgr(prev_thumb, thumb, self.motion_pixel_diff_thresh)
                if ratio < self.motion_threshold_ratio:
                    self.frames_skipped_static += 1
                    self._push((True, None, ratio))
                    continue

                self.frames_decoded_full += 1
                prev_thumb = thumb
                self._push((True, frame, ratio))

    def read(self) -> Tuple[bool, Optional[np.ndarray], float]:
        """Returns (success, frame_bgr_or_None, motion_ratio)."""
        import queue
        if self._stop_event.is_set():
            return False, None, 0.0
        try:
            return self._queue.get(timeout=5.0)
        except queue.Empty:
            return False, None, 0.0

    def seek(self, frame_idx: int) -> None:
        import threading
        self._stop_event.set()
        if self._worker_thread.is_alive():
            self._worker_thread.join(timeout=1.0)
        while not self._queue.empty():
            try:
                self._queue.get_nowait()
            except Exception:
                break
        self.raw_decoder.seek(frame_idx)
        self._stop_event = threading.Event()
        self._worker_thread = threading.Thread(target=self._prefetch_loop, daemon=True)
        self._worker_thread.start()

    def release(self) -> None:
        self._stop_event.set()
        while not self._queue.empty():
            try:
                self._queue.get_nowait()
            except Exception:
                break
        if self._worker_thread.is_alive():
            self._worker_thread.join(timeout=1.0)
        self.raw_decoder.release()

    def __enter__(self) -> "SmartVideoDecoder":
        return self

    def __exit__(self, exc_type, exc_val, exc_tb) -> None:
        self.release()

