import 'package:avvento_radio/componets/app_constants.dart';
import 'package:avvento_radio/componets/utils.dart';
import 'package:avvento_radio/models/exploremodels/programs.dart';
import 'package:avvento_radio/widgets/hightlights/hightlight_details_widget.dart';
import 'package:avvento_radio/widgets/images/resizable_image_widget.dart';
import 'package:avvento_radio/widgets/text/label_place_holder.dart';
import 'package:avvento_radio/widgets/text/text_overlay_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/programs_provider.dart';

class HightlightsWidget extends StatefulWidget {
  const HightlightsWidget({super.key});

  @override
  State<HightlightsWidget> createState() => _HightlightsWidget();
}

class _HightlightsWidget extends State<HightlightsWidget> {
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
      margin: const EdgeInsets.only(top: 10.0),
      width: double.infinity,
      height: Utils.calculateAspectHeight(context, 1.45),
      child: Column(
        children: [
          Expanded(child: buildListView(context, programsProvider)),
        ],
      ),
    );
  }

  Widget buildListView(BuildContext context, ProgramsProvider programsProvider) {
    final int itemCount = programsProvider.jobList.length;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int index) {
          return buildExploreDetailsScreen(programsProvider.jobList[index]);
      },
    );
  }

  Widget buildExploreDetailsScreen(Programs explore) {
    return HightlightsDetailsWidget(explore: explore);
  }


}