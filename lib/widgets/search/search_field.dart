import 'package:flutter/material.dart';

import '../../components/app_constants.dart';
import '../../themes/avvento_colors.dart';

/// Text style for a search field's text and hint: an even line box, so the
/// text sits in the middle of it.
TextStyle searchFieldStyle(Color color, double size) => TextStyle(
      color: color,
      fontSize: size,
      height: 1.25,
      fontWeight: FontWeight.w500,
      leadingDistribution: TextLeadingDistribution.even,
    );

/// Padding that makes a one-line field [height] tall with its text centred,
/// at any text size. Being that tall, the field itself is the tap target.
EdgeInsets searchFieldPadding(BuildContext context, double size,
    {double height = 45}) {
  final line = MediaQuery.textScalerOf(context).scale(size * 1.25);
  final vertical = ((height - line) / 2).clamp(0.0, height);
  return EdgeInsets.symmetric(vertical: vertical);
}

/// The 48dp search bar, with a clear button and, while it has focus, Cancel.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onCancel,
    this.hint = AppConstants.searchHint,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onCancel;
  final String hint;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return ListenableBuilder(
      listenable: Listenable.merge([controller, focusNode]),
      builder: (context, _) {
        final focused = focusNode.hasFocus;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.only(left: 14, right: 2),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: focused ? c.accent : c.line, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      ExcludeSemantics(
                          child: Icon(Icons.search_rounded,
                              size: 20, color: c.text3)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          autofocus: autofocus,
                          onChanged: onChanged,
                          onSubmitted: onSubmitted,
                          textInputAction: TextInputAction.search,
                          cursorColor: c.accent,
                          style: searchFieldStyle(c.text, 16),
                          decoration: InputDecoration(
                            isCollapsed: true,
                            contentPadding: searchFieldPadding(context, 16),
                            border: InputBorder.none,
                            hintText: hint,
                            hintStyle: searchFieldStyle(c.text3, 16),
                          ),
                        ),
                      ),
                      if (controller.text.isNotEmpty)
                        Semantics(
                          button: true,
                          label: AppConstants.clearSearch,
                          excludeSemantics: true,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              controller.clear();
                              onChanged('');
                            },
                            child: SizedBox.square(
                              dimension: 44,
                              child: Center(
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                      color: c.text3, shape: BoxShape.circle),
                                  child: Icon(Icons.close_rounded,
                                      size: 12, color: c.bg),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (focused)
                TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(44, 44),
                    foregroundColor: c.text2,
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  child: const Text(AppConstants.cancel),
                ),
            ],
          ),
        );
      },
    );
  }
}
