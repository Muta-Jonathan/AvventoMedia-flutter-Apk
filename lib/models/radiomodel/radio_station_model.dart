class RadioStation {
  final String artist;
  final String imageUrl;
  final String nowPlayingTitle;
  final String streamUrl;
  final int duration;
  final int elapsed;

  RadioStation({
    required this.nowPlayingTitle,
    required this.artist,
    required this.imageUrl,
    required this.streamUrl,
    required this.duration,
    required this.elapsed,
  });

  Map<String, dynamic> toJson() {
    return {
      'artist': artist,
      'imageUrl': imageUrl,
      'nowPlayingTitle': nowPlayingTitle,
      'streamUrl': streamUrl,
      'duration': duration,
      'elapsed': elapsed,
    };
  }
  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      artist: json['artist'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      nowPlayingTitle: json['nowPlayingTitle'] ?? '',
      streamUrl: json['streamUrl'] ?? '',
      elapsed: json['elapsed'] ?? 0,
      duration: json['duration'] ?? 0,
    );
  }

}
