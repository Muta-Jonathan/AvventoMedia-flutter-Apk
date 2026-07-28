import 'package:flutter/material.dart';

class TvSectionShelf extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final List<Widget> children;
  final double height;

  const TvSectionShelf({
    super.key,
    required this.title,
    this.trailing,
    required this.children,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
        // Horizontal Scrollable Shelf
        SizedBox(
          height: height,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: children.length,
            itemBuilder: (context, index) {
              return children[index];
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
