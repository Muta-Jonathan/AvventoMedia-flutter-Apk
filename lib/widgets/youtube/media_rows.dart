import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/youtube_playlist_item_controller.dart';
import '../../models/youtubemodels/youtube_playlist_item_model.dart';
import '../../models/youtubemodels/youtube_playlist_model.dart';
import '../../routes/routes.dart';
import '../../search/search_source.dart';
import '../common/media_list_row.dart';
import '../search/list_search.dart';

String _videos(int n) => n == 1 ? '1 video' : '$n videos';

/// A playlist as a [MediaListRow]: the stack, its size and when it started.
Widget playlistRow(YoutubePlaylistModel p,
        {String query = '', VoidCallback? onTap}) =>
    MediaListRow(
      cover: p.thumbnailUrl,
      title: p.title,
      details:
          [_videos(p.itemCount), MediaListRow.date(p.publishedAt)].join(' · '),
      stacked: true,
      query: query,
      onTap: onTap,
    );

/// A video as a [MediaListRow]: its length on the thumbnail, then its date.
Widget videoRow(YouTubePlaylistItemModel v,
    {String query = '', VoidCallback? onTap}) {
  final length = SearchEntries.parseIsoDuration(v.duration);
  return MediaListRow(
    cover: v.thumbnailUrl,
    title: v.title,
    details: MediaListRow.date(v.publishedAt),
    badge: length == null ? null : MediaListRow.length(length),
    query: query,
    onTap: onTap,
  );
}

/// The videos of a playlist, narrowed and ordered by the page's search.
/// Tapping one opens it.
class PlaylistVideosList extends StatelessWidget {
  const PlaylistVideosList(
      {super.key, required this.items, required this.search});

  final List<YouTubePlaylistItemModel> items;
  final ListSearchHandle search;

  @override
  Widget build(BuildContext context) {
    return ListSearchList<YouTubePlaylistItemModel>(
      items: items,
      search: search,
      titleOf: (v) => v.title,
      dateOf: (v) => v.publishedAt,
      durationOf: (v) => SearchEntries.parseIsoDuration(v.duration),
      itemBuilder: (context, video, query) => videoRow(
        video,
        query: query,
        onTap: () {
          Get.put(YoutubePlaylistItemController()).setSelectedEpisode(video);
          Get.toNamed(Routes.getWatchYoutubeRoute());
        },
      ),
    );
  }
}
