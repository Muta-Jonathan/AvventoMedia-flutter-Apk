class Episode {
  final int episodeId;
  final String type;
  final String title;
  final int duration;
  final bool explicit;
  final int showId;
  final int authorId;
  final String imageUrl;
  final String imageOriginalUrl;
  final String imageTransformation;
  final String publishedAt;
  final bool downloadEnabled;
  final String waveformUrl;
  final String siteUrl;
  final String downloadUrl;
  final String playbackUrl;

  Episode({
    required this.episodeId,
    required this.type,
    required this.title,
    required this.duration,
    required this.explicit,
    required this.showId,
    required this.authorId,
    required this.imageUrl,
    required this.imageOriginalUrl,
    required this.imageTransformation,
    required this.publishedAt,
    required this.downloadEnabled,
    required this.waveformUrl,
    required this.siteUrl,
    required this.downloadUrl,
    required this.playbackUrl,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      episodeId: json['episode_id'],
      type: json['type'],
      title: json['title'],
      duration: json['duration'],
      explicit: json['explicit'],
      showId: json['show_id'],
      authorId: json['author_id'],
      imageUrl: json['image_url'],
      imageOriginalUrl: json['image_original_url'],
      imageTransformation: json['image_transformation'],
      publishedAt: json['published_at'],
      downloadEnabled: json['download_enabled'],
      waveformUrl: json['waveform_url'],
      siteUrl: json['site_url'],
      downloadUrl: json['download_url'],
      playbackUrl: json['playback_url'],
    );
  }
}
