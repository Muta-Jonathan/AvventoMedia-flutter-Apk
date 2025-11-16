import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class TextOverlay extends StatelessWidget {
  final String? label;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final bool allCaps;
  final int maxLines;
  final bool underline;
  final TextAlign textAlign;

  const TextOverlay({
    super.key,
    required this.label,
    this.fontSize = 12.0,
    this.maxLines = 2,
    this.textAlign = TextAlign.left,
    required this.color,
    this.underline = false,
    this.fontWeight = FontWeight.normal,
    this.allCaps = false,});

  @override
  Widget build(BuildContext context) {
    String? displayLabel = allCaps ? label?.toUpperCase() : label;
    displayLabel = displayLabel?.replaceAll('/n', '\n\n');
    return Padding(
      padding: const EdgeInsets.only(left: 5,bottom: 2),
      child: Linkify(
        onOpen: (link) async {
          if (!await launchUrl(Uri.parse(link.url))) {
            throw Exception('Could not launch ${link.url}');
          }
        },
        text: displayLabel!,
        overflow: TextOverflow.ellipsis,
        maxLines: maxLines,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          decoration: underline ? TextDecoration.underline : TextDecoration.none,
          decorationColor: Colors.amber,
        ),
        options: const LinkifyOptions(humanize: true),
        linkStyle: const TextStyle(
            color: Colors.amber,
            fontStyle: FontStyle.italic
        ),
      )
    );
  }
}
