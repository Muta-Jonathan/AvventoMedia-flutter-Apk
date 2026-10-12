import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Colours for the grouped settings list, matched to the More redesign.
class _SettingsColors {
  _SettingsColors(BuildContext context)
      : _dark = Theme.of(context).brightness == Brightness.dark;
  final bool _dark;

  Color get card => _dark ? const Color(0xFF221F33) : Colors.white;
  Color get separator => _dark
      ? Colors.white.withValues(alpha: 0.07)
      : Colors.black.withValues(alpha: 0.08);
  Color get header => _dark ? const Color(0xFF9E9CB0) : Colors.black54;
  Color get trailing => _dark ? const Color(0xFF6F6C85) : Colors.black38;
  Color get switchTrack => _dark ? const Color(0xFF3A3750) : Colors.black12;
}

/// Accent for switches and badges' default.
const Color settingsAccent = Color(0xFFFFB300);

/// A titled, rounded card of [SettingsTile]s with hairline separators.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.tiles});

  final String title;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    final colors = _SettingsColors(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 26, 4, 8),
          child: Text(
            title,
            style: TextStyle(
              color: colors.header,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.7,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ColoredBox(
            color: colors.card,
            child: Column(
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  if (i > 0)
                    Padding(
                      // Separator starts after the icon tile, iOS-style.
                      padding: const EdgeInsets.only(left: 60),
                      child: Divider(
                          height: 0.5, thickness: 0.5, color: colors.separator),
                    ),
                  tiles[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// One row: tinted icon tile, label, and a trailing element.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    this.onTap,
    this.external = false,
    this.showChevron = true,
    this.badge,
    this.value,
    this.trailing,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback? onTap;

  /// Opens outside the app: shows an arrow-out icon instead of a chevron.
  final bool external;
  final bool showChevron;

  /// Count pill (hidden when null or 0).
  final int? badge;

  /// Current choice, shown before the chevron (e.g. "30 days").
  final String? value;

  /// Replaces the default trailing (e.g. a switch or segmented control).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = _SettingsColors(context);
    final onSurface = Theme.of(context).colorScheme.onPrimary;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(label,
                    style: TextStyle(color: onSurface, fontSize: 15)),
              ),
              if ((badge ?? 0) > 0) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$badge',
                      style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
              ],
              if (value != null) ...[
                Text(value!,
                    style: TextStyle(color: colors.header, fontSize: 14)),
                const SizedBox(width: 6),
              ],
              if (trailing != null)
                trailing!
              else if (external)
                Icon(CupertinoIcons.arrow_up_right_square,
                    size: 16, color: colors.trailing)
              else if (showChevron)
                Icon(CupertinoIcons.chevron_forward,
                    size: 18, color: colors.trailing),
            ],
          ),
        ),
      ),
    );
  }
}

/// iOS-style switch in the settings accent.
class SettingsSwitch extends StatelessWidget {
  const SettingsSwitch(
      {super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeTrackColor: settingsAccent,
        inactiveTrackColor: _SettingsColors(context).switchTrack,
      );
}
