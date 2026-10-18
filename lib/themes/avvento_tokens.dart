import 'package:flutter/widgets.dart';

/// Spacing scale for the redesigned screens.
abstract final class AvventoSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Horizontal page margin.
  static const double page = 20;
  static const EdgeInsets pageInsets = EdgeInsets.symmetric(horizontal: page);

  /// Minimum tap target, even where the visual is smaller.
  static const double minTap = 44;
}

abstract final class AvventoRadii {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 24;
  static const double pill = 999;
}
