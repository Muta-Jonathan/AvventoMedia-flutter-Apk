import 'package:avvento_radio/componets/app_constants.dart';
import 'package:avvento_radio/componets/utils.dart';
import 'package:avvento_radio/widgets/label_place_holder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'audio_list_details_screen.dart';

class AudioListScreen extends StatefulWidget {
  const AudioListScreen({super.key});

  @override
  State<AudioListScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<AudioListScreen> {

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      width: double.infinity,
      height: 328,
      child: Column(
        children: [
          const SizedBox(height: 20),
          const LabelPlaceHolder(title: AppConstants.spreaker, ),
          Padding(
            padding: const EdgeInsets.only(left: 20,right: 20),
            child: const Divider(),
          ),
          Expanded(child: buildListView(context)),
          const Divider()
        ],
      ),
    );
  }

  Widget buildListView(BuildContext context) {

    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: 10,
      itemBuilder: (BuildContext context, int index) {
        return const AudioListDetailsWidget();
      },
    );
  }

}
