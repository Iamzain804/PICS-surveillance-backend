import os
import threading
from typing import Iterable, Optional, TextIO


def tee_stream_to_file_and_console(stream: Iterable[str], log_path: str, prefix: str = "", console: Optional[TextIO] = None):
    """Stream lines to both a file and stdout/console while preserving order."""
    if console is None:
        console = None

    def _runner():
        with open(log_path, "a", encoding="utf-8", errors="replace") as fh:
            for raw_line in stream:
                line = raw_line.rstrip("\n")
                if not line:
                    continue
                out_line = f"{prefix}{line}" if prefix else line
                fh.write(out_line + "\n")
                fh.flush()
                if console is not None:
                    console.write(out_line + "\n")
                    console.flush()
                else:
                    print(out_line, flush=True)

    thread = threading.Thread(target=_runner, daemon=True)
    thread.start()
    return thread
