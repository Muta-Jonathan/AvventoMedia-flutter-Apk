import 'dart:math';

import 'package:avvento_media/componets/app_constants.dart';
import 'package:avvento_media/componets/utils.dart';
import 'package:avvento_media/models/exploremodels/programs.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:avvento_media/widgets/explore/home_explore_details_screen.dart';
import 'package:avvento_media/widgets/text/label_place_holder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/programs_provider.dart';

class HomeExploreScreen extends StatefulWidget {
  const HomeExploreScreen({super.key});

  @override
  State<HomeExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<HomeExploreScreen> {
  int itemsToDisplay = 5;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final programsProvider = Provider.of<ProgramsProvider>(context, listen: false);
    try {
      await programsProvider.fetchData();
    } catch (e) {
      // Handle error gracefully
    }
  }

  @override
  Widget build(BuildContext context) {
    final programsProvider = Provider.of<ProgramsProvider>(context);

    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      width: double.infinity,
      height: Utils.calculateAspectHeight(context, 1.2),
      child: Column(
        children: [
          const LabelPlaceHolder(title: AppConstants.missNot),
          const SizedBox(height: 20),
          Expanded(child: buildListView(context, programsProvider)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildListView(BuildContext context, ProgramsProvider programsProvider) {
    final int itemCount = programsProvider.jobList.length;

    if (itemCount > 0) {
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount > 0 ? min(itemsToDisplay, itemCount) + 1 : 0,
        itemBuilder: (BuildContext context, int index) {
          if (index < min(itemsToDisplay, itemCount)) {
            return buildExploreDetailsScreen(programsProvider.jobList[index]);
          } else if (index == min(itemsToDisplay, itemCount)) {
            return itemCount > itemsToDisplay ? buildShowMoreItem(context) : const SizedBox.shrink();
          } else {
            return const SizedBox.shrink();
          }
        },
      );
    } else {
      return const LoadingWidget();
    }
  }

  Widget buildExploreDetailsScreen(Programs explore) {
    return HomeExploreDetailsScreen(explore: explore);
  }

  Widget buildShowMoreItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0), // Adjust as needed
      child: CupertinoButton(
        padding: const EdgeInsets.all(12.0), // Adjust as needed
        child: CircleAvatar(
          radius: 24, // Adjust the radius to fit the icon size
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          child: const Icon(
            CupertinoIcons.forward, // Cupertino "forward" icon
            size: 24,
            color: Colors.white, // Customize the color
          ),
        ),
        onPressed: () {
          // Increment the number of items to display when "Show More" is clicked
          setState(() {
            itemsToDisplay += 5;
          });
        },
      ),
    );
  }

}
