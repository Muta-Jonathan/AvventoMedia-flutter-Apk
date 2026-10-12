import 'podcast_episode_model.dart';

/// A podcast episode saved to the device for offline listening.
class DownloadedEpisode {
  final PodcastEpisode episode;
  final String showTitle;
  final String filePath;
  final int bytes;
  final DateTime downloadedAt;

  DownloadedEpisode({
    required this.episode,
    required this.showTitle,
    required this.filePath,
    required this.bytes,
    required this.downloadedAt,
  });

  factory DownloadedEpisode.fromJson(Map<String, dynamic> json) =>
      DownloadedEpisode(
        episode: PodcastEpisode.fromJson(json['episode']),
        showTitle: json['showTitle'] ?? '',
        filePath: json['filePath'],
        bytes: json['bytes'] ?? 0,
        downloadedAt: DateTime.parse(json['downloadedAt']),
      );

  Map<String, dynamic> toJson() => {
        'episode': episode.toJson(),
        'showTitle': showTitle,
        'filePath': filePath,
        'bytes': bytes,
        'downloadedAt': downloadedAt.toIso8601String(),
      };
}
