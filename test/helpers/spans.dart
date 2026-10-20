import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The text of every span on screen that has a background, i.e. the words a
/// search marked.
List<String> markedWords(WidgetTester tester) {
  final marked = <String>[];
  for (final rich in tester.widgetList<RichText>(find.byType(RichText))) {
    rich.text.visitChildren((span) {
      if (span is TextSpan && span.style?.backgroundColor != null) {
        marked.add(span.text ?? '');
      }
      return true;
    });
  }
  return marked;
}
