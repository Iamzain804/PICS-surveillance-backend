# PICS — Surveillance Backend

A high-throughput, GPU-accelerated Computer Vision and REST API backend for **PICS** (People Intelligence Camera System) — an automated employee attendance and break monitoring platform. 

The system processes multi-camera continuous CCTV footage using hardware-accelerated video decoding (NVDEC), TensorRT-optimized person detection (YOLOv8), multi-target tracking (ByteTrack), facial biometric recognition (InsightFace ArcFace), vectorized cosine similarity matching, and OCR-based timestamp drift correction.

---

## 1. Project Overview

PICS Backend bridges industrial CCTV surveillance with modern human resource analytics. Rather than requiring active employee interaction (e.g., RFID badges or fingerprint scanners), PICS passively processes entrance and exit surveillance streams, tracks human entities, extracts biometric facial embeddings, resolves identity against an enrolled staff matrix, and logs verifiable attendance events to a relational database.

---

## 2. System Objectives

- **Passive & Non-Intrusive:** Eliminate hardware bottlenecks by analyzing standard surveillance video streams.
- **High Throughput & Speed:** Leverage NVIDIA GPU hardware acceleration (NVDEC, TensorRT, cuDNN) to process multi-hour footage faster than real-time.
- **Compute Efficiency:** Avoid wasteful deep inference on empty or static frames using motion gating.
- **Biometric Accuracy:** Employ high-accuracy angular margin loss embeddings (ArcFace) with multi-frame sample accumulation and strict quality gating.
- **Temporal Fidelity:** Overcome camera clock drift and variable frame rates by reading burnt-in camera watermarks via OCR and applying retrospective linear interpolation.

---

## 3. Core Backend Features

- **NVDEC Hardware Video Decoding:** H.264/HEVC hardware decoding via PyAV (`h264_cuvid`) with zero CPU overhead.
- **SmartVideoDecoder (Motion Gating):** Background thread motion filtering straight from decoder YUV planes; static frames skip full 1080p BGR allocation, saving computational cycles and memory bandwidth.
- **YOLOv8 Detection & TensorRT FP16:** Person detection running on NVIDIA TensorRT FP16 engines for 2–4x lower latency.
- **ByteTrack Integration:** Persistent entity tracking across occlusions and camera crossings.
- **InsightFace Face Recognition:** RetinaFace detection + ArcFace ResNet50 (512-dimensional normalized embeddings).
- **Vectorized Face Matching:** Single BLAS matrix-vector product `(N × 512) @ (512,)` against all enrolled staff encodings.
- **Three-Class Decision Logic:** Categorizes recognition into `recognized`, `ambiguous` (routed to human review queue), or `unrecognized`.
- **OCR Drift Correction:** Burnt-in video timestamp extraction (CLAHE + EasyOCR) with `scipy.interpolate.interp1d` linear drift interpolation.
- **Automated Checkpointing:** Recovers interrupted multi-hour video runs from frame checkpoints and recombines segments with FFmpeg.
- **RESTful API & Asynchronous Tasks:** FastAPI endpoints with Celery and Redis task queue.
- **Excel Report Engine:** Automated attendance and break reporting with customizable department, shift, and date filters.

---

## 4. System Architecture

```
                    [ CCTV Surveillance Camera Streams ]
                                    │
                                    ▼
       ┌────────────────────────────────────────────────────────┐
       │             Layer 1: NVDEC GPU Video Decoder           │
       │    (h264_cuvid hardware decoding via PyAV / PyTorch)   │
       └────────────────────────────┬───────────────────────────┘
                                    │
                                    ▼
       ┌────────────────────────────────────────────────────────┐
       │         Layer 2: Smart Motion Gating (160x120)         │
       │ (Static frames skipped — no full BGR buffer allocated) │
       └────────────────────────────┬───────────────────────────┘
                                    │ (Motion Detected)
                                    ▼
       ┌────────────────────────────────────────────────────────┐
       │     Layer 3: YOLOv8n TensorRT FP16 Person Detection    │
       │            + Embedded ByteTrack Association            │
       └────────────────────────────┬───────────────────────────┘
                                    │ (Person Bounding Box Crops)
                                    ▼
       ┌────────────────────────────────────────────────────────┐
       │    Layer 4: InsightFace Buffalo_L (Face Recognition)   │
       │  (Quality Gating: area × detection_score × symmetry)   │
       └────────────────────────────┬───────────────────────────┘
                                    │ (512-dim Embedding)
                                    ▼
       ┌────────────────────────────────────────────────────────┐
       │     Layer 5: Vectorized Matrix Cosine Search           │
       │      Three-Outcome Logic: Recognized / Ambiguous       │
       └────────────────────────────┬───────────────────────────┘
                                    │
                                    ▼
       ┌────────────────────────────────────────────────────────┐
       │   Layer 6: EasyOCR Watermark + Scipy Drift Correction  │
       └────────────────────────────┬───────────────────────────┘
                                    │
                                    ▼
         [ PostgreSQL DB ]  ◄───────────────►  [ FastAPI REST API ]
                 │                                      │
                 ▼                                      ▼
     [ Celery / Redis Workers ]              [ PICS Web Dashboard ]
```

