import 'package:flutter/material.dart';

import '../../themes/avvento_colors.dart';

/// "Presenters" with an optional accent action ("See all") on the right;
/// the action is a 44dp target.
class ListenSectionHeader extends StatelessWidget {
  const ListenSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 2),
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title,
                  style: TextStyle(
                      color: c.text,
                      fontSize: 18,
                      height: 24 / 18,
                      fontWeight: FontWeight.w700)),
            ),
          ),
          if (action != null)
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onAction,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
                child: Align(
                  alignment: Alignment.centerRight,
                  widthFactor: 1,
                  child: Text(action!,
                      style: TextStyle(
                          color: c.accentText,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
