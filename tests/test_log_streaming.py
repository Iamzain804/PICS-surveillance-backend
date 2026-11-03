from io import StringIO

from log_streaming import tee_stream_to_file_and_console


def test_tee_stream_to_file_and_console(tmp_path):
    console = StringIO()
    log_path = tmp_path / "job.log"
    stream = iter(["alpha\n", "beta\n"])

    thread = tee_stream_to_file_and_console(stream, str(log_path), prefix="[JOB] ", console=console)
    thread.join(timeout=2)

    assert log_path.read_text(encoding="utf-8").splitlines() == ["[JOB] alpha", "[JOB] beta"]
    assert console.getvalue().splitlines() == ["[JOB] alpha", "[JOB] beta"]
