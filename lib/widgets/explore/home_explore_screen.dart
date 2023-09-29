import 'package:avvento_radio/componets/app_constants.dart';
import 'package:avvento_radio/componets/utils.dart';
import 'package:avvento_radio/models/exploremodels/programs.dart';
import 'package:avvento_radio/widgets/explore/home_explore_details_screen.dart';
import 'package:avvento_radio/widgets/label_place_holder.dart';
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
          const Divider(),
        ],
      ),
    );
  }

  Widget buildListView(BuildContext context, ProgramsProvider programsProvider) {
    final int itemCount = programsProvider.jobList.length;
    const int maxItemsToDisplay = 5;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: itemCount <= maxItemsToDisplay ? itemCount : maxItemsToDisplay + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return buildFirstItem(context, programsProvider.jobList[0]);
        } else if (index < maxItemsToDisplay) {
          return buildExploreDetailsScreen(programsProvider.jobList[index]);
        } else if (index == maxItemsToDisplay) {
          return buildShowMoreItem(context);
        } else {
          return const SizedBox.shrink(); // Return an empty SizedBox for any extra items
        }
      },
    );
  }
  Widget buildFirstItem(BuildContext context, index) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: buildExploreDetailsScreen(index),
    );
  }

  Widget buildExploreDetailsScreen(Programs explore) {
    return HomeExploreDetailsScreen(explore: explore);
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
