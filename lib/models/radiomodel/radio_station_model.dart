class RadioStation {
  final int id;
  final String artist;
  final String imageUrl;
  final String nowPlayingTitle;
  final String streamUrl;
  final int duration;
  final int elapsed;
  final String nextProgram;

  RadioStation({
    required this.id,
    required this.nowPlayingTitle,
    required this.artist,
    required this.imageUrl,
    required this.streamUrl,
    required this.duration,
    required this.elapsed,
    required this.nextProgram,
  });

  Map<String, dynamic> toJson() {
    return {
      'artist': artist,
      'imageUrl': imageUrl,
      'nowPlayingTitle': nowPlayingTitle,
      'streamUrl': streamUrl,
      'duration': duration,
      'elapsed': elapsed,
      'nextProgram' : nextProgram,
    };
  }
  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      id: json['sh_id'] ?? 0,
      artist: json['artist'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      nowPlayingTitle: json['nowPlayingTitle'] ?? '',
      streamUrl: json['streamUrl'] ?? '',
      elapsed: json['elapsed'] ?? 0,
      duration: json['duration'] ?? 0,
      nextProgram: '',
    );
  }
}
