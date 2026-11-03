import os

from main import resolve_raw_dir


def test_resolve_raw_dir_defaults_to_data_raw(monkeypatch):
    monkeypatch.delenv("RAW_VIDEO_DIR", raising=False)
    expected = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "data", "raw")
    assert os.path.abspath(resolve_raw_dir()) == os.path.abspath(expected)
