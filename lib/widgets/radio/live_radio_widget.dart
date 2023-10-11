import 'package:avvento_radio/componets/app_constants.dart';
import 'package:avvento_radio/componets/utils.dart';
import 'package:avvento_radio/models/radiomodel/radioModel.dart';
import 'package:avvento_radio/widgets/radio/live_radio_details_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../apis/firestore_service_api.dart';
import '../text/label_place_holder.dart';

class LiveRadioWidget extends StatefulWidget {
  const LiveRadioWidget({super.key});

  @override
  State<LiveRadioWidget> createState() => _LiveRadioWidget();
}

class _LiveRadioWidget extends State<LiveRadioWidget> {
  final _radioAPI = Get.put(FirestoreServiceAPI());

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      width: double.infinity,
      height: Utils.calculateAspectHeight(context, 1.3),
      child: Column(
        children: [
          const LabelPlaceHolder(title: AppConstants.liveRadio, titleFontSize: 18),
          const SizedBox(height: 10),
          Expanded(child: buildListView(context)),
        ],
      ),
    );
  }

  Widget buildListView(BuildContext context) {
    return StreamBuilder(
        stream: _radioAPI.fetchRadio(),
        builder: (_, snapshot)  {
          if (snapshot.hasData) {
            List liveTvList = snapshot.data!.docs;

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: liveTvList.length,
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot documentSnapshot = liveTvList[index];
                RadioModel radioModel = RadioModel.fromSnapShot(documentSnapshot);

                return  buildLiveTvDetailsScreen(radioModel);
              },
            );
          } else {
            return const Text("no data");
          }
        });
  }

  Widget buildLiveTvDetailsScreen(RadioModel radioModel) {
    return LiveRadioDetailsWidget(radioModel: radioModel);
  }
}
