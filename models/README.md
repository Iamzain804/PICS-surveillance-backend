# PICS AI Model Registry & Artifacts

This directory houses the model weights, metadata manifests, and verification checksums for the PICS Surveillance Backend.

---

## Model Inventory

| Model | Architecture | Format | Size | SHA256 Checksum | Purpose |
|---|---|---|---|---|---|
| `yolov8n.pt` | YOLOv8 Nano | PyTorch (`.pt`) | 6.25 MB | `f59b3d833e2ff32e194b5bb8e08d211dc7c5bdf144b90d2c8412c47ccfc83b36` | Person Detection (Class 0) |
| `buffalo_l` | RetinaFace + ArcFace | ONNX | ~300 MB | Dynamic / InsightFace Hub | Face Detection & 512D Embedding |
| `bytetrack` | ByteTrack | Config | — | `config/bytetrack.yaml` | Multi-person Track Association |

---

## Verifying Model Integrity

To verify that the local `yolov8n.pt` matches the original verified production artifact:

```bash
# Windows PowerShell
Get-FileHash models\yolov8n.pt -Algorithm SHA256

# Linux / macOS
sha256sum -c models/checksums.sha256
```

Expected hash:
`f59b3d833e2ff32e194b5bb8e08d211dc7c5bdf144b90d2c8412c47ccfc83b36`

---

## TensorRT FP16 Compilation (Optional GPU Acceleration)

For high-throughput deployment on NVIDIA GPUs (Pascal, Turing, Ampere, Ada, Hopper), compile the PyTorch `.pt` model into a hardware-optimized TensorRT FP16 engine (`yolov8n.engine`):

```bash
python export_yolo_tensorrt.py --model models/yolov8n.pt --half --device 0
```

> **Note:** TensorRT `.engine` files are compiled specific to the local GPU architecture, driver, and CUDA/TensorRT versions. They should always be generated locally on the target deployment machine rather than committed across heterogeneous hardware.
