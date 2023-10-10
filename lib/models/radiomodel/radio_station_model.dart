class RadioStation {
  final String artist;
  final String imageUrl;
  final String nowPlayingTitle;
  final String streamUrl;

  RadioStation({
    required this.nowPlayingTitle,
    required this.artist,
    required this.imageUrl,
    required this.streamUrl,
  });

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      artist: json['artist'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      nowPlayingTitle: json['nowPlayingTitle'] ?? '',
      streamUrl: json['streamUrl'] ?? '',
    );
  }

}
