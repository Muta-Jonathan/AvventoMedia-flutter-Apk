import 'radiomodel/podcast_episode_model.dart';

/// A sermon series by one presenter; [parts] are in part order.
class SermonSeries {
  const SermonSeries({
    required this.id,
    required this.title,
    required this.cover,
    required this.parts,
  });

  final String id;
  final String title;
  final String cover;
  final List<PodcastEpisode> parts;

  factory SermonSeries.fromJson(Map<String, dynamic> json) => SermonSeries(
        id: json['id'],
        title: json['title'],
        cover: json['cover'] ?? '',
        parts: [
          for (final p in json['parts'] as List) PodcastEpisode.fromJson(p)
        ],
      );
}

/// A preacher or speaker. The list endpoint returns the summary fields;
/// the detail endpoint adds [series] and [singles].
class Presenter {
  const Presenter({
    required this.id,
    required this.name,
    required this.image,
    required this.genre,
    required this.sermonCount,
    required this.seriesCount,
    this.series = const [],
    this.singles = const [],
  });

  final String id;

  /// With title, e.g. "Pr. Okello Samuel".
  final String name;

  /// Portrait: a crop of sermon art.
  final String image;
  final String genre;
  final int sermonCount;
  final int seriesCount;
  final List<SermonSeries> series;

  /// Newest first.
  final List<PodcastEpisode> singles;

  /// Every sermon: series parts in order, then singles.
  List<PodcastEpisode> get allSermons =>
      [for (final s in series) ...s.parts, ...singles];

  /// The most recently published sermon, or null.
  PodcastEpisode? get latest {
    PodcastEpisode? best;
    for (final e in allSermons) {
      if (best == null || e.publishedAt > best.publishedAt) best = e;
    }
    return best;
  }

  factory Presenter.fromJson(Map<String, dynamic> json) => Presenter(
        id: json['id'],
        name: json['name'],
        image: json['image'] ?? '',
        genre: json['genre'] ?? '',
        sermonCount: (json['sermon_count'] as num?)?.toInt() ?? 0,
        seriesCount: (json['series_count'] as num?)?.toInt() ?? 0,
        series: [
          for (final s in (json['series'] as List?) ?? const [])
            SermonSeries.fromJson(s)
        ],
        singles: [
          for (final e in (json['singles'] as List?) ?? const [])
            PodcastEpisode.fromJson(e)
        ]..sort((a, b) => b.publishedAt.compareTo(a.publishedAt)),
      );
}
