import 'package:flutter/material.dart';

import '../../themes/avvento_colors.dart';

/// One short message and one action, for a rail that couldn't load.
class InlineNotice extends StatelessWidget {
  const InlineNotice({
    super.key,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.fromLTRB(14, 4, 6, 4),
      decoration: BoxDecoration(
          color: c.surface2, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Expanded(
            child: Text(message,
                style: TextStyle(
                    color: c.text2,
                    fontSize: 13,
                    height: 19 / 13,
                    fontWeight: FontWeight.w500)),
          ),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
                minimumSize: const Size(44, 44),
                foregroundColor: c.accentText,
                textStyle:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
