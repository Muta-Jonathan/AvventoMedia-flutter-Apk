import 'package:avvento_media/componets/app_constants.dart';
import 'package:avvento_media/componets/utils.dart';
import 'package:avvento_media/models/radiomodel/radio_model.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:avvento_media/widgets/radio/live_radio_details_widget.dart';
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

            if (liveTvList.isNotEmpty) {
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
              return const LoadingWidget();
            }
          } else {
            return const LoadingWidget();
          }
        });
  }

  Widget buildLiveTvDetailsScreen(RadioModel radioModel) {
    return LiveRadioDetailsWidget(radioModel: radioModel);
  }
}
