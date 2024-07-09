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
      art: json['links']['art'],
      isPublished: json['is_published'],
      episodes: json['episodes'],
      categories: categoriesList,
      episodesLink: json['links']['episodes'],
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(json['art_updated_at'] * 1000),
    );
  }
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