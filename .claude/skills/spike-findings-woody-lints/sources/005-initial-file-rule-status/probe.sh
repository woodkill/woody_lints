#!/usr/bin/env bash
# spike 005 — 규칙을 `analysis_options.yaml` 이름의 파일에 직접 적었을 때(initial file)
# analyzer 가 deprecated / removed / 없는 규칙을 어떻게 보고하는지 본다.
#
# 실행: bash .planning/spikes/005-initial-file-rule-status/probe.sh <작업 폴더>
#
# 저장소 안에는 build/woody_rule_check/ 만 잠깐 만들었다가 지운다. lib/ 는 읽기만 한다.
set -u

if [ $# -lt 1 ]; then
  echo "사용법: bash probe.sh <작업 폴더>" >&2
  exit 64
fi

SPIKE_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SPIKE_DIR/../../.." && pwd)"
WORK="$1"
DART="$REPO_ROOT/.fvm/flutter_sdk/bin/dart"
SHIPPED="$REPO_ROOT/lib/analysis_options.yaml"
IN_REPO_CHECK="$REPO_ROOT/build/woody_rule_check"

if [ ! -x "$DART" ]; then
  echo "Dart SDK 를 찾지 못했다: $DART (저장소 루트에서 fvm install 을 먼저 실행)" >&2
  exit 66
fi
mkdir -p "$WORK" || { echo "작업 폴더를 만들지 못했다: $WORK" >&2; exit 73; }

# 저장소 안에 만든 임시 폴더는 어떤 경우에도 지운다.
cleanup() {
  rm -rf "$IN_REPO_CHECK"
  rmdir "$REPO_ROOT/build" 2>/dev/null || true
}
trap cleanup EXIT

export DASH__SUPPRESS_ANALYTICS=true
export ANALYZER_STATE_LOCATION_OVERRIDE="$WORK/state"

# $1 폴더에서 인자 없이 분석하고 요약을 찍는다. 추가 인자는 dart analyze 에 그대로 넘긴다.
analyze_here() {
  local dir="$1"; shift
  (cd "$dir" && "$DART" analyze --format=json "$@" >"$WORK/out.json" 2>"$WORK/err.txt")
  local code=$?
  python3 "$SPIKE_DIR/summarize.py" "$WORK/out.json" "$code" "$dir"
  if [ -s "$WORK/err.txt" ]; then echo "    stderr: $(head -3 "$WORK/err.txt" | tr '\n' ' ')"; fi
}

# 규칙 목록만 담은 옵션 파일을 가진 순수 Dart 패키지를 만든다.
make_rules_package() {
  local dir="$WORK/$1"; shift
  rm -rf "$dir"; mkdir -p "$dir/lib"
  printf 'name: spike_rule_status\npublish_to: none\nenvironment:\n  sdk: ^3.13.0\n' > "$dir/pubspec.yaml"
  printf '/// 분석 대상이 비지 않게 두는 파일.\nint answer() => 42;\n' > "$dir/lib/a.dart"
  { echo "linter:"; echo "  rules:"; for rule in "$@"; do echo "    - $rule"; done; } > "$dir/analysis_options.yaml"
  (cd "$dir" && "$DART" pub get >/dev/null 2>&1)
  echo "$dir"
}

echo "SDK: $("$DART" --version 2>&1)"
echo
echo "# 1부. 규칙 하나씩 (규칙 목록만 적은 옵션 파일)"
for rule in unnecessary_await_in_return prefer_final_parameters avoid_returning_null no_such_rule_zz9 avoid_print; do
  echo "## $rule"
  analyze_here "$(make_rules_package "one-$rule" "$rule")"
done

echo
echo "# 2부. rules.json(3.13.4 tag) 이 deprecated 라고 적은 5개 + unnecessary_await_in_return"
analyze_here "$(make_rules_package six avoid_null_checks_in_equality_operators avoid_private_typedef_functions one_member_abstracts prefer_final_parameters use_if_null_to_convert_nulls_to_bools unnecessary_await_in_return)"

echo
echo "# 3부. 같은 규칙들을 include 한 파일에 적었을 때"
INC="$(make_rules_package via-include avoid_print)"
{ echo "linter:"; echo "  rules:"; for rule in unnecessary_await_in_return prefer_final_parameters avoid_returning_null no_such_rule_zz9; do echo "    - $rule"; done; } > "$INC/shared.yaml"
printf 'include: shared.yaml\n' > "$INC/analysis_options.yaml"
analyze_here "$INC"

echo
echo "# 4부. 실제 배포 파일을 initial file 로 (복사 위치별)"
echo "## 4-1. 저장소 안 build/woody_rule_check/ 에 복사, 저장소 루트에서 인자 없이"
mkdir -p "$IN_REPO_CHECK"
cp "$SHIPPED" "$IN_REPO_CHECK/analysis_options.yaml"
analyze_here "$REPO_ROOT"

echo "## 4-2. 같은 복사본, 저장소 루트에서 그 폴더를 인자로"
analyze_here "$REPO_ROOT" build/woody_rule_check

echo "## 4-3. 문제 규칙 4개를 끼워 넣은 복사본, 저장소 루트에서 인자 없이"
python3 - "$SHIPPED" "$IN_REPO_CHECK/analysis_options.yaml" <<'PY'
import sys
src, dst = sys.argv[1], sys.argv[2]
text = open(src, encoding="utf-8").read()
marker = "    - control_flow_in_finally"
assert marker in text, "배포 파일에서 끼워 넣을 자리를 찾지 못했다"
extra = "".join(f"    - {rule}\n" for rule in (
    "unnecessary_await_in_return", "prefer_final_parameters", "avoid_returning_null", "no_such_rule_zz9"))
head, tail = text.split(marker, 1)
line_end = tail.index("\n") + 1
open(dst, "w", encoding="utf-8").write(head + marker + tail[:line_end] + extra + tail[line_end:])
PY
analyze_here "$REPO_ROOT"

echo "## 4-4. 같은 복사본에서 plugins: 를 뺀 것, 저장소 루트에서 인자 없이"
python3 - "$IN_REPO_CHECK/analysis_options.yaml" <<'PY'
import re, sys
path = sys.argv[1]
text = open(path, encoding="utf-8").read()
stripped = re.sub(r"(?m)^plugins:\n(?:[ \t]+.*\n)+", "", text)
assert stripped != text, "plugins: 섹션을 찾지 못했다"
open(path, "w", encoding="utf-8").write(stripped)
PY
analyze_here "$REPO_ROOT"

echo "## 4-5. 저장소 밖 임시 폴더에 원본 복사, --packages 로 저장소의 패키지 설정을 넘김"
OUT="$WORK/outside"; rm -rf "$OUT"; mkdir -p "$OUT"
cp "$SHIPPED" "$OUT/analysis_options.yaml"
analyze_here "$OUT" "--packages=$REPO_ROOT/.dart_tool/package_config.json"

# 문제 규칙 4개를 끼워 넣은 배포 파일 복사본을 $1 에 쓴다.
write_problem_copy() {
  python3 - "$SHIPPED" "$1" <<'PY'
import sys
src, dst = sys.argv[1], sys.argv[2]
text = open(src, encoding="utf-8").read()
marker = "    - control_flow_in_finally"
assert marker in text, "배포 파일에서 끼워 넣을 자리를 찾지 못했다"
extra = "".join(f"    - {rule}\n" for rule in (
    "unnecessary_await_in_return", "prefer_final_parameters", "avoid_returning_null", "no_such_rule_zz9"))
head, tail = text.split(marker, 1)
line_end = tail.index("\n") + 1
open(dst, "w", encoding="utf-8").write(head + marker + tail[:line_end] + extra + tail[line_end:])
PY
}

echo "## 4-6. 문제 규칙 4개를 끼워 넣은 복사본(plugins: 포함), 저장소 루트에서 그 폴더를 인자로"
mkdir -p "$IN_REPO_CHECK"
write_problem_copy "$IN_REPO_CHECK/analysis_options.yaml"
rm -rf "$WORK/state-46"
start=$(date +%s)
ANALYZER_STATE_LOCATION_OVERRIDE="$WORK/state-46" analyze_here "$REPO_ROOT" build/woody_rule_check
echo "    걸린 시간 $(( $(date +%s) - start ))초, plugin 준비 폴더: $(ls "$WORK/state-46/.plugin_manager" 2>/dev/null | wc -l | tr -d ' ')개"

echo "## 4-7. 같은 복사본을 저장소 밖 임시 폴더에 두고 --packages 로 분석"
write_problem_copy "$OUT/analysis_options.yaml"
rm -rf "$WORK/state-47"
start=$(date +%s)
ANALYZER_STATE_LOCATION_OVERRIDE="$WORK/state-47" analyze_here "$OUT" "--packages=$REPO_ROOT/.dart_tool/package_config.json"
echo "    걸린 시간 $(( $(date +%s) - start ))초, plugin 준비 폴더: $(ls "$WORK/state-47/.plugin_manager" 2>/dev/null | wc -l | tr -d ' ')개"

echo "## 4-8. 4-7 과 같되 Dart 파일을 하나 둔 경우"
printf '/// 분석 대상이 비지 않게 두는 파일.\nint answer() => 42;\n' > "$OUT/a.dart"
rm -rf "$WORK/state-48"
start=$(date +%s)
ANALYZER_STATE_LOCATION_OVERRIDE="$WORK/state-48" analyze_here "$OUT" "--packages=$REPO_ROOT/.dart_tool/package_config.json"
echo "    걸린 시간 $(( $(date +%s) - start ))초, plugin 준비 폴더: $(ls "$WORK/state-48/.plugin_manager" 2>/dev/null | wc -l | tr -d ' ')개"

echo
echo "# 5부. 같은 규칙이라도 패키지의 SDK 하한(pubspec 의 environment.sdk)에 따라 보고가 달라지는가"
# $1 이름, $2 SDK 제약(빈 문자열이면 pubspec 없음), 나머지는 규칙
make_sdk_package() {
  local dir="$WORK/$1"; local sdk="$2"; shift 2
  rm -rf "$dir"; mkdir -p "$dir/lib"
  printf '/// 분석 대상이 비지 않게 두는 파일.\nint answer() => 42;\n' > "$dir/lib/a.dart"
  { echo "linter:"; echo "  rules:"; for rule in "$@"; do echo "    - $rule"; done; } > "$dir/analysis_options.yaml"
  if [ -n "$sdk" ]; then
    printf 'name: spike_rule_status\npublish_to: none\nenvironment:\n  sdk: "%s"\n' "$sdk" > "$dir/pubspec.yaml"
    (cd "$dir" && "$DART" pub get >/dev/null 2>&1)
  fi
  echo "$dir"
}
for pair in "unnecessary_await_in_return|^3.12.0" "unnecessary_await_in_return|^3.13.0" \
            "prefer_final_parameters|^3.10.0" "prefer_final_parameters|^3.11.0" \
            "avoid_returning_null|^3.2.0" "avoid_returning_null|^3.3.0" \
            "unnecessary_await_in_return|"; do
  rule="${pair%%|*}"; sdk="${pair##*|}"
  echo "## $rule, sdk: ${sdk:-(pubspec 없음)}"
  analyze_here "$(make_sdk_package "sdk-$rule-$(echo "${sdk:-none}" | tr -d '^.')" "$sdk" "$rule")"
done
