import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BoxedIcon extends StatelessWidget {
  final Color backgroundColor;
  const BoxedIcon({super.key, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:  BorderRadius.circular(5.0),
      ),
      child: const Padding(
        padding: EdgeInsets.all(2),
        child: Icon(
          size: 20.5,
          CupertinoIcons.mic,
          color: Color.fromARGB(255, 22, 20, 36), //rgba(22,20,36,255),
        ),
      ),
    );
  }
}