import 'package:avvento_radio/componets/app_constants.dart';
import 'package:avvento_radio/widgets/label_place_holder.dart';
import 'package:flutter/material.dart';

import '../../apis/fetch_spreaker_api.dart';
import '../../models/spreakermodels/spreaker_episodes.dart';
import 'audio_list_details_screen.dart';

class AudioListScreen extends StatefulWidget {
  const AudioListScreen({super.key});

  @override
  State<AudioListScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<AudioListScreen> {
  late Future<List<SpreakerEpisode>> spreakerList;

  @override
  void initState() {
    super.initState();
    spreakerList = FetchSpreakerAPI.fetchEpisodesForShow();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      width: double.infinity,
      height: 328,
      child: Column(
        children: [
          const SizedBox(height: 20),
          const LabelPlaceHolder(title: AppConstants.spreaker),
          const Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Divider(),
          ),
          Expanded(child: buildListView(context)),
          const Divider()
        ],
      ),
    );
  }

  Widget buildListView(BuildContext context) {
    return FutureBuilder<List<SpreakerEpisode>>(
      future: spreakerList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 3.0, // Adjust the stroke width as needed
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary), // Change the color here
            ),
          ); // Display a loading indicator while fetching data
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No data available'); // Handle the case where no data is available
        } else {
          final episodes = snapshot.data;
          return ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: episodes?.length,
            itemBuilder: (BuildContext context, int index) {
              return buildSpreakerDetailsScreen(episodes![index]);
            },
          );
        }
      },
    );
  }

  Widget buildSpreakerDetailsScreen(SpreakerEpisode spreakerEpisode) {
    return AudioListDetailsWidget(spreakerEpisode: spreakerEpisode);
  }
}

