import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

import '../componets/app_constants.dart';

class ListenPage extends StatefulWidget {
  const ListenPage({Key? key}) : super(key: key);

  @override
  ListenPageState createState() => ListenPageState();
}

class ListenPageState extends State<ListenPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
              width: double.infinity,
              child: Marquee(
                text: 'Some sample text e.',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                scrollAxis: Axis.horizontal,
                blankSpace: 120.0,
                velocity: 25.0, // Adjust the velocity to a lower value (e.g., 25.0)
                pauseAfterRound: const Duration(seconds: 2),
                startPadding: 0,
                accelerationDuration: const Duration(seconds: 2),
                accelerationCurve: Curves.linear,
                decelerationDuration: const Duration(milliseconds: 500),
                decelerationCurve: Curves.easeOut,
              ),
            ),
            const Text(
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
      body: const Column(
        children: [
          Divider(),

        ],
      )
    );
  }
}
