class YouTubePlaylistItemModel {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoId;
  final String duration;
  final DateTime publishedAt;

  YouTubePlaylistItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoId,
    this.duration = '',
    required this.publishedAt
  });

  factory YouTubePlaylistItemModel.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'];
    final thumbnails = snippet['thumbnails'];
    final defaultThumbnail = thumbnails['standard'];

    return YouTubePlaylistItemModel(
      id: json['id'],
      title: snippet['title'],
      description: snippet['description'],
      thumbnailUrl: defaultThumbnail['url'],
      videoId: snippet['resourceId']['videoId'],
      publishedAt: DateTime.parse(snippet['publishedAt']),
    );
  }

  YouTubePlaylistItemModel copyWith({
    String? id,
    String? videoId,
    String? title,
    String? description,
    String? thumbnailUrl,
    String? duration,
    DateTime? publishedAt,
  }) {
    return YouTubePlaylistItemModel(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }
}
