import 'package:avvento_media/models/exploremodels/source.dart';

class Programs {
  late final Source source;
  late final String author;
  late final String title;
  late final String description;
  late final String urlToImage;
  late final String publishedAt;

  Programs({
    required this.source,
    required this.author,
    required this.title,
    required this.description,
    required this.urlToImage,
    required this.publishedAt
  });

  factory Programs.fromJson(Map<String, dynamic> json) {
    return Programs(
      source: Source.fromJson(json['source']),
      author: json['author'] ?? "",
      title: json['title'],
      description: json['description'],
      urlToImage: json['urlToImage'],
      publishedAt: json['publishedAt'],
    );
  }
}