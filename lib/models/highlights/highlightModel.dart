import 'package:cloud_firestore/cloud_firestore.dart';

class HighlightModel {
  late final String title;
  late final String name;
  late final String imageUrl;
  late final Timestamp publishedAt;

  HighlightModel({
    required this.title,
    required this.name,
    required this.imageUrl,
    required this.publishedAt
  });

  factory HighlightModel.fromSnapShot(DocumentSnapshot document) {
    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    return HighlightModel(
      title: data['title'],
      name: data['name'],
      imageUrl: data['imageUrl'],
      publishedAt: data['publishedAt'],
    );
  }
}