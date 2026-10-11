---
last_mapped_commit: 90a2736b8d998c84467faf562a0fec720b797eaf
last_mapped_at: 2026-10-11
---
# Codebase Concerns

**Analysis Date:** 2026-10-11

**저장소 성격:** Dart 소스 코드가 없는 설정 전용(config-only) 패키지. 배포 산출물은 `lib/analysis_options.yaml` 단 하나이며, 사용하는 프로젝트가 `include: package:woody_lints/analysis_options.yaml` 로 가져간다. 추적 파일은 8개(`.fvmrc`, `.gitignore`, `.vscode/settings.json`, `CHANGELOG.md`, `README.md`, `analysis_options.yaml`, `lib/analysis_options.yaml`, `pubspec.yaml`)이다. 따라서 아래 우려 사항은 대부분 문서-설정 불일치(drift), 배포/버전 관리, 검증 부재에 관한 것이다.

`TODO` / `FIXME` / `HACK` / `XXX` 주석: 검출되지 않음.

## Tech Debt

**README 규칙 목록과 실제 설정의 불일치:**
- Issue: `README.md` 의 "포함된 규칙 목록"이 실제로는 꺼져 있는 항목을 켜진 것처럼 안내한다.
  - `README.md:81` 은 `require_trailing_commas` 를 포함 규칙으로 기재하지만 `lib/analysis_options.yaml:31` 에서 주석 처리되어 있다.
  - `README.md:91-92` 는 `formatter: trailing_commas` 를 포함 항목으로 기재하지만 `lib/analysis_options.yaml:15-16` 에서 주석 처리되어 있다.
  - `lib/analysis_options.yaml:42-47` 의 `analyzer.errors` (`invalid_annotation_target: ignore`) 와 `analyzer.exclude` (`**/*.freezed.dart`, `**/*.g.dart`) 는 README 에 전혀 기재되어 있지 않다.
- Files: `README.md`, `lib/analysis_options.yaml`
- Impact: 사용자가 trailing comma 보존/강제가 적용된다고 믿지만 실제로는 적용되지 않는다. 생성 파일 제외와 오류 무시가 암묵적으로 적용된다는 사실을 사용자가 알 수 없다.
- Fix approach: `lib/analysis_options.yaml` 을 단일 진실 원천(single source of truth)으로 삼고 README 목록을 그에 맞춘다. 규칙을 추가/주석 처리할 때 같은 커밋에서 `README.md` 와 `CHANGELOG.md` 를 함께 수정한다.

**주석 처리된 채 남아 있는 설정(dead config):**
- Issue: 결정이 내려지지 않은 설정이 주석 상태로 배포 파일에 남아 있다 — `formatter: trailing_commas: preserve` (`lib/analysis_options.yaml:15-16`), `require_trailing_commas` (`:31`), `public_member_api_docs` (`:34`). 왜 꺼져 있는지 이유가 적혀 있지 않다.
- Files: `lib/analysis_options.yaml`
- Impact: 의도(일시적 비활성인지 폐기인지)를 알 수 없어 다음 수정자가 임의로 다시 켤 위험이 있다. `public_member_api_docs` 를 켜면 모든 사용 프로젝트에서 대량의 진단이 한꺼번에 발생한다.
- Fix approach: 각 항목을 켜거나 삭제한다. 유지한다면 비활성 사유를 한 줄 주석으로 남긴다.

**템플릿 보일러플레이트 주석이 사실과 다름:**
- Issue: `lib/analysis_options.yaml:1-12` 의 머리 주석은 `package:lints` 의 'recommended' 세트를 켠다고 설명하지만 실제 include 는 `package:flutter_lints/flutter.yaml` (`:13`) 이다. `:18` 의 "Uncomment the following section" 문구 아래 섹션은 이미 활성 상태다. `README.md:1-12` 에는 `dart create` 템플릿의 HTML 주석이 그대로 남아 있다.
- Files: `lib/analysis_options.yaml`, `README.md`
- Impact: 배포 파일을 읽는 사람에게 잘못된 기반 세트를 알려준다.
- Fix approach: 머리 주석을 "flutter_lints 기반 + 추가 규칙" 이라는 실제 구성 설명으로 교체하고 README 의 템플릿 주석을 제거한다.

