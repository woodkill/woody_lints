<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages). 
-->

Flutter 프로젝트의 코드 품질 향상, 성능 최적화, 그리고 유지보수 편의성을 위해 엄선된 최적의 린트(Lint) 규칙 세트

## 핵심가치

이 규칙 세트는 다음 세 가지 핵심 가치에 집중:
- 성능(Performance): 불필요한 리빌드를 방지. 메모리 효율 최적화.
- 안정성(Bug Prevention): 런타임 에러와 논리적 오류를 컴파일 단계에서 포착.
- 가독성(Readability): 누구나 쉽게 읽을 수 있는 명확한 코드 지향.

## 사용법

1. 새로운 Flutter 프로젝트의 pubspec.yaml 파일에 이 저장소를 추가.

```
dev_dependencies:
  flutter_test:
    sdk: flutter
  woody_lints:
    git:
      url: https://github.com/woodkill/woody_lints.git
      ref: main
```

2. 터미널에서 패키지를 가져옵니다

```
flutter pub get
```

3. 프로젝트 루트 폴더에 있는 analysis_options.yaml 파일을 열고 다음과 같이 한 줄을 추가합니다.

```
include: package:woody_lints/analysis_options.yaml
```

## 포함된 규칙 목록

- 성능 최적화
    - prefer_const_constructors: 위젯 재사용을 극대화하여 성능 향상
    - prefer_const_literals_to_create_immutables: 불변 컬렉션의 효율적 관리
    - sized_box_for_whitespace: 가벼운 여백 위젯 사용 권장

- 코드 스타일 및 유지보수
    - always_declare_return_types: 함수의 명확한 의도 파악
    - sort_child_properties_last: 위젯 트리 구조 시각화 개선
    - prefer_final_locals: 데이터의 불변성 보장
    - require_trailing_commas: 자동 코드 정렬 최적화
    - prefer_single_quotes: 홑따옴표('') 사용 통일

- 버그 방지 및 안전성
    - use_build_context_synchronously: 비동기 작업 시 잘못된 Context 참조 방지 (매우 중요)
    - unawaited_futures: 처리되지 않은 Future 감지
    - avoid_print: 실 서비스 앱에서 불필요한 로그 노출 방지
    - control_flow_in_finally: finally 블록 내 제어문 사용 금지