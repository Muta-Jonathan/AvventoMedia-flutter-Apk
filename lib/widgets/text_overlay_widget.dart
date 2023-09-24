import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextOverlay extends StatelessWidget {
  final String label;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  const TextOverlay({super.key, required this.label, this.fontSize = 12.0, required this.color, this.fontWeight = FontWeight.normal,});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5,bottom: 2),
      child: Text(
          label,
          maxLines: 3,
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
