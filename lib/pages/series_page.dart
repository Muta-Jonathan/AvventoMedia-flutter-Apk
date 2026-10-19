import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/app_constants.dart';
import '../models/presenter_model.dart';
import '../models/radiomodel/radio_podcast_model.dart';
import '../models/saved_item_model.dart';
import 'podcast_episode_list_page.dart';

/// A presenter's series, on the podcast page layout: cover, title,
/// presenter, Play / Resume, Download all and the parts in order.
class SeriesPage extends StatelessWidget {
  /// Defaults to the route argument (presenter, series).
  const SeriesPage({super.key, this.presenter, this.series});

  final Presenter? presenter;
  final SermonSeries? series;

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as (Presenter, SermonSeries)?;
    final p = presenter ?? args!.$1;
    final s = series ?? args!.$2;
    // The page expects the API's newest-first order; it sorts by part.
    final newestFirst = List.of(s.parts)
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    final latest = newestFirst.isEmpty ? 0 : newestFirst.first.publishedAt;

    return PodcastEpisodeListPage(
      show: RadioPodcast(
        id: s.id,
        title: s.title,
        description: '',
        author: p.name,
        email: '',
        art: s.cover,
        isPublished: true,
        episodes: s.parts.length,
        categories: const [],
        episodesLink: '',
        lastUpdated: DateTime.fromMillisecondsSinceEpoch(latest * 1000),
      ),
      overline: AppConstants.seriesLabel,
      countLabel: AppConstants.partCount,
      saved: SavedItem(
        id: s.id,
        type: 'presenter_series',
        title: s.title,
        thumbnailUrl: s.cover,
        groupId: p.id,
        groupTitle: p.name,
        savedAt: DateTime.now(),
      ),
      fetchEpisodes: (_) async => newestFirst,
      cachedEpisodes: (_) async => null,
    );
  }
}
