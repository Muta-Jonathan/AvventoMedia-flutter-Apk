import '../radiomodel/radio_station_model.dart';

class MusicPlayerPosition {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
  final RadioStation? radioStation; // Change to optional

  const MusicPlayerPosition(this.position, this.bufferedPosition, this.duration, {this.radioStation});
}