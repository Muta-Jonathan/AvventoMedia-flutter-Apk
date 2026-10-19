/// AzuraCast's private art URLs need the API key, which the player, mini
/// player and lock screen can't send; the public route serves the same
/// image without it.
String publicArtUrl(String url) => url.replaceFirstMapped(
    RegExp(r'(/api/station/[^/]+/)podcast/'), (m) => '${m[1]}public/podcast/');

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

  /// AzuraCast's episode number, when the show sets one.
  final int? episodeNumber;

  /// AzuraCast's season; the Bible shows use the book's place in the Bible.
  final int? seasonNumber;

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
    required this.media,
    this.episodeNumber,
    this.seasonNumber,
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
      art: publicArtUrl(json['art']),
      media: json['links']['media'],
      episodeNumber: (json['episode_number'] as num?)?.toInt(),
      seasonNumber: (json['season_number'] as num?)?.toInt(),
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
      'episode_number': episodeNumber,
      'season_number': seasonNumber,
    };
  }
}
