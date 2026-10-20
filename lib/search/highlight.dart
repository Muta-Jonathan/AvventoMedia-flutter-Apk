import 'package:flutter/material.dart';

/// [text] as spans with every word of [query] marked, for showing why a row
/// matched. Case doesn't matter; with no query it is one plain span.
List<TextSpan> highlightSpans(
  String text,
  String query, {
  required TextStyle style,
  required Color background,
}) {
  final words = query
      .trim()
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .map(RegExp.escape)
      .toList()
    // Longest first, so "daniel" wins over "dan".
    ..sort((a, b) => b.length.compareTo(a.length));
  if (words.isEmpty) return [TextSpan(text: text, style: style)];

  final pattern = RegExp('(${words.join('|')})', caseSensitive: false);
  final spans = <TextSpan>[];
  var from = 0;
  for (final m in pattern.allMatches(text)) {
    if (m.start > from) {
      spans.add(TextSpan(text: text.substring(from, m.start), style: style));
    }
    spans.add(TextSpan(
        text: m.group(0), style: style.copyWith(backgroundColor: background)));
    from = m.end;
  }
  if (from < text.length) {
    spans.add(TextSpan(text: text.substring(from), style: style));
  }
  return spans;
}
