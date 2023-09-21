import 'package:avvento_radio/componets/app_constants.dart';
import 'package:avvento_radio/models/exploremodels/programs.dart';
import 'package:avvento_radio/widgets/explore_details_screen.dart';
import 'package:avvento_radio/widgets/label_place_holder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/services.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<dynamic> jobList = [];

  Future<void> readJson() async{
    final String response = await rootBundle.loadString('assets/temp.json');
    final data = await json.decode(response);

    setState(() {
      jobList = data['programs']
          .map((data) => Programs.fromJson(data)).toList();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    readJson();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      width: double.infinity,
      height: calculateHeight(context),
      child: Column(
        children: [
          const LabelPlaceHolder(title: AppConstants.missNot),
          const SizedBox(height: 20),
          Expanded(child: buildListView(context)),
          const Divider()
        ],
      ),
    );
  }

  double calculateHeight(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double widgetWidth = 1.2 * screenWidth;
    return widgetWidth * 9.0 / 16.0;
  }

  Widget buildListView(BuildContext context) {
    final int itemCount = jobList.length;
    const int maxItemsToDisplay = 5;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: itemCount <= maxItemsToDisplay ? itemCount : maxItemsToDisplay + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return buildFirstItem(context);
        } else if (index < maxItemsToDisplay) {
          return buildExploreDetailsScreen(jobList[index]);
        } else if (index == maxItemsToDisplay) {
          return buildShowMoreItem(context);
        } else {
          return const SizedBox.shrink(); // Return an empty SizedBox for any extra items
        }
      },
    );
  }

  Widget buildFirstItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: buildExploreDetailsScreen(jobList[0]),
    );
  }

  Widget buildExploreDetailsScreen(Programs explore) {
    return ExploreDetailsScreen(explore: explore);
  }

  Widget buildShowMoreItem(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle the "show more" action here
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0), // Adjust as needed
        child: CupertinoButton(
          padding: const EdgeInsets.all(8.0), // Adjust as needed
          child: Icon(
            CupertinoIcons.forward, // Cupertino "forward" icon
            size: 32,
            color: Theme.of(context).colorScheme.onPrimary, // Customize the color
          ),
          onPressed: () {
            // Handle the "show more" action here
          },
        ),
      ),
    );
  }

}
