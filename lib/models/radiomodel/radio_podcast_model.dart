import 'podcast_episode_model.dart' show publicArtUrl;

class RadioPodcast {
  final String id;
  final String title;
  final String description;
  final String author;
  final String email;
  final String art;
  final bool isPublished;
  final int episodes;
  final List<Category> categories;
  final String episodesLink;
  final DateTime lastUpdated;

  RadioPodcast({
    required this.id,
    required this.title,
    required this.description,
    required this.author,
    required this.email,
    required this.art,
    required this.isPublished,
    required this.episodes,
    required this.categories,
    required this.episodesLink,
    required this.lastUpdated,
  });


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'author': author,
      'email': email,
      'art': art,
      'isPublished': isPublished,
      'episodes': episodes,
      'categories': categories,
      'episodesLink': episodesLink,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch ~/ 1000,
    };
  }

  factory RadioPodcast.fromJson(Map<String, dynamic> json) {
    var categoriesJson = json['categories'] as List;
    List<Category> categoriesList = categoriesJson.map((category) => Category.fromJson(category)).toList();

    return RadioPodcast(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      author: json['author'],
      email: json['email'] ?? '',
      art: publicArtUrl(json['links']['art']),
      isPublished: json['is_published'],
      episodes: json['episodes'],
      categories: categoriesList,
      episodesLink: json['links']['episodes'],
      // The newest episode, so a show with a new one rises in the lists;
      // the cover's date until the server provides it.
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(
          (_seconds(json['last_episode_at']) ?? json['art_updated_at']) * 1000),
    );
  }
}

int? _seconds(Object? value) {
  final n = (value as num?)?.toInt();
  return n == null || n <= 0 ? null : n;
}

class Category {
  final String category;
  final String text;
  final String title;
  final String? subtitle;

  Category({
    required this.category,
    required this.text,
    required this.title,
    this.subtitle,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      category: json['category'],
      text: json['text'],
      title: json['title'],
      subtitle: json['subtitle'],
    );
  }
}