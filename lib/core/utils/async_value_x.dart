import 'package:flutter_riverpod/flutter_riverpod.dart';

extension AsyncValueX<T> on AsyncValue<T> {
  /// Safe value access compatible with Riverpod 3.
  T? get valueOrNull => asData?.value;
}
