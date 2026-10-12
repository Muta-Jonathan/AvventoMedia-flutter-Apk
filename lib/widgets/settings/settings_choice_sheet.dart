import 'package:flutter/material.dart';

/// Bottom sheet with a title, an explanation and radio options, for
/// settings rows such as Dark Mode and Remove played episodes.
class SettingsChoiceSheet {
  /// [options] maps each value to its label, in display order.
  static Future<void> show<T>(
    BuildContext context, {
    required String title,
    required String message,
    required Map<T, String> options,
    required T selected,
    required ValueChanged<T> onChanged,
  }) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final sheet = dark ? const Color(0xFF221F33) : Colors.white;
    final card = dark ? const Color(0xFF2A2740) : Colors.grey[100]!;
    final titleColor = dark ? Colors.white : const Color(0xFF161424);
    final messageColor = dark ? const Color(0xFF9E9CB0) : Colors.black54;
    final idle = dark ? const Color(0xFF6F6C85) : Colors.black26;
    final selectedText =
        dark ? const Color(0xFFFFCA28) : const Color(0xFFB26A00);
    const accent = Color(0xFFFFB300);

    return showModalBottomSheet(
      context: context,
      backgroundColor: sheet,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(title,
                    style: TextStyle(
                        color: titleColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
                child: Text(message,
                    style: TextStyle(
                        color: messageColor, fontSize: 13, height: 1.5)),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: ColoredBox(
                  color: card,
                  child: Column(children: [
                    for (final option in options.keys) ...[
                      if (option != options.keys.first)
                        Divider(
                            height: 0.5,
                            thickness: 0.5,
                            color: idle.withValues(alpha: 0.3)),
                      _Option(
                        label: options[option]!,
                        selected: option == selected,
                        textColor: titleColor,
                        selectedTextColor: selectedText,
                        idleColor: idle,
                        accent: accent,
                        onTap: () {
                          onChanged(option);
                          Navigator.pop(sheetContext);
                        },
                      ),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.label,
    required this.selected,
    required this.textColor,
    required this.selectedTextColor,
    required this.idleColor,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color textColor;
  final Color selectedTextColor;
  final Color idleColor;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        inMutuallyExclusiveGroup: true,
        checked: selected,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(children: [
                Expanded(
                  child: Text(label,
                      style: TextStyle(
                          color: selected ? selectedTextColor : textColor,
                          fontSize: 15)),
                ),
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: selected ? accent : idleColor, width: 2),
                  ),
                  child: selected
                      ? Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              color: accent, shape: BoxShape.circle))
                      : null,
                ),
              ]),
            ),
          ),
        ),
      );
}
