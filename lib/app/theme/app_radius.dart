import 'package:flutter/widgets.dart';

abstract final class AppRadius {
  static const small = Radius.circular(12);
  static const medium = Radius.circular(16);
  static const large = Radius.circular(20);

  static const card = BorderRadius.all(large);
  static const control = BorderRadius.all(small);
}
