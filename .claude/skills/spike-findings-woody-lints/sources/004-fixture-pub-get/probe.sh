#!/usr/bin/env bash
# spike 004 — Flutter 프로젝트인 연습용 프로젝트에서 `flutter pub get` 과 `dart pub get` 이
# 각각 무엇을 바꾸는지 본다.
#
# 실행: bash .planning/spikes/004-fixture-pub-get/probe.sh <작업 폴더>
#
# 경우마다 template/ 을 작업 폴더에 새로 복사해 쓴다. 저장소 안의 파일은 바꾸지 않는다.
set -u

if [ $# -lt 1 ]; then
  echo "사용법: bash probe.sh <작업 폴더>" >&2
  exit 64
fi

SPIKE_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SPIKE_DIR/../../.." && pwd)"
WORK="$1"
# fvm 이 저장소에 걸어 둔 SDK 를 직접 부른다 (작업 폴더가 저장소 밖이라 `fvm` 은 .fvmrc 를 찾지 못한다).
SDK="$REPO_ROOT/.fvm/flutter_sdk"
FLUTTER="$SDK/bin/flutter"
DART="$SDK/bin/dart"
RAW_DART="$SDK/bin/cache/dart-sdk/bin/dart"

if [ ! -x "$FLUTTER" ] || [ ! -x "$DART" ]; then
  echo "Flutter SDK 를 찾지 못했다: $SDK (저장소 루트에서 fvm install 을 먼저 실행)" >&2
  exit 66
fi

mkdir -p "$WORK" || { echo "작업 폴더를 만들지 못했다: $WORK" >&2; exit 73; }

# template/ 을 $WORK/<이름> 으로 새로 복사한다.
make_case() {
  local dir="$WORK/$1"
  rm -rf "$dir"
  mkdir -p "$dir/lib"
  sed "s|__WOODY_LINTS_ROOT__|$REPO_ROOT|" "$SPIKE_DIR/template/pubspec.yaml.tmpl" > "$dir/pubspec.yaml"
  cp "$SPIKE_DIR/template/analysis_options.yaml" "$dir/analysis_options.yaml"
  cp "$SPIKE_DIR/template/lib/main.dart" "$dir/lib/main.dart"
  echo "$dir"
}

# analysis_options.yaml 이 template 과 같은지 찍는다.
report_options() {
  local dir="$1"
  if cmp -s "$SPIKE_DIR/template/analysis_options.yaml" "$dir/analysis_options.yaml"; then
    echo "  analysis_options.yaml: 그대로"
  else
    echo "  analysis_options.yaml: 바뀜 ↓"
    diff -u "$SPIKE_DIR/template/analysis_options.yaml" "$dir/analysis_options.yaml" | sed 's/^/    /'
  fi
}

# 실행 뒤 생긴 파일을 찍는다 (.dart_tool 은 한 단계만).
report_files() {
  local dir="$1"
  echo "  생긴 파일: $(cd "$dir" && find . -maxdepth 2 -not -path './lib*' -not -name '.' -not -name 'pubspec.yaml' -not -name 'analysis_options.yaml' | sort | tr '\n' ' ')"
}

echo "SDK: $("$DART" --version 2>&1)"
echo

echo "## A. dart pub get (Flutter SDK 의 bin/dart)"
A="$(make_case a-dart-pub-get)"
(cd "$A" && "$DART" pub get >"$WORK/a.log" 2>&1); echo "  exit $?"
report_options "$A"; report_files "$A"
echo

echo "## B. flutter pub get"
B="$(make_case b-flutter-pub-get)"
(cd "$B" && "$FLUTTER" pub get >"$WORK/b.log" 2>&1); echo "  exit $?"
grep -i "analysis_options" "$WORK/b.log" | sed 's/^/  출력: /'
report_options "$B"; report_files "$B"
cp "$B/analysis_options.yaml" "$WORK/b-after-first.yaml"
echo

echo "## B2. flutter pub get 을 한 번 더"
(cd "$B" && "$FLUTTER" pub get >"$WORK/b2.log" 2>&1); echo "  exit $?"
if cmp -s "$WORK/b-after-first.yaml" "$B/analysis_options.yaml"; then echo "  첫 실행 뒤와 같음 (더 바꾸지 않음)"; else echo "  또 바뀜"; fi
grep -i "analysis_options" "$WORK/b2.log" | sed 's/^/  출력: /'
echo

echo "## C. build/** 를 미리 적어 둔 뒤 flutter pub get"
C="$(make_case c-pre-excluded)"
printf 'include: package:woody_lints/analysis_options.yaml\n\nanalyzer:\n  exclude:\n    - build/**\n' > "$C/analysis_options.yaml"
cp "$C/analysis_options.yaml" "$WORK/c-before.yaml"
(cd "$C" && "$FLUTTER" pub get >"$WORK/c.log" 2>&1); echo "  exit $?"
if cmp -s "$WORK/c-before.yaml" "$C/analysis_options.yaml"; then echo "  analysis_options.yaml: 그대로"; else echo "  analysis_options.yaml: 바뀜 ↓"; diff -u "$WORK/c-before.yaml" "$C/analysis_options.yaml" | sed 's/^/    /'; fi
echo

echo "## D. android/ 폴더가 있는 프로젝트에서 flutter pub get"
D="$(make_case d-with-platform-dir)"
mkdir -p "$D/android"
(cd "$D" && "$FLUTTER" pub get >"$WORK/d.log" 2>&1); echo "  exit $?"
report_options "$D"
echo

echo "## E. FLUTTER_ROOT 없이 dart-sdk 의 dart 를 직접 불러 pub get"
E="$(make_case e-raw-dart)"
(cd "$E" && env -u FLUTTER_ROOT "$RAW_DART" pub get >"$WORK/e.log" 2>&1); echo "  exit $?"
tail -2 "$WORK/e.log" | sed 's/^/  출력: /'
report_options "$E"
echo

echo "## F. dart pub get 과 flutter pub get 의 결과 비교 (A 대 B)"
python3 - "$A" "$B" <<'PY'
import json, sys
a, b = sys.argv[1], sys.argv[2]
def load(d):
    cfg = json.load(open(f"{d}/.dart_tool/package_config.json"))
    # 프로젝트 자신의 rootUri 와 생성 시각은 경우마다 다르므로 뺀다.
    return {p["name"]: (p["rootUri"], p.get("languageVersion")) for p in cfg["packages"] if p["rootUri"] != "../"}
pa, pb = load(a), load(b)
print("  package_config.json 패키지 수:", len(pa), "대", len(pb), "-", "같음" if pa == pb else "다름")
for name in sorted(set(pa) ^ set(pb)):
    print("    한쪽에만 있음:", name)
la, lb = open(f"{a}/pubspec.lock").read(), open(f"{b}/pubspec.lock").read()
print("  pubspec.lock:", "같음" if la == lb else "다름")
PY
echo

echo "## G. 받은 lock 그대로 강제하는 dart pub get --enforce-lockfile (A 에서)"
cp "$A/pubspec.lock" "$WORK/a-lock-before"
(cd "$A" && "$DART" pub get --enforce-lockfile >"$WORK/g.log" 2>&1); echo "  exit $?"
if cmp -s "$WORK/a-lock-before" "$A/pubspec.lock"; then echo "  pubspec.lock: 그대로"; else echo "  pubspec.lock: 바뀜"; fi
report_options "$A"
echo

echo "## H. include 한 파일이 build/** 를 이미 제외하고 있을 때 flutter pub get"
H="$(make_case h-excluded-via-include)"
printf 'include: package:woody_lints/analysis_options.yaml\n\nanalyzer:\n  exclude:\n    - build/**\n' > "$H/shared.yaml"
printf 'include: shared.yaml\n' > "$H/analysis_options.yaml"
cp "$H/analysis_options.yaml" "$WORK/h-before.yaml"
(cd "$H" && "$FLUTTER" pub get >"$WORK/h.log" 2>&1); echo "  exit $?"
if cmp -s "$WORK/h-before.yaml" "$H/analysis_options.yaml"; then echo "  analysis_options.yaml: 그대로"; else echo "  analysis_options.yaml: 바뀜 ↓"; diff -u "$WORK/h-before.yaml" "$H/analysis_options.yaml" | sed 's/^/    /'; fi
