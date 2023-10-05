import 'package:flutter/material.dart';

class LabelPlaceHolder extends StatelessWidget {
  final String title;
  final String moreLabel;
  final double titleFontSize;
  const LabelPlaceHolder({super.key, required this.title, this.titleFontSize = 15, this.moreLabel=''});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(title,
              style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: titleFontSize,
              ),
            ),
          ),
          Text(moreLabel,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue
            ),
          ),
        ],)
      );
  }
}
