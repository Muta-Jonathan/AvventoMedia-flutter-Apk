import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider_widget.dart';

class CustomListTile extends StatefulWidget {
  final String label;
  final IconData leadingIcon;
  final bool isSwitch;
  final Function(bool)? onSwitchChanged;

  const CustomListTile({
    Key? key,
    required this.label,
    required this.leadingIcon,
    required this.isSwitch,
    this.onSwitchChanged,
  }) : super(key: key);

  @override
  _CustomListTileState createState() => _CustomListTileState();
}

class _CustomListTileState extends State<CustomListTile> {
  late bool _isSwitchOn;

  @override
  void initState() {
    super.initState();
    _isSwitchOn = true;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.themeData.brightness == Brightness.dark;
    return ListTile(
      leading: Icon(widget.leadingIcon, size: 30),
      title: TextOverlay(
        label: widget.label,
        color: Theme.of(context).colorScheme.onPrimary,
        fontSize: 14,
      ),
      trailing: widget.isSwitch
          ? Switch.adaptive(
        value: isDarkMode,
        activeColor: Colors.orange,
        onChanged: (value) {
          setState(() {
            // widget.onSwitchChanged?.call(value);
            themeProvider.toggleTheme();
          });
        },
      )
          : Icon(CupertinoIcons.chevron_forward), // Change this icon as needed
      onTap: widget.isSwitch
          ? null // Disable onTap when the switch is enabled
          : () {
        if (!_isSwitchOn) {
          widget.onSwitchChanged?.call(true);
        }
      },
    );
  }
}