---

## 5. Technology Stack

| Category | Component | Specification |
|---|---|---|
| Runtime | Python | 3.10 / 3.11 |
| Web Framework | FastAPI | Asynchronous ASGI REST API |
| Database | PostgreSQL + SQLAlchemy | Relational storage with Alembic migrations |
| Task Queue | Celery + Redis | Asynchronous video processing jobs |
| Deep Learning | PyTorch + Torchvision | CUDA 12.4 acceleration |
| Inference Engine | NVIDIA TensorRT | FP16 optimized execution engines |
| Detection | Ultralytics YOLOv8 | Nano detection (`yolov8n`) |
| Face Biometrics | InsightFace (buffalo_l) | RetinaFace + ArcFace ResNet50 |
| Tracking | ByteTrack | Embedded within Ultralytics pipeline |
| OCR | EasyOCR | CLAHE image enhancement + OCR text recognition |
| Hardware Video | PyAV / FFmpeg | NVDEC (`h264_cuvid`) GPU decoding |
| Reports | OpenPyXL | Formatted Excel attendance & break reports |

---

## 6. AI Model Inventory & Verification

All official model weights and metadata are cataloged in `models/manifest.yaml`.

| Model Name | Architecture | Format | Size | SHA256 Checksum | Purpose |
|---|---|---|---|---|---|
| `yolov8n.pt` | YOLOv8 Nano | PyTorch | 6.25 MB | `f59b3d833e2ff32e194b5bb8e08d211dc7c5bdf144b90d2c8412c47ccfc83b36` | Person Detection (Class 0) |
| `buffalo_l` | RetinaFace + ArcFace | ONNX | ~300 MB | Verified Registry | Face Detection & Embedding |
| `bytetrack` | Kalman + Association | YAML | — | `config/bytetrack.yaml` | Multi-Target Tracking |

Integrity check command:
```bash
# Windows PowerShell
Get-FileHash models\yolov8n.pt -Algorithm SHA256

# Linux
sha256sum -c models/checksums.sha256
```

---

## 7. Project Directory Structure

```
PICS-surveillance-backend/
├── ai/                        # Deep learning inference and decoder modules
│   ├── face_registration.py   # Staff biometric enrollment utility
│   ├── gpu_decoder.py         # NVDEC & SmartVideoDecoder implementations
│   ├── matcher.py             # Vectorized cosine similarity face matching
│   ├── ocr_extractor.py       # Camera timestamp OCR extraction
│   └── tracker_engine.py      # Tracker interfaces
├── config/                    # Configuration files
│   ├── bytetrack.yaml         # ByteTrack tracking parameters
│   ├── config.yaml            # Central pipeline and service configuration
│   └── settings.py            # YAML and environment variable loader
├── database/                  # Database models and session management
│   └── database.py            # SQLAlchemy schema definitions
├── docs/                      # Architectural documentation and audits
├── migrations/                # Alembic database migrations
├── models/                    # AI model artifacts and metadata
│   ├── manifest.yaml          # Model version and architecture manifest
│   ├── checksums.sha256       # SHA256 verification hashes
│   ├── README.md              # Model compilation and runtime guide
│   └── yolov8n.pt             # Verified YOLOv8n detection weights
├── pipeline/                  # Modular video processing pipeline
│   ├── benchmark.py           # Pipeline benchmarking utilities
│   ├── checkpoint.py          # Mid-run checkpoint serialization
│   ├── config.py              # Strongly-typed PipelineConfig dataclass
│   ├── decoder.py             # Public decoder exports
│   ├── detector.py            # YOLO detector with TensorRT fallback
│   ├── logging_setup.py       # Structured logging
│   ├── matcher.py             # Matrix embedding matcher
│   ├── motion.py              # Motion gating algorithms
│   ├── pipeline.py            # Single-pass video processing orchestration
│   ├── recognizer.py          # InsightFace wrapper with quality gates
│   ├── timestamps.py          # OCR timestamp drift corrector
│   ├── tracker.py             # TrackState bookkeeping
│   └── video_io.py            # FFmpeg writers and HUD drawing
├── reports/                   # Excel report generation logic
├── schemas/                   # Pydantic request/response schemas
├── seeders/                   # Initial database seeding scripts
├── services/                  # Business logic services
├── tests/                     # Unit and integration test suites
├── .env.example               # Safe environment configuration template
├── .gitattributes             # Git LFS tracking rules
├── .gitignore                 # Strict exclusion rules
├── ab_benchmark_suite.py      # A/B testing suite (PyTorch vs TensorRT)
├── alembic.ini                # Alembic configuration
├── api_server.py              # FastAPI main application entry point
├── auto_pipeline.py           # Autonomous camera watcher service
├── benchmark_pipeline_speed.py # Wall-clock database throughput benchmark
├── celery_app.py              # Celery worker application
├── export_yolo_tensorrt.py    # TensorRT FP16 engine compilation utility
├── generate_excel_report.py   # CLI Excel report generator
├── integrated_pipeline.py     # Backward-compatible pipeline runner
├── logger.py                  # Logger configuration
├── requirements.txt           # Python dependency specification
└── README.md                  # Project documentation
```

