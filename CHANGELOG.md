## 2.0.0 - 미출시

지원 SDK: Dart 3.13 이상 (이전: Dart 3.10.4 이상)

### 올리기 전에

- Dart 3.13 미만(Flutter 3.47 미만)을 쓰는 프로젝트는 `ref: v1.3.0` 에 머문다.
- 옛 주소 한 줄을 쓰는 프로젝트는 고칠 것이 없다. 새 프로젝트는 `package:woody_lints/recommended.yaml` 을 include 한다.

### 그 밖의 변경

- 저장소 안에 검증용 연습 프로젝트 여섯(`example/` 과 `fixtures/` 다섯), 검증 명령 `tool/verify.dart`, GitHub Actions workflow 를 추가. 사용하는 프로젝트에는 영향 없음.
- 프리셋을 조각 셋과 묶음으로 나눔 — `package:woody_lints/base.yaml` (기본 규칙), `riverpod.yaml` (`riverpod_lint` plugin), `codegen.yaml` (생성 파일 제외와 `invalid_annotation_target: ignore`), `recommended.yaml` (셋을 한 번에). 규칙 · 주석 · 설정은 옮기기만 했고 내용은 1.3.0 과 같다 (minor — 새 프리셋 파일 추가).
- 옛 주소 `package:woody_lints/analysis_options.yaml` 은 `recommended.yaml` 을 include 하는 별칭으로 남긴다 — 그 한 줄을 쓰는 프로젝트가 받는 구성(기본 + Riverpod + codegen)은 같다. 사용하는 프로젝트에는 영향 없음.
- 저장소 자체 분석용 루트 `analysis_options.yaml` 의 `lib/analysis_options.yaml` 제외를 걷어냄 — 나눈 뒤에는 그 파일에 `plugins:` 가 없어 `plugins_in_inner_options` 가 나지 않는다 (Dart 3.13.4). 사용하는 프로젝트에는 영향 없음.

### 새로 생기는 경고

(Phase 4 실측 후 채움)

## 1.3.0

- riverpod_lint 를 최상위 `plugins:` (analysis_server_plugin) 방식으로 전환.
  - 옛 `analyzer: plugins: - riverpod_lint` 선언은 riverpod_lint 3.x 에서 아무것도 로드하지 않아 규칙이 실행된 적이 없었다 → 이번 버전부터 riverpod_lint 규칙이 처음으로 켜진다.
  - Dart 3.13 (Flutter 3.47) 의 `included_file_warning` (legacy plugin deprecated) 해소.
- `flutter_lints` 를 `dev_dependencies` → `dependencies` 로 이동. `include: package:flutter_lints/flutter.yaml` 이 사용하는 프로젝트의 직접 의존 여부와 무관하게 해석된다.
- 저장소 자체 분석용 루트 `analysis_options.yaml` 추가 — `lib/analysis_options.yaml` 의 `plugins:` 가 이 저장소 안에서는 inner 옵션으로 취급되어 나는 `plugins_in_inner_options` 경고를 제외한다. 사용하는 프로젝트에는 영향 없음.

## 1.0.0

- Initial version.
