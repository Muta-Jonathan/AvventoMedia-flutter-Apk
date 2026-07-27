class CustomPlaylistMeta {
  final String id;
  final String title;
  final DateTime createdAt;

  const CustomPlaylistMeta({
    required this.id,
    required this.title,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
      };

  factory CustomPlaylistMeta.fromJson(Map<String, dynamic> json) =>
      CustomPlaylistMeta(
        id: json['id'] as String,
        title: json['title'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