**기반 세트와 중복되는 규칙 선언:**
- Issue: 명시한 12개 규칙 중 6개는 include 한 세트가 이미 켠다 (로컬 pub cache 의 `flutter_lints-6.0.0`, `lints-6.1.0` 로 확인).
  - `flutter_lints/flutter.yaml` 에 이미 포함: `sized_box_for_whitespace`, `sort_child_properties_last`, `use_build_context_synchronously`, `avoid_print`
  - `lints/recommended.yaml` 에 이미 포함: `slash_for_doc_comments`, `control_flow_in_finally`
  - 이 패키지가 실제로 추가하는 규칙: `prefer_const_constructors`, `prefer_const_literals_to_create_immutables`, `always_declare_return_types`, `prefer_final_locals`, `prefer_single_quotes`, `unawaited_futures`
- Files: `lib/analysis_options.yaml:20-40`, `README.md:70-89`
- Impact: 동작상 문제는 없다. 다만 이 패키지의 실질 기여분이 무엇인지 흐려지고, 기반 세트가 규칙을 제거해도 여기서는 계속 켜진 상태로 남는다(의도라면 명시 필요).
- Fix approach: 중복 선언을 유지한다면 "기반 세트 변경과 무관하게 고정"이라는 의도를 주석으로 남기고, 아니라면 제거한다.

**CHANGELOG 누락:**
- Issue: `CHANGELOG.md` 에는 `1.3.0` 과 `1.0.0` 항목만 있다. 그 사이 버전(예: 커밋 `dbcd20b` 의 `1.2.5`)과 규칙 변경(`slash_for_doc_comments` 추가, `formatter` 추가/비활성, `analyzer:` 섹션 추가)이 기록되어 있지 않다.
- Files: `CHANGELOG.md`, `pubspec.yaml:3`
- Impact: 사용 프로젝트에서 진단이 새로 생기거나 사라졌을 때 원인 버전을 추적할 수 없다.
- Fix approach: `pubspec.yaml` 의 `version` 을 올리는 커밋마다 `CHANGELOG.md` 항목을 추가한다.

**FVM 고정 버전과 문서상 검증 버전의 불일치:**
- Issue: `.fvmrc` 와 `.vscode/settings.json` 은 Flutter `3.41.2` (Dart `3.11.0`) 를 고정한다. 반면 `lib/analysis_options.yaml:50-56`, `README.md:95`, `CHANGELOG.md:5` 는 Flutter `3.41.9` / `3.47.5` (Dart 3.13) 에서의 동작을 근거로 서술한다.
- Files: `.fvmrc`, `.vscode/settings.json`, `lib/analysis_options.yaml`, `README.md`
- Impact: 저장소에 고정된 툴체인으로는 문서에 적힌 동작(legacy plugin 경고, `flutter analyze` 의 plugin 진단 누락)을 재현할 수 없다.
- Fix approach: `.fvmrc` 를 실제 검증에 쓰는 버전으로 올리거나, 문서에 검증 버전과 저장소 고정 버전이 다르다는 점을 명시한다.

## Known Bugs

**`flutter analyze` 가 riverpod_lint 진단을 표시하지 않음 (Flutter 3.47.5):**
- Symptoms: 사용 프로젝트에서 `flutter analyze` 를 실행하면 riverpod_lint 규칙 위반이 출력되지 않는다. `dart analyze` 에서는 출력된다. (저장소 문서에 기록된 2026-09-20 실측이며, 이번 분석에서 재현하지는 않았다.)
- Files: `lib/analysis_options.yaml:55-58`, `README.md:95`
- Trigger: Flutter 3.47.5 에서 `flutter analyze` 실행.
- Workaround: `dart analyze` 를 사용한다. CI 가 `flutter analyze` 만 돌리는 사용 프로젝트는 riverpod_lint 위반을 통과시키므로 CI 명령을 바꿔야 한다.

