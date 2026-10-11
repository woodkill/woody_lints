"""spike 008 — 분석 도중에 Ctrl-C 를 누른 상황을 만들고, 그 뒤의 실행이 스스로 회복하는지 본다.

사용법: python3 .planning/spikes/008-state-folder-placement/interrupt.py <작업 폴더>

<작업 폴더>/fx 가 있어야 한다 (state_probe.dart 의 placement 부가 만든다).
`dart analyze` 를 새 세션으로 띄운 뒤 그 프로세스 그룹 전체에 SIGINT 를 보낸다
(터미널에서 Ctrl-C 를 누르면 하위 프로세스까지 함께 받는 것과 같다).
상태 폴더는 <작업 폴더>/state 아래에 두고 `~/.dartServer` 는 건드리지 않는다.
"""
import json
import os
import shutil
import signal
import subprocess
import sys
import time
from typing import Optional

HEADER = "An error occurred while executing an analyzer plugin:"
EXPECTED = 4  # 연습용 프로젝트의 기대 진단 수 (lint 2 + plugin 2)


def find_plugin_bin(state: str) -> Optional[str]:
    """상태 폴더에서 plugin 폴더의 bin/ 경로를 찾는다. 없으면 None."""
    manager = os.path.join(state, ".plugin_manager")
    if not os.path.isdir(manager):
        return None
    folders = [os.path.join(manager, name) for name in os.listdir(manager)]
    folders = [f for f in folders if os.path.isdir(f)]
    return os.path.join(folders[0], "bin") if folders else None


def describe_files(state: str) -> str:
    """plugin.aot 과 depfile.txt 가 있는지와 크기를 한 줄로 만든다."""
    bin_dir = find_plugin_bin(state)
    if bin_dir is None:
        return "plugin 폴더 없음"
    parts = []
    for name in ("plugin.aot", "depfile.txt"):
        path = os.path.join(bin_dir, name)
        parts.append(f"{name}={os.path.getsize(path)}바이트" if os.path.exists(path) else f"{name}=없음")
    return ", ".join(parts)


def run_analyze(dart: str, fixture: str, state: str) -> str:
    """분석을 끝까지 돌리고 결과를 한 줄로 만든다."""
    env = dict(os.environ, ANALYZER_STATE_LOCATION_OVERRIDE=state)
    started = time.time()
    done = subprocess.run(
        [dart, "--suppress-analytics", "analyze", "--format=json"],
        cwd=fixture, env=env, capture_output=True, text=True, check=False,
    )
    elapsed = time.time() - started
    line = next((l for l in reversed(done.stdout.splitlines()) if l.lstrip().startswith("{")), "")
    try:
        count = len(json.loads(line)["diagnostics"])
    except (json.JSONDecodeError, KeyError):
        count = None
    ok = done.returncode == 2 and count == EXPECTED
    shown = "JSON 없음" if count is None else f"진단 {count}건"
    header = ", stderr 에 머리말 있음" if HEADER in done.stderr else ""
    return f"{'통과' if ok else '실패'} (exit {done.returncode}, {elapsed:.1f}s, {shown}{header})"


def interrupt_analyze(dart: str, fixture: str, state: str, seconds: float) -> str:
    """분석을 띄우고 [seconds] 초 뒤에 프로세스 그룹 전체에 SIGINT 를 보낸다."""
    env = dict(os.environ, ANALYZER_STATE_LOCATION_OVERRIDE=state)
    process = subprocess.Popen(
        [dart, "--suppress-analytics", "analyze", "--format=json"],
        cwd=fixture, env=env, start_new_session=True,
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
    )
    time.sleep(seconds)
    try:
        os.killpg(process.pid, signal.SIGINT)
    except ProcessLookupError:
        return "끊기 전에 이미 끝났다"
    try:
        process.wait(timeout=20)
    except subprocess.TimeoutExpired:
        os.killpg(process.pid, signal.SIGKILL)
        process.wait()
        return "SIGINT 로 끝나지 않아 SIGKILL 을 보냈다"
    # 하위 프로세스(컴파일러)가 정리될 시간을 조금 준다.
    time.sleep(1.0)
    return f"끊음 (exit {process.returncode})"


def fresh_state(work: str, name: str) -> str:
    """빈 상태 폴더를 만든다."""
    state = os.path.join(work, "state", name)
    shutil.rmtree(state, ignore_errors=True)
    os.makedirs(state)
    return state


def main(work: str) -> int:
    """경우별로 끊고, 그 뒤의 실행 두 번을 찍는다."""
    work = os.path.realpath(work)
    repo = os.path.realpath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
    dart = os.path.join(repo, ".fvm", "flutter_sdk", "bin", "dart")
    fixture = os.path.join(work, "fx")
    if not os.access(dart, os.X_OK):
        print("Dart SDK 를 찾지 못했다 (저장소 루트에서 fvm install 을 먼저 실행)", file=sys.stderr)
        return 66
    if not os.path.isfile(os.path.join(fixture, ".dart_tool", "package_config.json")):
        print("연습용 프로젝트가 없다. state_probe.dart 의 placement 부를 먼저 돌린다", file=sys.stderr)
        return 66

    print("# 1부. 처음 실행을 도중에 끊는다 (컴파일된 plugin 이 아직 없다)")
    for seconds in (3.0, 6.0, 9.0, 11.0):
        state = fresh_state(work, f"interrupt-{int(seconds)}")
        print(f"## {seconds:.0f}초에 끊음: {interrupt_analyze(dart, fixture, state, seconds)}")
        print(f"   남은 파일: {describe_files(state)}")
        print(f"   다음 실행: {run_analyze(dart, fixture, state)}")
        print(f"   그다음 실행: {run_analyze(dart, fixture, state)}")

    print()
    print("# 2부. 준비된 상태에서 다시 컴파일하게 만든 뒤 도중에 끊는다 (옛 depfile.txt 가 남아 있다)")
    for seconds in (3.0, 6.0, 9.0):
        state = fresh_state(work, f"reinterrupt-{int(seconds)}")
        print(f"## 준비: {run_analyze(dart, fixture, state)}")
        bin_dir = find_plugin_bin(state)
        if bin_dir is None:
            print("   plugin 폴더가 없다 — 건너뛴다")
            continue
        # plugin 의 패키지 설정이 snapshot 보다 새것이 되게 한다 (plugin 새 버전이 받아진 상황을 흉내 낸다).
        config = os.path.join(os.path.dirname(bin_dir), ".dart_tool", "package_config.json")
        time.sleep(1.1)
        os.utime(config, None)
        os.utime(os.path.join(bin_dir, "plugin.dart"), None)
        print(f"   {seconds:.0f}초에 끊음: {interrupt_analyze(dart, fixture, state, seconds)}")
        print(f"   남은 파일: {describe_files(state)}")
        print(f"   다음 실행: {run_analyze(dart, fixture, state)}")
        print(f"   그다음 실행: {run_analyze(dart, fixture, state)}")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(__doc__)
        sys.exit(64)
    sys.exit(main(sys.argv[1]))
