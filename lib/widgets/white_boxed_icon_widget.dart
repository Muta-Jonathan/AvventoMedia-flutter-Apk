import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WhiteBoxedIcon extends StatelessWidget {
  const WhiteBoxedIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
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