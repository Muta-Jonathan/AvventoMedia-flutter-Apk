import 'package:flutter/material.dart';

/// Horizontally scrolling, single-select pill chips (YouTube-style).
class FilterChipsBar extends StatelessWidget {
  const FilterChipsBar({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  static const double height = 52;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    // Selected: inverted (light on dark, dark on light), as in YouTube.
    final selectedBg = dark ? Colors.white : const Color(0xFF161424);
    final selectedFg = dark ? Colors.black : Colors.white;
    final idleBg = dark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.06);
    final idleFg = dark ? Colors.white : const Color(0xFF161424);

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isSelected = i == selected;
          return Semantics(
            button: true,
            selected: isSelected,
            child: Material(
              color: isSelected ? selectedBg : idleBg,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onSelected(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Center(
                    child: Text(
                      labels[i],
                      style: TextStyle(
                        color: isSelected ? selectedFg : idleFg,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
