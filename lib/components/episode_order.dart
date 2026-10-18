import 'package:flutter/foundation.dart';

import '../models/radiomodel/podcast_episode_model.dart';
import 'app_constants.dart';
import 'feed_kind.dart';

enum EpisodeSort { inOrder, newest, oldest }

final _seriesLabel = RegExp(
    r'\b(?:part|pt\.?|chapter|ch\.?|lesson|session)\s*#?(\d+)',
    caseSensitive: false);
final _episodeLabel =
    RegExp(r'(?:\b(?:episode|ep\.?)\s*|#)(\d+)', caseSensitive: false);
final _trailingNumber = RegExp(r'\b(\d+)\s*$');

/// Part/chapter number in a title: "Part 3", "Ch. 12", "Lesson 4",
/// "Episode 7", "#7", or a trailing "Genesis 2". Null when there is none.
int? episodeNumber(String title) {
  for (final re in [_seriesLabel, _episodeLabel, _trailingNumber]) {
    final m = re.firstMatch(title);
    if (m != null) return int.parse(m.group(1)!);
  }
  return null;
}

/// The episode's place in a series: AzuraCast's episode number, else the
/// number in its title.
int? seriesNumber(PodcastEpisode e) =>
    e.episodeNumber ?? episodeNumber(e.title);

/// "Chapter" when the title says chapter, else "Part".
String seriesNumberLabel(PodcastEpisode e) =>
    RegExp(r'\b(?:chapter|ch\.?)\s*\d', caseSensitive: false).hasMatch(e.title)
        ? AppConstants.chapter
        : AppConstants.part;

/// Most titles say "Part N" / "Chapter N": play it in order by default.
/// AzuraCast numbers daily shows too, so its episode number alone doesn't
/// count; "Episode 312" and "Day 266" shows default to newest.
bool looksLikeSeries(List<PodcastEpisode> episodes) {
  if (episodes.length < 2) return false;
  final numbered = episodes.where((e) => _seriesLabel.hasMatch(e.title));
  return numbered.length >= episodes.length * 0.6;
}

/// [episodes] arrive newest first. In order sorts by part number (Bible:
/// book, then chapter; otherwise season, then number); ties and unnumbered
/// episodes keep publish order, unnumbered last.
List<PodcastEpisode> sortEpisodes(
    List<PodcastEpisode> episodes, EpisodeSort sort,
    {FeedKind kind = FeedKind.series}) {
  switch (sort) {
    case EpisodeSort.newest:
      return episodes;
    case EpisodeSort.oldest:
      return episodes.reversed.toList();
    case EpisodeSort.inOrder:
      final list = episodes.reversed.toList();
      final numbers = {for (final e in list) e.id: _orderKey(e, kind)};
      mergeSort(list, compare: (a, b) {
        final x = numbers[a.id], y = numbers[b.id];
        if (x == null || y == null) {
          return x == null ? (y == null ? 0 : 1) : -1;
        }
        return x.compareTo(y);
      });
      return list;
  }
}

int? _orderKey(PodcastEpisode e, FeedKind kind) {
  if (kind == FeedKind.bible) {
    final ref = bibleRef(e);
    if (ref != null) return ref.book * 1000 + ref.chapter;
  }
  final n = seriesNumber(e);
  return n == null ? null : (e.seasonNumber ?? 0) * 100000 + n;
}
