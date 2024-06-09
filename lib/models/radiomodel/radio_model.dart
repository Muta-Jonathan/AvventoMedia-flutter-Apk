import 'package:cloud_firestore/cloud_firestore.dart';

class RadioModel {
  late final String name;
  late final String imageUrl;
  late final String status;
  late final Timestamp publishedAt;

  RadioModel({
    required this.name,
    required this.imageUrl,
    required this.status,
    required this.publishedAt
  });

  factory RadioModel.fromSnapShot(DocumentSnapshot document) {
    final Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    return RadioModel(
      name: data['name'],
      imageUrl: data['imageUrl'],
      status: data['status'],
      publishedAt: data['publishedAt'],
    );
  }
}