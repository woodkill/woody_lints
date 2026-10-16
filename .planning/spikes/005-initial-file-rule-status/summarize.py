"""spike 005 — `dart analyze --format=json` 출력에서 옵션 파일 진단만 한 줄씩 찍는다.

사용법: python3 summarize.py <json 출력 파일> <종료 코드> <기준 폴더>
"""
import json
import sys


def summarize(out_path: str, exit_code: str, base_dir: str) -> None:
    """JSON 출력 파일을 읽어 진단을 `경로:줄 강도 code — 메시지` 로 찍는다."""
    try:
        raw = open(out_path, encoding="utf-8").read().strip()
    except OSError as error:
        print(f"  출력 파일을 읽지 못했다: {error}")
        return
    line = next((l for l in reversed(raw.splitlines()) if l.lstrip().startswith("{")), "")
    try:
        diagnostics = json.loads(line)["diagnostics"]
    except (json.JSONDecodeError, KeyError):
        print(f"  exit {exit_code} — JSON 없음. 출력 앞부분: {raw[:200]!r}")
        return
    print(f"  exit {exit_code} — 진단 {len(diagnostics)}건")
    prefix = base_dir.rstrip("/") + "/"
    for d in sorted(diagnostics, key=lambda d: (d["location"]["file"], d["location"]["range"]["start"]["line"])):
        path = d["location"]["file"]
        path = path[len(prefix):] if path.startswith(prefix) else path
        start = d["location"]["range"]["start"]["line"]
        print(f"    {path}:{start}  {d['severity'].lower()}  {d['code']} — {d['problemMessage']}")


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print(__doc__)
        sys.exit(64)
    summarize(sys.argv[1], sys.argv[2], sys.argv[3])
