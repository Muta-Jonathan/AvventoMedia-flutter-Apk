import 'package:cloud_firestore/cloud_firestore.dart';

class LiveTvModel {
  late final String name;
  late final int? likes;
  late final String imageUrl;
  late final String status;
  late final String streamUrl;
  late final String webUrl;
  late final String description;
  late final Timestamp publishedAt;

  LiveTvModel({
    required this.name,
    required this.imageUrl,
    required this.status,
    required this.description,
    required this.streamUrl,
    required this.webUrl,
    this.likes = 0,
    required this.publishedAt
  });

  factory LiveTvModel.fromSnapShot(DocumentSnapshot document) {
    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    return LiveTvModel(
      name: data['name'],
      imageUrl: data['imageUrl'],
      status: data['status'],
      streamUrl: data['streamUrl'],
      webUrl: data['webUrl'],
      description: data['description'],
      publishedAt: data['publishedAt'],
      likes: data['likes'],
    );
  }
}