import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

import '../../apis/azuracast_api.dart';
import '../../models/radiomodel/radio_station_model.dart';

class RadioStationProvider extends ChangeNotifier {
  RadioStation? _radioStation;

  RadioStation? get radioStation => _radioStation;

  /// A fixed station and no connection, for tests.
  @visibleForTesting
  RadioStationProvider.fixed(RadioStation? station) : _radioStation = station;

  RadioStationProvider() {
    establishWebSocketConnection();
    sendInitialMessage(); // Send the initial message
    fetchRadioStationUpdates();
  }

  void establishWebSocketConnection() {
    AzuraCastAPI.establishWebsocketConnection();
  }

  void sendInitialMessage() {
    AzuraCastAPI.sendInitialMessage();
  }

  Timer? _elapsedTimer;

  StreamSubscription<RadioStation>? _updates;

  void fetchRadioStationUpdates() {
    _updates = AzuraCastAPI.getRadioStationUpdates().listen(
        (updatedRadioStation) {
      _radioStation = updatedRadioStation;
      _startElapsedTimer();
      notifyListeners(); // Notify listeners of changes
    }, onError: (_) {
      // Offline or dropped: keep the last song until [reconnect].
    });
  }

  /// Opens a fresh connection, e.g. when the device is back online.
  void reconnect() {
    _updates?.cancel();
    AzuraCastAPI.closeWebsocketConnection();
    establishWebSocketConnection();
    sendInitialMessage();
    fetchRadioStationUpdates();
  }

  void _startElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_radioStation != null) {
        if (_radioStation!.elapsed < _radioStation!.duration) {
          _radioStation = RadioStation(
            id: _radioStation!.id,
            artist: _radioStation!.artist,
            imageUrl: _radioStation!.imageUrl,
            nowPlayingTitle: _radioStation!.nowPlayingTitle,
            streamUrl: _radioStation!.streamUrl,
            duration: _radioStation!.duration,
            elapsed: _radioStation!.elapsed + 1,
            nextProgram: _radioStation!.nextProgram,
          );
          notifyListeners();
        }
      }
    });
  }

  @override
  void dispose() {
    _elapsedTimer?.cancel();
    _updates?.cancel();
    AzuraCastAPI.closeWebsocketConnection();
    super.dispose();
  }
}


