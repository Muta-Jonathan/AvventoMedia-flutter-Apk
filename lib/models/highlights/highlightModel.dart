import 'package:cloud_firestore/cloud_firestore.dart';

class HighlightModel {
  late final String? id;
  late final String title;
  late final String name;
  late final String urlToImage;
  late final String publishedAt;

  HighlightModel({
    this.id,
    required this.title,
    required this.name,
    required this.urlToImage,
    required this.publishedAt
  });

  factory HighlightModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return HighlightModel(
      id: document.id,
      title: data['title'],
      name: data['name'],
      urlToImage: data['urlToImage'],
      publishedAt: data['publishedAt'],
    );
  }
}