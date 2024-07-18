class YoutubePlaylistModel {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final int itemCount;
  final DateTime publishedAt;

  YoutubePlaylistModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.itemCount,
    required this.publishedAt,
  });

  factory YoutubePlaylistModel.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'];
    final thumbnails = snippet['thumbnails'];
    final defaultThumbnail = thumbnails['maxres'];

    return YoutubePlaylistModel(
      id: json['id'],
      title: snippet['title'],
      description: snippet['description'],
      thumbnailUrl: defaultThumbnail['url'],
      itemCount: json['contentDetails']['itemCount'],
      publishedAt: DateTime.parse(snippet['publishedAt']), // Parse the date
    );
  }
}