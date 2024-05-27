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