class YouTubePlaylistItemModel {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String channelTitle;
  final String videoId;
  final String duration;
  final String views;
  final DateTime publishedAt;
  final String liveBroadcastContent;
  final String privacyStatus;

  YouTubePlaylistItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoId,
    required this.channelTitle,
    this.duration = '',
    this.views = '',
    required this.publishedAt,
    this.liveBroadcastContent = '',
    this.privacyStatus = '',
  });

  factory YouTubePlaylistItemModel.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'];
    final thumbnails = snippet['thumbnails'];
    // Check for the thumbnail qualities in order of preference
    final defaultThumbnail = thumbnails['maxres'] ??
        thumbnails['standard'] ??
        thumbnails['high'];
    final statistics = json["statistics"];

    return YouTubePlaylistItemModel(
      id: json['id'],
      title: snippet['title'],
      channelTitle: snippet['channelTitle'],
      description: snippet['description'],
      thumbnailUrl: defaultThumbnail['url'],
      videoId: snippet['resourceId']?['videoId'] ?? json['id'],
      duration: json['contentDetails']?['duration'] ?? '',
      liveBroadcastContent: json['snippet']?["liveBroadcastContent"] ?? '',
      privacyStatus: json['status']?["privacyStatus"] ?? '',
      views: statistics?['viewCount'] ?? '',
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
    String? channelTitle,
    String? views,
    DateTime? publishedAt,
    String? liveBroadcastContent,
    String? privacyStatus,
  }) {
    return YouTubePlaylistItemModel(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      channelTitle: channelTitle ?? this.channelTitle,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      views: views ?? this.views,
      publishedAt: publishedAt ?? this.publishedAt,
      liveBroadcastContent: liveBroadcastContent ?? this.liveBroadcastContent,
      privacyStatus: privacyStatus ?? this.privacyStatus,
    );
  }
}
