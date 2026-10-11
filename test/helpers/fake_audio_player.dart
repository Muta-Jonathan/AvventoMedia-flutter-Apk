import 'dart:async';

import 'package:just_audio/just_audio.dart';

/// In-memory [AudioPlayer] for tests: no platform channels. Drive it with
/// [emitState] / [emitPosition] and inspect [calls].
class FakeAudioPlayer implements AudioPlayer {
  final _state = StreamController<PlayerState>.broadcast(sync: true);
  final _position = StreamController<Duration>.broadcast(sync: true);
  final _sequence = StreamController<SequenceState>.broadcast(sync: true);

  PlayerState _playerState = PlayerState(false, ProcessingState.idle);
  Duration? fakeDuration;
  bool interruptNextLoad = false;
  final List<String> calls = [];

  void emitState(bool playing, ProcessingState processingState) {
    _playerState = PlayerState(playing, processingState);
    _state.add(_playerState);
  }

  void emitPosition(Duration position) => _position.add(position);

  @override
  PlayerState get playerState => _playerState;
  @override
  Stream<PlayerState> get playerStateStream => _state.stream;
  @override
  Stream<Duration> get positionStream => _position.stream;
  @override
  Stream<SequenceState> get sequenceStateStream => _sequence.stream;
  @override
  Duration? get duration => fakeDuration;
  @override
  bool get playing => _playerState.playing;
  @override
  ProcessingState get processingState => _playerState.processingState;
  @override
  bool get hasNext => false;
  @override
  bool get hasPrevious => false;

  @override
  Future<void> setLoopMode(LoopMode mode) async {}
  @override
  Future<void> play() async => calls.add('play');
  @override
  Future<void> pause() async => calls.add('pause');
  @override
  Future<void> stop() async => calls.add('stop');
  @override
  Future<void> seek(Duration? position, {int? index}) async =>
      calls.add('seek:${position?.inSeconds}');
  @override
  Future<Duration?> setAudioSource(
    AudioSource audioSource, {
    bool preload = true,
    int? initialIndex,
    Duration? initialPosition,
  }) async {
    calls.add('setAudioSource');
    if (interruptNextLoad) {
      interruptNextLoad = false;
      throw PlayerInterruptedException('Connection aborted');
    }
    return fakeDuration;
  }
  @override
  Future<void> dispose() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
