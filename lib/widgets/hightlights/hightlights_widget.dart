import 'package:avvento_radio/componets/utils.dart';
import 'package:avvento_radio/models/highlights/highlightModel.dart';
import 'package:avvento_radio/widgets/hightlights/hightlight_details_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../apis/firestore_service_api.dart';

class HightlightsWidget extends StatefulWidget {
  const HightlightsWidget({super.key});

  @override
  State<HightlightsWidget> createState() => _HightlightsWidget();
}

class _HightlightsWidget extends State<HightlightsWidget> {
  final _firestoreServiceAPI = Get.put(FirestoreServiceAPI());

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

    return StreamBuilder(
        stream: _firestoreServiceAPI.fetchHighlights(),
        builder: (_, snapshot)  {
          if (snapshot.hasData) {
            List highlightList = snapshot.data!.docs;

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: highlightList.length,
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot documentSnapshot = highlightList[index];
                String docID = documentSnapshot.id;

                Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
                HighlightModel highlightModel = HighlightModel.fromSnapShot(documentSnapshot);

                return  buildHighlightDetailsScreen(highlightModel);
              },
            );
          } else {
            return const Text("no data");
          }
        });



  }

  Widget buildHighlightDetailsScreen(HighlightModel highlightModel) {
    return HightlightsDetailsWidget(highlightModel: highlightModel,);
  }


}
