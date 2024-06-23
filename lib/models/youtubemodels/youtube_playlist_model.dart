class YoutubePlaylistModel {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final int itemCount;

  YoutubePlaylistModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.itemCount,
  });

  factory YoutubePlaylistModel.fromJson(Map<String, dynamic> json) {
    return YoutubePlaylistModel(
      id: json['id'],
      title: json['snippet']['title'],
      description: json['snippet']['description'],
      thumbnailUrl: json['snippet']['thumbnails']['standard']['url'],
      itemCount: json['contentDetails']['itemCount'],
    );
  }
}