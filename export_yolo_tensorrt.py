"""
EPIC YOLOv8 TensorRT FP16 Export & Benchmark Utility
====================================================
Converts YOLOv8 PyTorch model (.pt) into high-performance TensorRT FP16 engine (.engine).
Reduces inference latency from ~14ms to ~4ms per frame on NVIDIA GPUs.
"""

import os
import sys
import time
import argparse
import numpy as np

# Ensure backend directory is in sys.path
sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))

from ultralytics import YOLO


def export_yolov8_to_tensorrt(
    model_path: str = "models/yolov8n.pt",
    device: int = 0,
    half: bool = True,
    imgsz: int = 640,
    workspace: int = 4
) -> str:
    """
    Exports YOLOv8 model to TensorRT engine format.
    
    Args:
        model_path: Path to input .pt weight file
        device: CUDA device index (e.g. 0)
        half: Enable FP16 half-precision
        imgsz: Inference input image size (default 640)
        workspace: TensorRT workspace size in GB
        
    Returns:
        Path to generated .engine file
    """
    if not os.path.isabs(model_path):
        model_path = os.path.abspath(os.path.join(os.path.dirname(__file__), model_path))

    if not os.path.exists(model_path):
        raise FileNotFoundError(f"Source PyTorch model not found at: {model_path}")

    print("======================================================================")
    print(" EPIC YOLOv8 -> TensorRT FP16 Exporter")
    print("======================================================================")
    print(f"  Source Model:   {model_path}")
    print(f"  Target Device:  CUDA:{device}")
    print(f"  FP16 Precision: {half}")
    print(f"  Input Size:     {imgsz}x{imgsz}")
    print(f"  Workspace:      {workspace} GB")
    print("======================================================================\n")

    print("[1/2] Loading PyTorch model...")
    model = YOLO(model_path)

    print("[2/2] Exporting to TensorRT engine (this may take 1-3 minutes on first build)...")
    start_time = time.time()
    
    exported_path = model.export(
        format="engine",
        device=device,
        half=half,
        imgsz=imgsz,
        workspace=workspace,
        verbose=True
    )
    
    elapsed = time.time() - start_time
    print(f"\n[SUCCESS] TensorRT Engine Export Complete in {elapsed:.1f}s!")
    print(f"  Engine Path: {exported_path}\n")

    return str(exported_path)


def benchmark_models(pt_path: str, engine_path: str, device: int = 0, num_warmup: int = 20, num_iters: int = 100):
    """
    Benchmarks latency between PyTorch (.pt) and TensorRT (.engine) models.
    """
    print("======================================================================")
    print(" EPIC Model Latency Benchmark")
    print("======================================================================")
    dummy_frame = np.random.randint(0, 255, (720, 1280, 3), dtype=np.uint8)

    # 1. Benchmark PyTorch Model
    if os.path.exists(pt_path):
        print(f"\n[Benchmarking PyTorch Model]: {pt_path}")
        pt_model = YOLO(pt_path)
        for _ in range(num_warmup):
            _ = pt_model.predict(source=dummy_frame, classes=[0], verbose=False, device=device)

        t0 = time.time()
        for _ in range(num_iters):
            _ = pt_model.predict(source=dummy_frame, classes=[0], verbose=False, device=device)
        pt_latency = ((time.time() - t0) / num_iters) * 1000.0
        pt_fps = 1000.0 / pt_latency
        print(f"  PyTorch Avg Latency: {pt_latency:.2f} ms | Throughput: {pt_fps:.1f} FPS")
    else:
        pt_latency = None

    # 2. Benchmark TensorRT Engine
    if os.path.exists(engine_path):
        print(f"\n[Benchmarking TensorRT FP16 Engine]: {engine_path}")
        try:
            trt_model = YOLO(engine_path, task="detect")
            for _ in range(num_warmup):
                _ = trt_model.predict(source=dummy_frame, classes=[0], verbose=False, device=device)

            t0 = time.time()
            for _ in range(num_iters):
                _ = trt_model.predict(source=dummy_frame, classes=[0], verbose=False, device=device)
            trt_latency = ((time.time() - t0) / num_iters) * 1000.0
            trt_fps = 1000.0 / trt_latency
            print(f"  TensorRT Avg Latency: {trt_latency:.2f} ms | Throughput: {trt_fps:.1f} FPS")

            if pt_latency:
                speedup = pt_latency / trt_latency
                print(f"\n  Speedup: {speedup:.2f}x faster with TensorRT FP16!")
        except Exception as e:
            print(f"  TensorRT Benchmark failed: {e}")
    print("======================================================================\n")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Export YOLOv8 model to TensorRT FP16")
    parser.add_argument("--model", type=str, default="models/yolov8n.pt", help="Path to input .pt model")
    parser.add_argument("--device", type=int, default=0, help="CUDA Device index (default: 0)")
    parser.add_argument("--half", action="store_true", default=True, help="Use FP16 half precision")
    parser.add_argument("--imgsz", type=int, default=640, help="Image size for inference (default: 640)")
    parser.add_argument("--benchmark", action="store_true", help="Run latency comparison benchmark")

    args = parser.parse_args()

    try:
        engine_file = export_yolov8_to_tensorrt(
            model_path=args.model,
            device=args.device,
            half=args.half,
            imgsz=args.imgsz
        )
        if args.benchmark:
            benchmark_models(args.model, engine_file, device=args.device)
    except Exception as err:
        print(f"[ERROR] Export failed: {err}")
        sys.exit(1)
