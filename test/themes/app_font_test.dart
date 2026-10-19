import 'package:avvento_media/themes/avvento_theme.dart';
import 'package:avvento_media/themes/dark_theme.dart';
import 'package:avvento_media/themes/light_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('both app themes use Figtree', () {
    for (final theme in [darkTheme, lightTheme]) {
      expect(theme.textTheme.bodyMedium?.fontFamily, AvventoTheme.figtree);
      expect(theme.textTheme.titleLarge?.fontFamily, AvventoTheme.figtree);
    }
  });
}