---

## 8. Installation & Setup

### Prerequisites
- **Python:** 3.10 or 3.11
- **NVIDIA GPU:** 6GB+ VRAM recommended (Pascal or newer)
- **NVIDIA Drivers:** Driver 535+ (CUDA 12.x compatible)
- **PostgreSQL:** Version 14 or newer
- **Redis:** Version 6 or newer
- **FFmpeg:** Installed and available on system `PATH`

### 1. Clone the Repository
```bash
git clone https://github.com/Iamzain804/PICS-surveillance-backend.git
cd PICS-surveillance-backend
```

### 2. Create and Activate Virtual Environment
```bash
# Windows
python -m venv .venv
.\.venv\Scripts\activate

# Linux
python3 -m venv .venv
source .venv/bin/activate
```

### 3. Install PyTorch with CUDA Support
```bash
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu124
```

### 4. Install Dependencies
```bash
pip install -r requirements.txt
```

### 5. Configure Environment Variables
```bash
cp .env.example .env
```
Update `.env` with your PostgreSQL database credentials and Redis URL.

### 6. Initialize Database
```bash
alembic upgrade head
```

### 7. (Optional) Compile TensorRT Engine
To enable 2–4x faster YOLO inference on NVIDIA GPUs:
```bash
python export_yolo_tensorrt.py --model models/yolov8n.pt --half --device 0
```
This generates `models/yolov8n.engine`. The pipeline automatically detects and prioritizes the `.engine` file.

---

## 9. Running the Services

### Start FastAPI API Server
```bash
uvicorn api_server:app --host 0.0.0.0 --port 8000 --reload
```
Interactive API documentation will be available at `http://localhost:8000/docs`.

### Start Celery Background Worker
```bash
# Windows (solo pool for CUDA compatibility)
celery -A celery_app worker --loglevel=info -P solo

# Linux
celery -A celery_app worker --loglevel=info --concurrency=2
```

### Run Autonomous Video Watcher
```bash
python auto_pipeline.py
```

---

## 10. Benchmarking & Verification

The repository includes reproducible benchmarking utilities:

```bash
# 1. Controlled A/B Benchmark (PyTorch vs TensorRT, Latency P50/P95/P99)
python ab_benchmark_suite.py

# 2. Database Wall-Clock Speed Measurement
python benchmark_pipeline_speed.py

# 3. Validate Motion Gate Agreement
python validate_motion_gate.py
```

---

## 11. Security & Compliance

- **No Surveillance Footage Stored in Git:** CCTV video clips, raw footage, and event crops are excluded via `.gitignore`.
- **Zero Hardcoded Secrets:** All credentials, database connection strings, and tokens are read strictly from environment variables.
- **Privacy Preservation:** Actual biometric encoding dumps (`.pkl.backup`) containing employee facial vectors are strictly excluded from source control.

---

## 12. Maintainer

**Muhammad Zain Manzoor**  
GitHub: [@Iamzain804](https://github.com/Iamzain804)
