class RadioStation {
  final String? artist;
  final String? imageUrl;
  final String? nowPlayingTitle;
  final String? streamUrl;
  final int? duration;
  final int? elapsed;

  RadioStation({
    this.nowPlayingTitle,
    this.artist,
    this.imageUrl,
    this.streamUrl,
    this.duration,
    this.elapsed,
  });

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
