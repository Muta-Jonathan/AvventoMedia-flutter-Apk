import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

import '../componets/app_constants.dart';

class ListenPage extends StatefulWidget {
  const ListenPage({Key? key}) : super(key: key);

  @override
  _ListenPageState createState() => _ListenPageState();
}

class _ListenPageState extends State<ListenPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 30,
              width: double.infinity,
              child: Marquee(
                text: 'Some sample text e.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                scrollAxis: Axis.horizontal,
                blankSpace: 120.0,
                velocity: 25.0, // Adjust the velocity to a lower value (e.g., 25.0)
                pauseAfterRound: Duration(seconds: 2),
                startPadding: 0,
                accelerationDuration: Duration(seconds: 2),
                accelerationCurve: Curves.linear,
                decelerationDuration: Duration(milliseconds: 500),
                decelerationCurve: Curves.easeOut,
              ),
            ),
            Text(
              AppConstants.missNot,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: Column(
        children: [
          Divider(),

        ],
      )
    );
  }
}
