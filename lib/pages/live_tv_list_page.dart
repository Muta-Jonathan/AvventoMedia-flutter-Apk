import 'package:avvento_media/widgets/search/list_search.dart';
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

    return ListSearchScope(
      builder: (context, search) => Scaffold(
      backgroundColor:   Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        controller: search.scroll,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: <Widget>[
          if (search.controller.searching)
            ...listSearchTop(context, search,
                hint: AppConstants.searchLive, unit: 'channels', showLength: false),
          if (!search.controller.searching) ...<Widget>[
          SliverAppBar(
            backgroundColor:   Theme.of(context).colorScheme.surface,
            iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
            actions: [ListSearchButton(search: search)],
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
          ],
          LiveTvVerticalWidget(search: search),
        ],
      ),
    ));
  }
}

