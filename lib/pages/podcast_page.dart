import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:marquee/marquee.dart';

import '../controller/episode_controller.dart';

class PodcastPage extends StatefulWidget {
  const PodcastPage({Key? key}) : super(key: key);

  @override
  PodcastPageState createState() => PodcastPageState();
}

class PodcastPageState extends State<PodcastPage> {
  final EpisodeController episodeController = Get.find();
  @override
  Widget build(BuildContext context) {
    final selectedEpisode = episodeController.selectedEpisode.value;
    double screenWidth = MediaQuery.of(context).size.width;
    String publishedDate = Jiffy.parse(selectedEpisode!.publishedAt).yMMMMEEEEdjm;
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
                  text: selectedEpisode!.title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth / 19),
                  scrollAxis: Axis.horizontal,
                  blankSpace: screenWidth / 1.2,
                  velocity: 23.0, // Adjust the velocity to a lower value (e.g., 25.0)
                  pauseAfterRound: const Duration(seconds: 2),
                  startPadding: 0,
                  accelerationDuration: const Duration(seconds: 2),
                  accelerationCurve: Curves.linear,
                  decelerationDuration: const Duration(milliseconds: 500),
                  decelerationCurve: Curves.easeOut,
                ),
              ),
              Text(
                "Published on $publishedDate",
                style: TextStyle(
                  fontSize: screenWidth / 30,
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
