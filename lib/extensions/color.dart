import 'dart:ui';

extension Colorx on Color {
  String get hexCode => value.toRadixString(16).padLeft(8, '0').toUpperCase();
}
