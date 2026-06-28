/// Types: 'video' | 'playlist' | 'podcast_episode' | 'podcast_show'
class SavedItem {
  final String id;
  final String type;
  final String title;
  final String thumbnailUrl;
  final String groupId;
  final String groupTitle;
  final String? videoId;
  final String? url;
  final String? duration;
  final String? description;
  final String? publishedAtItem;
  final String? views;
  final DateTime savedAt;

  const SavedItem({
    required this.id,
    required this.type,
    required this.title,
    required this.thumbnailUrl,
    required this.groupId,
    required this.groupTitle,
    this.videoId,
    this.url,
    this.duration,
    this.description,
    this.publishedAtItem,
    this.views,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'thumbnailUrl': thumbnailUrl,
        'groupId': groupId,
        'groupTitle': groupTitle,
        'videoId': videoId,
        'url': url,
        'duration': duration,
        'description': description,
        'publishedAtItem': publishedAtItem,
        'views': views,
        'savedAt': savedAt.toIso8601String(),
      };

  factory SavedItem.fromJson(Map<String, dynamic> json) => SavedItem(
        id: json['id'] as String,
        type: json['type'] as String,
        title: json['title'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String,
        groupId: json['groupId'] as String,
        groupTitle: json['groupTitle'] as String,
        videoId: json['videoId'] as String?,
        url: json['url'] as String?,
        duration: json['duration'] as String?,
        description: json['description'] as String?,
        publishedAtItem: json['publishedAtItem'] as String?,
        views: json['views'] as String?,
        savedAt: DateTime.parse(json['savedAt'] as String),
      );
}
