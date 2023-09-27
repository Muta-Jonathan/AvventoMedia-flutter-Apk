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
        body: Center(
      child: Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Cached Network Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              selectedEpisode.imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // Top Left Container with Stream Icon and Text
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.live_tv,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'LIVE',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Progress Bar with Time
          Positioned(
            bottom: 1,
            left: 1,
            right: 1,
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: 0.6, // Adjust the playback progress value
                  backgroundColor: Colors.grey,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '0:30', // Current time
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      '2:00', // Total duration
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom Container with Glass-like Background
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      // Implement the action for the download button
                    },
                    icon: Icon(Icons.file_download, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {
                      // Implement the action for the play button
                    },
                    icon: Icon(Icons.play_arrow, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () {
                      // Implement the action for the volume button
                    },
                    icon: Icon(Icons.volume_up, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    ),
    );
  }
}