**저장소 자체 분석 시 `plugins_in_inner_options` 경고:**
- Symptoms: 이 저장소 안에서는 `lib/analysis_options.yaml` 이 inner 옵션 파일로 취급되어 최상위 `plugins:` 에 경고가 난다.
- Files: `analysis_options.yaml:7-9`, `lib/analysis_options.yaml:57-58`
- Trigger: 저장소 루트에서 analyzer 실행.
- Workaround: 루트 `analysis_options.yaml` 이 `lib/analysis_options.yaml` 을 `exclude` 한다. 부작용은 아래 "Fragile Areas" 참조.

## Security Considerations

**고정되지 않은 원격 analyzer plugin 실행:**
- Risk: `plugins: riverpod_lint: ^3.1.3` 은 caret 범위다. plugin 은 사용 프로젝트의 `pubspec.lock` 이 아니라 Dart Analysis Server 의 plugin 캐시(`~/.dartServer/.plugin_manager`)에서 별도로 해석되고, 첫 분석 때 pub.dev 에서 내려받아 개발자 머신과 CI 에서 코드로 실행된다. 사용 프로젝트 쪽에는 이 버전을 고정할 lockfile 이 없다.
- Files: `lib/analysis_options.yaml:49-58`
- Current mitigation: 없음. pub.dev 의 패키지 무결성에 의존한다.
- Recommendations: 재현성과 공급망(supply chain) 통제가 필요하면 정확한 버전으로 고정하고 올릴 때마다 `CHANGELOG.md` 에 기록한다. 네트워크가 차단된 CI 에서는 plugin 다운로드가 실패할 수 있음을 README 에 명시한다.

**`ref: main` 으로 소비하도록 안내:**
- Risk: `README.md:28-31`, `:39-42` 는 git 의존성을 `ref: main` 으로 추가하라고 안내한다. git tag 는 하나도 없다. `main` 에 push 된 내용이 `flutter pub upgrade` 시점에 모든 사용 프로젝트에 그대로 들어간다.
- Files: `README.md`, `pubspec.yaml`
- Current mitigation: 사용 프로젝트의 `pubspec.lock` 이 resolved commit 을 고정한다(upgrade 전까지).
- Recommendations: 릴리스마다 `v1.3.0` 형식의 tag 를 만들고 README 를 `ref: v1.3.0` 으로 안내한다.

**전역 `invalid_annotation_target: ignore`:**
- Risk: freezed / json_serializable 사용을 위한 설정이지만 모든 사용 프로젝트의 모든 파일에 적용되어, 잘못된 위치에 붙은 annotation 을 실제 실수인 경우에도 감춘다.
- Files: `lib/analysis_options.yaml:43-44`
- Current mitigation: 없음.
- Recommendations: 보안 취약점은 아니며 진단 누락 위험이다. README 에 이 무시 설정을 명시하고, 필요 없는 프로젝트가 자신의 `analysis_options.yaml` 에서 되돌리는 방법을 안내한다.

**비밀 정보:** `.env`, credential, key 파일은 검출되지 않음. 하드코딩된 비밀 없음.

## Performance Bottlenecks

**Riverpod 미사용 프로젝트에도 plugin 로드 강제:**
- Problem: 이 설정을 include 하는 모든 프로젝트가 Riverpod 사용 여부와 무관하게 riverpod_lint plugin 을 내려받고 로드한다.
- Files: `lib/analysis_options.yaml:57-58`
- Cause: plugin 선언이 단일 배포 파일에 무조건 포함되어 있고 선택(opt-in) 수단이 없다.
- Improvement path: 배포 파일을 둘로 나눈다 — 규칙만 담은 `lib/analysis_options.yaml` 과, 이를 include 하고 `plugins:` 를 더한 `lib/riverpod.yaml`. 단, 최상위 `plugins:` 가 include 된 파일 안에서 어떻게 취급되는지(`plugins_in_inner_options`)를 대상 Dart 버전에서 먼저 검증해야 한다. 실제 분석 시간 영향은 측정하지 않았다.

