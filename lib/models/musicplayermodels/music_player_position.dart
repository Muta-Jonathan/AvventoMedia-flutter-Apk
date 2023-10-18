import 'package:just_audio_background/just_audio_background.dart';

import '../radiomodel/radio_station_model.dart';

class MusicPlayerPosition {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
  final RadioStation? radioStation;
  final MediaItem mediaItem;

  const MusicPlayerPosition(this.position, this.bufferedPosition, this.duration, this.mediaItem, {this.radioStation});
}