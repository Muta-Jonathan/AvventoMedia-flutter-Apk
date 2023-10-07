import 'package:avvento_radio/componets/utils.dart';
import 'package:avvento_radio/controller/highlight_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../models/highlights/highlightModel.dart';
import 'hightlight_details_widget.dart';

class HighlightsWidget extends StatefulWidget {
  const HighlightsWidget({super.key});

  @override
  State<HighlightsWidget> createState() => _HighlightsWidget();
}

class _HighlightsWidget extends State<HighlightsWidget> {

  @override
  Widget build(BuildContext context) {


    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      width: double.infinity,
      height: Utils.calculateAspectHeight(context, 1.45),
      child: Column(
        children: [
          Expanded(child: buildListView(context)),
        ],
      ),
    );
  }

  Widget buildListView(BuildContext context) {
    final controller = Get.put(HighlightController());

    return FutureBuilder(
      future: controller.getAllHighlights(),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator()); // Loading indicator
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No highlights available.');
        } else {
          return Container(
            margin: const EdgeInsets.only(top: 10.0),
            width: double.infinity,
            height: Utils.calculateAspectHeight(context, 1.45),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return buildHighlightDetailsScreen(snapshot.data![index]);
              },
            ),
          );
        }
      },
    );
  }

  Widget  buildHighlightDetailsScreen(HighlightModel highlight) {
    return HighlightsDetailsWidget(highlight: highlight,);
  }


}