## Fragile Areas

**배포 파일이 자체 분석에서 제외됨:**
- Files: `analysis_options.yaml:7-9`, `lib/analysis_options.yaml`
- Why fragile: 유일한 산출물인 `lib/analysis_options.yaml` 이 이 저장소의 analyzer 대상에서 빠져 있다. 규칙 이름 오타, 제거/폐기(deprecated)된 규칙, 서로 충돌하는 규칙, YAML 구조 오류가 이 저장소 안에서는 검출되지 않고 사용 프로젝트에서 처음 드러난다.
- Safe modification: 변경 후 실제 Flutter 프로젝트에서 `path:` 의존성으로 이 패키지를 걸고 `dart analyze` 를 실행해 옵션 파일 경고가 없는지 확인한 뒤 push 한다.
- Test coverage: 없음.

**최상위 `plugins:` 의 SDK 의존성:**
- Files: `lib/analysis_options.yaml:49-58`, `pubspec.yaml:10-11`
- Why fragile: 최상위 `plugins:` 방식은 Dart 3.10 이상에서만 동작하며 riverpod_lint 3.x 는 이 방식만 지원한다. `pubspec.yaml` 의 `sdk: ^3.10.4` 가 이를 간접적으로 강제하므로 더 낮은 Dart 를 쓰는 프로젝트는 이 패키지 버전을 해석할 수 없다. plugin 동작은 SDK 버전에 따라 달라진다(`flutter analyze` 진단 누락 사례).
- Safe modification: `plugins:` 섹션이나 SDK 제약을 바꿀 때는 지원하려는 최저/최신 Flutter 버전 양쪽에서 `dart analyze` 로 확인한다. 변경 후 IDE 의 Dart Analysis Server 재시작이 필요하다.
- Test coverage: 없음.

**plugin 버전과 사용 프로젝트 Riverpod 버전의 결합:**
- Files: `lib/analysis_options.yaml:58`
- Why fragile: riverpod_lint `^3.1.3` 이 사용 프로젝트의 `pubspec.lock` 과 별도로 해석되므로, 프로젝트가 쓰는 `riverpod` / `flutter_riverpod` 메이저 버전과 plugin 버전이 어긋날 수 있다. 어긋났을 때의 실제 동작은 확인하지 못했다.
- Safe modification: riverpod_lint 버전을 올릴 때 지원 Riverpod 버전 범위를 README 에 함께 적는다.
- Test coverage: 없음.

**모든 사용 프로젝트에 즉시 전파되는 변경:**
- Files: `lib/analysis_options.yaml`
- Why fragile: 규칙 하나를 켜면 `ref: main` 을 따르는 모든 프로젝트에 새 진단이 생긴다. `1.3.0` 은 그때까지 로드되지 않던 riverpod_lint 규칙을 처음 활성화했다(`CHANGELOG.md:4`).
- Safe modification: 규칙 추가/plugin 활성화는 minor 이상 버전으로 올리고 tag 로 배포한다.

## Scaling Limits

**단일 프리셋 구조:**
- Current capacity: 프리셋 1개(`lib/analysis_options.yaml`) — Flutter + Riverpod + freezed/json_serializable 조합을 전제로 한다.
- Limit: 순수 Dart 패키지, Riverpod 미사용 앱, 코드 생성 미사용 앱은 불필요한 plugin / exclude / 오류 무시를 함께 받는다.
- Scaling path: `lib/` 아래에 용도별 파일을 분리하고(예: 기본, riverpod, codegen) 사용 프로젝트가 필요한 것을 include 하도록 한다.

## Dependencies at Risk

