import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:avvento_media/widgets/liveTv/vertical/live_tv_details_vertical_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../routes/routes.dart';
import '../../../apis/firestore_service_api.dart';
import '../../../components/app_constants.dart';
import '../../../components/utils.dart';
import '../../../controller/live_tv_controller.dart';
import '../../../models/livetvmodel/livetv_model.dart';

class LiveTvVerticalWidget extends StatefulWidget {
  const LiveTvVerticalWidget({super.key});

  @override
  State<LiveTvVerticalWidget>  createState() => _LiveTvVerticalWidgetState();
}

class _LiveTvVerticalWidgetState extends State<LiveTvVerticalWidget> {
  final _liveTvAPI = Get.put(FirestoreServiceAPI());
  final liveTvController = Get.put(LiveTvController());

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _liveTvAPI.fetchLiveTv(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(child: LoadingWidget()),
          );
        } else if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(child: Text('No items found')),
          );
        } else {
          List liveTvList = snapshot.data!.docs;
          // Keep LIVE NOW channels first; push non-live ones to the end.
          final sorted = [...liveTvList]..sort((a, b) {
            final aLive = LiveTvModel.fromSnapShot(a as DocumentSnapshot).status == AppConstants.liveNow;
            final bLive = LiveTvModel.fromSnapShot(b as DocumentSnapshot).status == AppConstants.liveNow;
            if (aLive == bLive) return 0;
            return aLive ? -1 : 1;
          });
          return SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                DocumentSnapshot documentSnapshot = sorted[index] as DocumentSnapshot;
                LiveTvModel liveTvModel = LiveTvModel.fromSnapShot(documentSnapshot);
                return buildLiveTvDetailsScreen(liveTvModel);
              },
              childCount: sorted.length,
            ),
          );
        }
      },
    );
  }

  Widget buildLiveTvDetailsScreen(LiveTvModel liveTvModel) {
    return GestureDetector(
      onTap: () {
        if (liveTvModel.status == AppConstants.liveNow) {
          // Set the selected tv using the controller
          liveTvController.setSelectedTv(liveTvModel);
          // Navigate to the "livetvPage"
          Get.toNamed(Routes.getLiveTvRoute());
        } else {
          Utils.showComingSoonDialog(context);
        }
      },
      child: LiveTvDetailsVerticalWidget(liveTvModel: liveTvModel),
    );
  }
}

