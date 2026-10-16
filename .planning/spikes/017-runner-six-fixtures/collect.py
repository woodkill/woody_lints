#!/usr/bin/env python3
"""spike 017 · 018 — GitHub 실행 하나의 job 별 시간과 결과를 모아 JSON 으로 쓴다.

사용법: python3 .planning/spikes/017-runner-six-fixtures/collect.py <run id> <출력 파일>

`gh` 로 job 목록과 job 별 로그를 읽는다 (읽기만 한다). 로그에서 집어내는 것:
  - `SPIKE017_RESULT {…}` 한 줄 (runner_probe.dart 가 찍는다)
  - "Set up job" 의 `Image:` · `Version:` 줄, `/etc/os-release` 의 PRETTY_NAME, glibc 버전 줄
    (이미지가 실제로 달랐다는 대조)
  - 검증 명령의 화면에서 `SDK` · `plugin` 줄과 마지막 판정 줄 (verify job)
python 3.9 에서 돈다.
"""
import json
import re
import subprocess
import sys
from datetime import datetime


def gh(*args):
    """`gh` 를 돌려 stdout 을 돌려준다. 실패하면 메시지를 찍고 끝낸다 (69)."""
    done = subprocess.run(["gh", *args], capture_output=True, text=True)
    if done.returncode != 0:
        sys.stderr.write("gh %s 실패: %s\n" % (" ".join(args), done.stderr.strip()))
        sys.exit(69)
    return done.stdout


def seconds(start, end):
    """ISO 시각 둘 사이의 초. 하나라도 없으면 None."""
    if not start or not end:
        return None
    fmt = "%Y-%m-%dT%H:%M:%SZ"
    return int((datetime.strptime(end, fmt) - datetime.strptime(start, fmt)).total_seconds())


def strip_stamp(line):
    """로그 줄 앞의 시각과 색을 입히는 제어 문자를 뗀다."""
    return re.sub(r"^\S+Z ", "", re.sub(r"\x1b\[[0-9;]*[A-Za-z]", "", line))


def read_job(repo, job):
    """job 하나의 시간과 로그에서 집어낸 값을 dict 로 만든다."""
    # 로그에는 색을 입히는 제어 문자가 들어 있어 gh 가 기본으로는 내주지 않는다.
    log = gh("api", "--allow-escape-sequences", "repos/%s/actions/jobs/%s/logs" % (repo, job["id"]))
    lines = [strip_stamp(l) for l in log.splitlines()]
    result = None
    for line in lines:
        if line.startswith("SPIKE017_RESULT "):
            result = json.loads(line.split(" ", 1)[1])
    pretty = next((l for l in lines if l.startswith("PRETTY_NAME=")), None)
    glibc = next((l for l in lines if l.startswith("ldd (")), None)
    screen = [l for l in lines if re.match(r"^(SDK|기반 세트|plugin)\s{2,}\S", l)]
    verdict = next((l for l in lines if l.startswith("점검 통과") or l.startswith("점검 실패")), None)
    # "Set up job" 이 찍는 runner 이미지의 이름과 버전 — `ubuntu-latest` 가 실제로 무엇이었는지 본다.
    at = next((i for i, l in enumerate(lines) if l.startswith("Image: ")), None)
    image = None
    if at is not None:
        version = next((l for l in lines[at + 1:at + 4] if l.startswith("Version: ")), "Version: ?")
        image = "%s %s" % (lines[at].split(": ", 1)[1], version.split(": ", 1)[1])
    return {
        "name": job["name"],
        "conclusion": job["conclusion"],
        "labels": job.get("labels"),
        "jobSeconds": seconds(job.get("started_at"), job.get("completed_at")),
        "stepSeconds": {
            s["name"]: seconds(s.get("started_at"), s.get("completed_at")) for s in job.get("steps", [])
        },
        "runnerImage": image,
        "osRelease": pretty.split("=", 1)[1].strip('"') if pretty else None,
        "glibc": glibc,
        "verifyScreen": screen or None,
        "verifyVerdict": verdict,
        "result": result,
    }


def main():
    if len(sys.argv) != 3:
        sys.stderr.write("사용법: python3 .planning/spikes/017-runner-six-fixtures/collect.py <run id> <출력 파일>\n")
        sys.exit(64)
    run_id, out_path = sys.argv[1], sys.argv[2]
    repo = gh("repo", "view", "--json", "nameWithOwner", "-q", ".nameWithOwner").strip()
    run = json.loads(gh("api", "repos/%s/actions/runs/%s" % (repo, run_id)))
    jobs = json.loads(gh("api", "repos/%s/actions/runs/%s/jobs?per_page=100" % (repo, run_id)))["jobs"]
    out = {
        "runId": int(run_id),
        "workflow": run["name"],
        "event": run["event"],
        "headSha": run["head_sha"][:7],
        "conclusion": run["conclusion"],
        "createdAt": run["created_at"],
        "jobs": sorted((read_job(repo, j) for j in jobs), key=lambda j: j["name"]),
    }
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, indent=2)
        f.write("\n")
    for j in out["jobs"]:
        r = j["result"] or {}
        passes = ", ".join("%s %.1fs" % (p["tag"], p["wallMs"] / 1000) for p in r.get("passes", []))
        print("%-44s %-8s job %4ss  %s%s" % (
            j["name"], j["conclusion"], j["jobSeconds"], passes,
            "" if not r else ("  확인 %s" % ("모두 성립" if r.get("checksOk") else "실패 %s" % r.get("failed"))),
        ))


if __name__ == "__main__":
    main()
