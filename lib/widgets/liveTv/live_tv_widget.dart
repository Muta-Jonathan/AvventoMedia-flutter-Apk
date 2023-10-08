import 'package:avvento_radio/componets/app_constants.dart';
import 'package:avvento_radio/componets/utils.dart';
import 'package:avvento_radio/models/livetvmodel/liveTvModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../apis/firestore_service_api.dart';
import '../text/label_place_holder.dart';
import 'live_tv_details_widget.dart';

class LiveTvWidget extends StatefulWidget {
  const LiveTvWidget({super.key});

  @override
  State<LiveTvWidget> createState() => _LiveTvWidget();
}

class _LiveTvWidget extends State<LiveTvWidget> {
  final _liveTvAPI = Get.put(FirestoreServiceAPI());

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      width: double.infinity,
      height: Utils.calculateAspectHeight(context, 1.3),
      child: Column(
        children: [
          const LabelPlaceHolder(title: AppConstants.liveTv,titleFontSize: 18),
          const SizedBox(height: 10),
          Expanded(child: buildListView(context),)
        ],
      ),
    );
  }

  Widget buildListView(BuildContext context) {
    return StreamBuilder(
        stream: _liveTvAPI.fetchLiveTv(),
        builder: (_, snapshot)  {
          if (snapshot.hasData) {
            List liveTvList = snapshot.data!.docs;

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: liveTvList.length,
              itemBuilder: (BuildContext context, int index) {
                DocumentSnapshot documentSnapshot = liveTvList[index];

                LiveTvModel liveTvModel = LiveTvModel.fromSnapShot(documentSnapshot);

                return  buildLiveTvDetailsScreen(liveTvModel);
              },
            );
          } else {
            return const Text("no data");
          }
        });

  }

  Widget buildLiveTvDetailsScreen(LiveTvModel liveTvModel) {
    return LiveTvDetailsWidget(liveTvModel: liveTvModel,);
  }
}
