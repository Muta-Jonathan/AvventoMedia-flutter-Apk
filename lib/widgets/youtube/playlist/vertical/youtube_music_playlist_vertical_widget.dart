import 'package:flutter/material.dart';

import '../../../../components/app_constants.dart';
import '../../../../routes/routes.dart';
import '../../../search/list_search.dart';
import 'channel_playlists_list.dart';

/// The Music channel's playlists.
class YoutubeMusicPlaylistVerticalWidget extends StatelessWidget {
  const YoutubeMusicPlaylistVerticalWidget({super.key, required this.search});

  final ListSearchHandle search;

  @override
  Widget build(BuildContext context) => ChannelPlaylistsList(
        channel: AppConstants.avventoMusicChannel,
        itemRoute: Routes.getYoutubeMusicPlaylistItemRoute(),
        search: search,
      );
}
