import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/components/utils.dart';
import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:flutter/material.dart';

import '../widgets/liveTv/vertical/live_tv_vertical_widget.dart';

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

