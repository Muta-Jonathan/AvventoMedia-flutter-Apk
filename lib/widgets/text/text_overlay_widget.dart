import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextOverlay extends StatelessWidget {
  final String label;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final bool allCaps;

  const TextOverlay({
    super.key,
    required this.label,
    this.fontSize = 12.0,
    required this.color,
    this.fontWeight = FontWeight.normal,
    this.allCaps = false,});

  @override
  Widget build(BuildContext context) {
    String displayLabel = allCaps ? label.toUpperCase() : label;
    return Padding(
      padding: const EdgeInsets.only(left: 5,bottom: 2),
      child: Text(
        displayLabel,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          ),
        ),
    );
  }
}
