import 'package:avvento_media/themes/avvento_colors.dart';
import 'package:avvento_media/themes/dark_theme.dart';
import 'package:avvento_media/themes/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double contrast(Color fg, Color bg) {
  // Blend translucent colors over the background first.
  final f = Color.alphaBlend(fg, bg).computeLuminance();
  final b = bg.computeLuminance();
  final hi = f > b ? f : b;
  final lo = f > b ? b : f;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('existing themes expose the tokens', () {
    expect(darkTheme.extension<AvventoColors>(), AvventoColors.dark);
    expect(lightTheme.extension<AvventoColors>(), AvventoColors.light);
    expect(ThemeData.dark().avvento, AvventoColors.dark);
  });

  for (final (name, c) in [
    ('dark', AvventoColors.dark),
    ('light', AvventoColors.light),
  ]) {
    group('$name text contrast is at least 4.5:1', () {
      for (final bg in [c.bg, c.surface, c.surface2, c.mini]) {
        for (final (label, fg) in [
          ('text', c.text),
          ('text2', c.text2),
          ('text3', c.text3),
          ('accentText', c.accentText),
          ('liveText', c.liveText),
        ]) {
          test('$label on $bg', () {
            expect(contrast(fg, bg), greaterThanOrEqualTo(4.5));
          });
        }
      }
      test('onAccent on accent', () {
        expect(contrast(c.onAccent, c.accent), greaterThanOrEqualTo(4.5));
      });
      test('liveText on liveSoft', () {
        final tinted = Color.alphaBlend(c.liveSoft, c.bg);
        expect(contrast(c.liveText, tinted), greaterThanOrEqualTo(4.5));
      });
    });
  }

  test('lerp reaches both ends', () {
    expect(AvventoColors.dark.lerp(AvventoColors.light, 0).bg,
        AvventoColors.dark.bg);
    expect(AvventoColors.dark.lerp(AvventoColors.light, 1).bg,
        AvventoColors.light.bg);
  });
}
