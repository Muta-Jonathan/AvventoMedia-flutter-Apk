import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomListTile extends StatefulWidget {
  final String label;
  final IconData leadingIcon;
  final bool isSwitch;
  final Function(bool)? onSwitchChanged;
  final VoidCallback? onTap;

  const CustomListTile({
    super.key,
    required this.label,
    required this.leadingIcon,
    required this.isSwitch,
    this.onSwitchChanged,
    this.onTap,
  });

  @override
  CustomListTileState createState() => CustomListTileState();
}
class CustomListTileState extends State<CustomListTile> {
  late bool _isSwitchOn;

  @override
  void initState() {
    super.initState();
    _isSwitchOn = true;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(widget.leadingIcon, size: 30,color: Theme.of(context).colorScheme.onSecondaryContainer),
      title: TextOverlay(
        label: widget.label,
        color: Theme.of(context).colorScheme.onPrimary,
        fontSize: 14,
      ),
      trailing: widget.isSwitch
          ? Switch.adaptive(
        value: _isSwitchOn,
        activeColor: Colors.amber,
        onChanged: (value) {
          setState(() {
            widget.onSwitchChanged?.call(value);
          });
        },
      )
          : Icon(
          CupertinoIcons.chevron_forward,
          color: Theme.of(context).colorScheme.onSecondaryContainer), // Change this icon as needed
      onTap: widget.isSwitch
          ? null // Disable onTap when the switch is enabled
          : widget.onTap,
    );
  }
}


