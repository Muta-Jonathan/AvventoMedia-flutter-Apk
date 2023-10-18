import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextOverlay extends StatelessWidget {
  final String label;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final bool allCaps;
  final int maxLines;
  final bool underline;

  const TextOverlay({
    super.key,
    required this.label,
    this.fontSize = 12.0,
    this.maxLines = 2,
    required this.color,
    this.underline = false,
    this.fontWeight = FontWeight.normal,
    this.allCaps = false,});

  @override
  Widget build(BuildContext context) {
    String displayLabel = allCaps ? label.toUpperCase() : label;
    return Padding(
      padding: const EdgeInsets.only(left: 5,bottom: 2),
      child: Text(
        displayLabel,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
            decoration: underline ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
    );
  }
}
