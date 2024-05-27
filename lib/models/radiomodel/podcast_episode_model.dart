class PodcastEpisode {
  final String id;
  final String title;
  final String description;
  final String playlistMediaArtist;
  final String playlistMediaAlbum;
  final int publishedAt;
  final String downloadLink;
  final String publicLink;
  final bool isPublished;
  final String art;
  final String media;

  PodcastEpisode({
    required this.id,
    required this.title,
    required this.description,
    required this.playlistMediaArtist,
    required this.playlistMediaAlbum,
    required this.publishedAt,
    required this.downloadLink,
    required this.publicLink,
    required this.isPublished,
    required this.art,
    required this.media
  });

  factory PodcastEpisode.fromJson(Map<String, dynamic> json) {
    final playlistMediaJson = json['playlist_media'];
    return PodcastEpisode(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      playlistMediaArtist: playlistMediaJson['artist'],
      playlistMediaAlbum: playlistMediaJson['album'],
      publishedAt: json['publish_at'],
      downloadLink: json['links']['download'],
      publicLink: json['links']['public'],
      isPublished: json['is_published'],
      art: json['art'],
      media: json['links']['media'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'playlist_media': {
        'artist': playlistMediaArtist,
        'album': playlistMediaAlbum,
      },
      'publish_at': publishedAt,
      'links': {
        'download': downloadLink,
        'public': publicLink,
        'media': media,
      },
      'is_published': isPublished,
      'art': art,
    };
  }
}
