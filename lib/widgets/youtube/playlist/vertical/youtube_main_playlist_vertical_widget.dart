import 'package:flutter/material.dart';

import '../../../../components/app_constants.dart';
import '../../../../routes/routes.dart';
import '../../../search/list_search.dart';
import 'channel_playlists_list.dart';

/// The Main channel's playlists.
class YoutubeMainPlaylistVerticalWidget extends StatelessWidget {
  const YoutubeMainPlaylistVerticalWidget({super.key, required this.search});

  final ListSearchHandle search;

  @override
  Widget build(BuildContext context) => ChannelPlaylistsList(
        channel: AppConstants.avventoMainChannel,
        itemRoute: Routes.getYoutubeMainPlaylistItemRoute(),
        search: search,
      );
}
