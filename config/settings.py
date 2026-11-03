"""
EPIC Centralised Configuration Loader
======================================
Loads config/config.yaml, merges with environment variable overrides,
and exposes a singleton `cfg` dict for all modules.

Usage:
    from config.settings import cfg
    threshold = cfg["face_recognition"]["recognition_threshold"]
"""

import os
import yaml
from typing import Any, Dict

_BACKEND_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_CONFIG_PATH = os.path.join(_BACKEND_DIR, "config", "config.yaml")

_cfg_cache: Dict[str, Any] = {}


def _deep_merge(base: dict, override: dict) -> dict:
    """Recursively merge override into base."""
    merged = dict(base)
    for k, v in override.items():
        if k in merged and isinstance(merged[k], dict) and isinstance(v, dict):
            merged[k] = _deep_merge(merged[k], v)
        else:
            merged[k] = v
    return merged


def _apply_env_overrides(cfg: dict) -> dict:
    """Map well-known environment variables onto the config dict."""
    env_map = {
        # database
        "DATABASE_URL":             ("database", "url"),
        # api
        "API_HOST":                 ("api", "host"),
        "API_PORT":                 ("api", "port"),
        # watcher
        "POLL_INTERVAL":            ("watcher", "poll_interval_seconds"),
        # face recognition
        "RECOGNITION_THRESHOLD":    ("face_recognition", "recognition_threshold"),
        # motion gating
        "MOTION_THRESHOLD_RATIO":   ("motion_gating", "threshold_ratio"),
        # smtp
        "SMTP_SERVER":              ("smtp", "server"),
        "SMTP_PORT":                ("smtp", "port"),
        "SMTP_USERNAME":            ("smtp", "username"),
        "SMTP_PASSWORD":            ("smtp", "password"),
        "SMTP_SENDER":              ("smtp", "sender"),
    }

    for env_key, path in env_map.items():
        val = os.environ.get(env_key)
        if val is not None:
            node = cfg
            for p in path[:-1]:
                node = node.setdefault(p, {})
            # Attempt type coercion
            existing = node.get(path[-1])
            if isinstance(existing, int):
                try:
                    val = int(val)
                except ValueError:
                    pass
            elif isinstance(existing, float):
                try:
                    val = float(val)
                except ValueError:
                    pass
            elif isinstance(existing, bool):
                val = val.lower() in ("true", "1", "yes")
            node[path[-1]] = val

    return cfg


def load_config(config_path: str = None) -> Dict[str, Any]:
    """Load YAML config, apply env overrides, and return config dict."""
    global _cfg_cache
    if _cfg_cache:
        return _cfg_cache

    path = config_path or _CONFIG_PATH

    if os.path.exists(path):
        with open(path, "r", encoding="utf-8") as f:
            raw = yaml.safe_load(f) or {}
    else:
        print(f"[CONFIG WARNING] Config file not found at {path}, using defaults.")
        raw = {}

    raw = _apply_env_overrides(raw)
    _cfg_cache = raw
    return _cfg_cache


def get(section: str, key: str = None, default: Any = None) -> Any:
    """Convenient accessor: get("face_recognition", "recognition_threshold", 0.50)"""
    cfg = load_config()
    node = cfg.get(section, {})
    if key is None:
        return node if node else default
    return node.get(key, default) if isinstance(node, dict) else default


# Auto-load on import
cfg = load_config()
