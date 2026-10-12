import 'package:avvento_media/themes/dark_theme.dart';
import 'package:avvento_media/themes/light_theme.dart';
import 'package:avvento_media/widgets/common/filter_chips_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<int?> pumpBar(WidgetTester tester, ThemeData theme,
      {int selected = 0}) async {
    int? tapped;
    await tester.pumpWidget(MaterialApp(
      theme: theme,
      home: Scaffold(
        body: FilterChipsBar(
          labels: const ['Catalog', 'Favorites', 'Playlists'],
          selected: selected,
          onSelected: (i) => tapped = i,
        ),
      ),
    ));
    await tester.tap(find.text('Playlists'));
    return tapped;
  }

  Color textColor(WidgetTester tester, String label) =>
      tester.widget<Text>(find.text(label)).style!.color!;

  testWidgets('reports the tapped chip', (tester) async {
    expect(await pumpBar(tester, darkTheme), 2);
  });

  testWidgets('selected chip is inverted, others readable, in dark mode',
      (tester) async {
    await pumpBar(tester, darkTheme);
    expect(textColor(tester, 'Catalog'), Colors.black);
    expect(textColor(tester, 'Favorites'), Colors.white);
  });

  testWidgets('selected chip is inverted, others readable, in light mode',
      (tester) async {
    await pumpBar(tester, lightTheme);
    expect(textColor(tester, 'Catalog'), Colors.white);
    expect(textColor(tester, 'Favorites'), isNot(Colors.white));
  });
}