**`riverpod_lint` (`^3.1.3`, `plugins:` 로 선언):**
- Risk: `pubspec.yaml` 의 의존성이 아니라 `pubspec.lock` 으로 추적되지 않는다. caret 범위라 해석 버전이 시점마다 달라진다(로컬 pub cache 에 3.1.0, 3.1.3, 3.1.4, 3.1.9 가 공존).
- Impact: 같은 커밋의 사용 프로젝트라도 머신/시점에 따라 진단 결과가 달라질 수 있다.
- Migration plan: 정확한 버전 고정 후 주기적으로 수동 갱신.

**`flutter_lints` (`^6.0.0`):**
- Risk: `dependencies` 에 있어 사용 프로젝트의 의존성 그래프에 전달된다. 사용 프로젝트가 다른 메이저의 `flutter_lints` 를 직접 선언하면 버전 해석 충돌이 난다. 기반 세트가 메이저 업데이트로 규칙을 추가/제거하면 이 패키지의 실질 규칙 집합이 함께 바뀐다.
- Impact: `pub get` 실패 또는 예고 없는 진단 변화.
- Migration plan: README 에 사용 프로젝트의 `flutter_lints` 직접 선언을 제거하도록 안내한다. `flutter_lints` 메이저를 올릴 때 릴리스 노트를 확인하고 `CHANGELOG.md` 에 기록한다.

## Missing Critical Features

**CI 부재:**
- Problem: `.github/workflows/` 등 CI 설정이 검출되지 않는다. 배포 파일의 유효성을 자동으로 확인하는 수단이 없다.
- Blocks: 잘못된 설정이 `main` 에 들어가는 것을 막을 수 없다.

**릴리스 tag 부재:**
- Problem: git tag 가 없다. `pubspec.yaml` 의 `version` 은 git 의존성 소비자에게 버전 선택 수단이 되지 못한다.
- Blocks: 사용 프로젝트가 특정 릴리스에 고정하거나 롤백할 수 없다(commit hash 직접 지정만 가능).

**LICENSE 파일 부재:**
- Problem: 공개 GitHub 저장소(`pubspec.yaml:8`)이나 LICENSE 파일이 없다.
- Blocks: 제3자의 사용 조건이 불명확하다. 개인 사용 목적(`publish_to: 'none'`)이면 우선순위는 낮다.

**규칙 재정의(override) 안내 부재:**
- Problem: `README.md` 에 사용 프로젝트가 특정 규칙을 끄거나 `analyzer.exclude` / `errors` 를 덮어쓰는 방법이 없다.
- Blocks: 프리셋이 맞지 않는 프로젝트가 부분 적용하기 어렵다.

## Test Coverage Gaps

**배포 설정에 대한 검증 전무:**
- What's not tested: `lib/analysis_options.yaml` 의 YAML 유효성, 규칙 이름의 실재 여부, 규칙 간 충돌, `plugins:` 로드 성공 여부, 지원 SDK 범위에서의 동작.
- Files: `lib/analysis_options.yaml`, `analysis_options.yaml`
- Risk: 오타나 폐기된 규칙이 포함되어도 사용 프로젝트에서 경고가 나기 전까지 알 수 없다. 테스트 디렉터리(`test/`)와 예제 프로젝트(`example/`)가 없다.
- Priority: High — 이 저장소의 유일한 산출물이다.
- 권장 접근: 규칙 위반/준수 샘플을 담은 최소 Flutter 프로젝트를 `example/` 에 두고 `include: package:woody_lints/analysis_options.yaml` 로 연결한 뒤, CI 에서 `dart analyze` 의 기대 진단을 확인한다.

**README 와 설정의 일치 검증 없음:**
- What's not tested: `README.md` 의 규칙 목록과 `lib/analysis_options.yaml` 의 활성 규칙 일치 여부.
- Files: `README.md`, `lib/analysis_options.yaml`
- Risk: 문서 drift 가 계속 누적된다(현재 2건 존재).
- Priority: Medium

---

*Concerns audit: 2026-10-11*
