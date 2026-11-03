"""
Vectorized enrolled-employee face search.

Moved from integrated_pipeline.py with no logic changes: builds a single
normalized (N_total, D) embedding matrix across every enrolled employee's
encodings, then does one matrix-vector cosine-similarity multiply per query
face instead of a brute-force per-employee loop (~10x faster).
"""

from __future__ import annotations

import os
import pickle
from typing import Any, Optional

import numpy as np

from pipeline.logging_setup import get_logger

logger = get_logger("matcher")

EnrollmentMatrix = tuple[Optional[np.ndarray], list[str], list[int], list[float]]


def load_enrolled_employees(pkl_path: str, backend_dir: Optional[str] = None) -> dict[str, Any]:
    """
    Load enrolled employee face vectors from a PKL file.

    ``backend_dir`` anchors the fallback path exactly like the original
    integrated_pipeline.py did (relative to the backend root, i.e.
    ``<backend_dir>/../encoding/encodings.pkl`` -- a sibling ``encoding/``
    directory one level above web-admin-backend/, which is where
    encodings.pkl actually lives in this deployment). Passing pkl_path's own
    directory here would silently resolve to the wrong location.
    """
    if not os.path.exists(pkl_path):
        base_dir = backend_dir or os.path.dirname(os.path.abspath(pkl_path))
        alt_path = os.path.join(base_dir, "..", "encoding", "encodings.pkl")
        if os.path.exists(alt_path):
            pkl_path = alt_path
        else:
            return {}

    try:
        with open(pkl_path, "rb") as f:
            data = pickle.load(f)
            if isinstance(data, dict):
                return data
    except Exception as e:
        logger.warning("Failed to load enrolled-employee encodings from %s: %s", pkl_path, e)
    return {}


def build_enrollment_matrix(enrolled_employees: dict[str, Any]) -> EnrollmentMatrix:
    """
    Pre-computes a normalized embedding matrix and index for vectorized cosine similarity.
    Returns: (matrix: np.ndarray shape (N_total, D), emp_ids, enc_indices, weights)
    Where enc_indices[i] maps row i to the encoding index within that employee's list.
    """
    all_embeddings: list[np.ndarray] = []
    emp_ids: list[str] = []
    enc_indices: list[int] = []
    all_weights: list[float] = []

    for emp_id, info in enrolled_employees.items():
        if isinstance(info, dict):
            encodings = info.get("encodings", [])
            weights = info.get("weights", [])
        elif isinstance(info, (list, tuple)):
            encodings = info
            weights = []
        else:
            continue

        if not encodings:
            continue

        for i, enc in enumerate(encodings):
            enc_arr = np.array(enc, dtype=np.float32)
            enc_norm = np.linalg.norm(enc_arr)
            if enc_norm > 0:
                enc_arr = enc_arr / enc_norm
            all_embeddings.append(enc_arr)
            emp_ids.append(str(emp_id))
            enc_indices.append(i)
            w = weights[i] if (isinstance(weights, (list, tuple)) and i < len(weights)) else 1.0
            all_weights.append(float(w))

    if not all_embeddings:
        return None, [], [], []

    matrix = np.stack(all_embeddings, axis=0)  # (N_total, D)
    return matrix, emp_ids, enc_indices, all_weights


_ENROLLMENT_MATRIX_CACHE: Optional[EnrollmentMatrix] = None


def _get_enrollment_matrix(enrolled_employees: dict[str, Any]) -> EnrollmentMatrix:
    """Returns the process-wide cached (matrix, emp_ids, enc_indices, weights) tuple."""
    global _ENROLLMENT_MATRIX_CACHE
    if _ENROLLMENT_MATRIX_CACHE is None:
        _ENROLLMENT_MATRIX_CACHE = build_enrollment_matrix(enrolled_employees)
    return _ENROLLMENT_MATRIX_CACHE


def search_with_margin(
    face: Any,
    enrolled_employees: dict[str, Any],
) -> tuple[Optional[str], float, Optional[str], float]:
    """
    Computes cosine similarity against all stored vectors of all employees (max sim per employee).
    Returns: (top1_id, top1_sim, second_best_id, second_best_sim)
    """
    if not enrolled_employees or not hasattr(face, "embedding") or face.embedding is None:
        return None, 0.0, None, 0.0

    target_emb = face.embedding.astype(np.float32)
    norm = np.linalg.norm(target_emb)
    if norm > 0:
        target_emb = target_emb / norm

    matrix, emp_ids, enc_indices, weights = _get_enrollment_matrix(enrolled_employees)
    if matrix is None:
        return None, 0.0, None, 0.0

    raw_sims = matrix @ target_emb  # (N_total,)

    weight_arr = np.array(weights, dtype=np.float32)
    weighted_sims = raw_sims * weight_arr

    emp_max_sims: dict[str, float] = {}
    for i, emp_id in enumerate(emp_ids):
        sim_val = float(weighted_sims[i])
        if emp_id not in emp_max_sims or sim_val > emp_max_sims[emp_id]:
            emp_max_sims[emp_id] = sim_val

    if not emp_max_sims:
        return None, 0.0, None, 0.0

    sorted_employees = sorted(emp_max_sims.items(), key=lambda x: x[1], reverse=True)

    top1_id, top1_sim = sorted_employees[0]
    second_best_id, second_best_sim = None, 0.0
    if len(sorted_employees) >= 2:
        second_best_id, second_best_sim = sorted_employees[1]

    return top1_id, round(top1_sim, 4), second_best_id, round(second_best_sim, 4)
