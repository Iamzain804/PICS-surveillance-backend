# ─────────────────────────────────────────────────────────────
# EPIC AI Surveillance Pipeline — Backend Dockerfile
# ─────────────────────────────────────────────────────────────
# Multi-stage build: slim Python with NVIDIA GPU runtime support.
# Supports both CPU-only and GPU (NVIDIA CUDA) deployments.
# ─────────────────────────────────────────────────────────────

FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04 AS base

# Prevent interactive prompts during apt install
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.11 \
    python3.11-venv \
    python3-pip \
    ffmpeg \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Symlink python
RUN ln -sf /usr/bin/python3.11 /usr/bin/python && \
    ln -sf /usr/bin/python3.11 /usr/bin/python3

WORKDIR /app

# Install Python dependencies first (layer cache optimization)
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir pyyaml celery[redis]

# Copy application code
COPY . .

# Create required data directories
RUN mkdir -p data/raw/checkin data/raw/checkout data/raw/breakin data/raw/breakout \
             data/processed/checkin data/processed/checkout data/processed/breakin data/processed/breakout \
             data/review_crops \
             temp temp_chunks reports

# Expose API port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8000/api/pipeline/health || exit 1

# Default: start both API + watcher
CMD ["python", "start_epic.py"]
