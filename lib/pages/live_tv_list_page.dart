import 'package:avvento_media/componets/app_constants.dart';
import 'package:avvento_media/componets/utils.dart';
import 'package:avvento_media/controller/youtube_playlist_controller.dart';
import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../widgets/images/resizable_image_widget_2.dart';
import '../widgets/liveTv/vertical/live_tv_vertical_widget.dart';
import '../widgets/providers/youtube_provider.dart';
import '../widgets/text/show_more_desc.dart';
import '../widgets/youtube/items/youtube_playlist_item_widget.dart';
import '../widgets/youtube/playlist/vertical/youtube_playlist_vertical_widget.dart';

class LiveTvListPage extends StatefulWidget {
  const LiveTvListPage({super.key});

  @override
  State<LiveTvListPage> createState() => _LiveTvListPageState();
}

class _LiveTvListPageState extends State<LiveTvListPage> {

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:   Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor:   Theme.of(context).colorScheme.surface,
            iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
            expandedHeight: Utils.calculateHeight(context, 0.12),
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.blurBackground
              ],
              title: TextOverlay(
                label: AppConstants.liveTv,
                color: Theme.of(context).colorScheme.onPrimary,
                maxLines: 1,
                fontSize: AppConstants.fontSize20,
              ),
              centerTitle: false,
              expandedTitleScale: 1,
              collapseMode: CollapseMode.pin,
              titlePadding: const EdgeInsets.only(left: 48,bottom: 14),
            ),
          ),
          const LiveTvVerticalWidget(),
        ],
      ),
    );
  }
}

