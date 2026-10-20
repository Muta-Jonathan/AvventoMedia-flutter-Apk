import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/themes/dark_theme.dart';
import 'package:avvento_media/themes/light_theme.dart';
import 'package:avvento_media/widgets/search/search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, ThemeData theme,
      {double scale = 1}) async {
    await tester.pumpWidget(MaterialApp(
      theme: theme,
      home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Scaffold(
          body: SearchField(
            controller: TextEditingController(),
            focusNode: FocusNode(),
            onChanged: (_) {},
            onSubmitted: (_) {},
            onCancel: () {},
          ),
        ),
      ),
    ));
    await tester.pump();
  }

  for (final (name, theme) in [('dark', darkTheme), ('light', lightTheme)]) {
    for (final scale in [1.0, 1.3]) {
      testWidgets('hint, icon and bar share one centre line ($name, ${scale}x)',
          (tester) async {
        await pump(tester, theme, scale: scale);

        final bar = tester.getRect(find.byType(SearchField));
        final icon = tester.getCenter(find.byIcon(Icons.search_rounded)).dy;
        final hint = tester.getCenter(find.text(AppConstants.searchHint)).dy;

        expect(hint, closeTo(icon, 1), reason: 'hint vs icon');
        // The bar has 12dp above it.
        expect(hint, closeTo(bar.top + 12 + 24, 1.5), reason: 'hint vs bar');
      });
    }
  }

  testWidgets('typed text sits on the same line as the hint', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(MaterialApp(
      theme: darkTheme,
      home: Scaffold(
        body: SearchField(
          controller: controller,
          focusNode: FocusNode(),
          onChanged: (_) {},
          onSubmitted: (_) {},
          onCancel: () {},
        ),
      ),
    ));
    final hintY = tester.getCenter(find.text(AppConstants.searchHint)).dy;
    await tester.enterText(find.byType(TextField), 'Daniel');
    await tester.pump();

    expect(tester.getCenter(find.text('Daniel')).dy, closeTo(hintY, 1));
  });
}
