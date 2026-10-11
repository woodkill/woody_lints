import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `async_value_nullable_pattern` — nullable 데이터를 가진 `AsyncValue` 에 `:final value?` 를 쓴다.
int? readNullable(Object object) {
  switch (object) {
    case AsyncValue<int?>(:final value?):
      return value;
  }
  return null;
}
