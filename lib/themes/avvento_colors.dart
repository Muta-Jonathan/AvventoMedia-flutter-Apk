import 'package:flutter/material.dart';

/// Brand color tokens. Read with `Theme.of(context).extension<AvventoColors>()!`
/// or the [AvventoColorsX.avvento] shorthand.
@immutable
class AvventoColors extends ThemeExtension<AvventoColors> {
  const AvventoColors({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.line,
    required this.text,
    required this.text2,
    required this.text3,
    required this.accent,
    required this.accentText,
    required this.onAccent,
    required this.accentSoft,
    required this.liveDot,
    required this.liveText,
    required this.liveSoft,
    required this.nav,
    required this.mini,
    required this.skeleton,
  });

  final Color bg;
  final Color surface;
  final Color surface2;
  final Color line;
  final Color text;
  final Color text2;
  final Color text3;
  final Color accent;

  /// Accent used for text; darker in light mode to keep 4.5:1 contrast.
  final Color accentText;
  final Color onAccent;
  final Color accentSoft;
  final Color liveDot;
  final Color liveText;
  final Color liveSoft;
  final Color nav;
  final Color mini;
  final Color skeleton;

  static const dark = AvventoColors(
    bg: Color(0xFF0E1222),
    surface: Color(0xFF171C30),
    surface2: Color(0xFF232943),
    line: Color(0x17FFFFFF), // white 9%
    text: Color(0xFFF5F2EA),
    text2: Color(0xFFBDBBC9),
    text3: Color(0xFF9593A8),
    accent: Color(0xFFF2B705),
    accentText: Color(0xFFF2B705),
    onAccent: Color(0xFF1B1500),
    accentSoft: Color(0x29F2B705), // accent 16%
    liveDot: Color(0xFFFF5A5F),
    liveText: Color(0xFFFF9A9D),
    liveSoft: Color(0x29FF5A5F), // liveDot 16%
    nav: Color(0xFF0B0E1B),
    mini: Color(0xFF1D2238),
    skeleton: Color(0xFF1F2440),
  );

  static const light = AvventoColors(
    bg: Color(0xFFFAF7F1),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF0EADF),
    line: Color(0x1A1A1D2B), // text 10%
    text: Color(0xFF1A1D2B),
    text2: Color(0xFF4B4D5E),
    text3: Color(0xFF676979),
    accent: Color(0xFFF2B705),
    // Spec #8A6500 is 4.45:1 on surface2; nudged darker to pass 4.5:1.
    accentText: Color(0xFF876300),
    onAccent: Color(0xFF1B1500),
    accentSoft: Color(0x2EF2B705), // accent 18%
    liveDot: Color(0xFFD6282E),
    liveText: Color(0xFFB3161C),
    liveSoft: Color(0x1AD6282E), // liveDot 10%
    nav: Color(0xFFFFFFFF),
    mini: Color(0xFFFFFFFF),
    skeleton: Color(0xFFECE5D8),
  );

  @override
  AvventoColors copyWith({
    Color? bg,
    Color? surface,
    Color? surface2,
    Color? line,
    Color? text,
    Color? text2,
    Color? text3,
    Color? accent,
    Color? accentText,
    Color? onAccent,
    Color? accentSoft,
    Color? liveDot,
    Color? liveText,
    Color? liveSoft,
    Color? nav,
    Color? mini,
    Color? skeleton,
  }) {
    return AvventoColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      line: line ?? this.line,
      text: text ?? this.text,
      text2: text2 ?? this.text2,
      text3: text3 ?? this.text3,
      accent: accent ?? this.accent,
      accentText: accentText ?? this.accentText,
      onAccent: onAccent ?? this.onAccent,
      accentSoft: accentSoft ?? this.accentSoft,
      liveDot: liveDot ?? this.liveDot,
      liveText: liveText ?? this.liveText,
      liveSoft: liveSoft ?? this.liveSoft,
      nav: nav ?? this.nav,
      mini: mini ?? this.mini,
      skeleton: skeleton ?? this.skeleton,
    );
  }

  @override
  AvventoColors lerp(AvventoColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AvventoColors(
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      surface2: l(surface2, other.surface2),
      line: l(line, other.line),
      text: l(text, other.text),
      text2: l(text2, other.text2),
      text3: l(text3, other.text3),
      accent: l(accent, other.accent),
      accentText: l(accentText, other.accentText),
      onAccent: l(onAccent, other.onAccent),
      accentSoft: l(accentSoft, other.accentSoft),
      liveDot: l(liveDot, other.liveDot),
      liveText: l(liveText, other.liveText),
      liveSoft: l(liveSoft, other.liveSoft),
      nav: l(nav, other.nav),
      mini: l(mini, other.mini),
      skeleton: l(skeleton, other.skeleton),
    );
  }
}

extension AvventoColorsX on ThemeData {
  /// Falls back by brightness so it never throws on a theme without the extension.
  AvventoColors get avvento =>
      extension<AvventoColors>() ??
      (brightness == Brightness.dark
          ? AvventoColors.dark
          : AvventoColors.light);
}
