import 'package:flutter/material.dart';

import '../../../../components/app_constants.dart';
import '../../../../routes/routes.dart';
import '../../../search/list_search.dart';
import 'channel_playlists_list.dart';

/// The Kids channel's playlists.
class YoutubeKidsPlaylistVerticalWidget extends StatelessWidget {
  const YoutubeKidsPlaylistVerticalWidget({super.key, required this.search});

  final ListSearchHandle search;

  @override
  Widget build(BuildContext context) => ChannelPlaylistsList(
        channel: AppConstants.avventoKidsChannel,
        itemRoute: Routes.getYoutubeKidsPlaylistItemRoute(),
        search: search,
      );
}
