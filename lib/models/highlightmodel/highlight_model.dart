import 'package:cloud_firestore/cloud_firestore.dart';

import '../youtubemodels/youtube_playlist_item_model.dart';
import '../youtubemodels/youtube_playlist_model.dart';

class HighlightModel {
  late final String? title;
  late final String? name;
  late final String? imageUrl;
  late final String? type;
  late final Timestamp publishedAt;
  late final YouTubePlaylistItemModel? youtubePlaylistItem;
  late final YoutubePlaylistModel? youtubePlaylist;

  HighlightModel({
    this.title,
    this.name,
    this.imageUrl,
    this.type,
    required this.publishedAt,
    this.youtubePlaylistItem,
    this.youtubePlaylist
  });

  factory HighlightModel.fromSnapShot(DocumentSnapshot document) {
    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    return HighlightModel(
      title: data['title'],
      name: data['name'],
      imageUrl: data['imageUrl'],
      type: data["type"],
      publishedAt: data['publishedAt'],
      youtubePlaylistItem: data['youtubePlaylistItem'] != null
          ? YouTubePlaylistItemModel.fromJson(data['youtubePlaylistItem'])
          : null,
      youtubePlaylist: data['youtubePlaylist'] != null
          ? YoutubePlaylistModel.fromJson(data['youtubePlaylist'])
          : null,
    );
  }
}