import 'package:flutter/cupertino.dart';

import '../../apis/azuracast_api.dart';
import '../../models/radiomodel/radio_station_model.dart';

class RadioStationProvider extends ChangeNotifier {
  RadioStation? _radioStation;

  RadioStation? get radioStation => _radioStation;

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

  void fetchRadioStationUpdates() {
    AzuraCastAPI.getRadioStationUpdates().listen((updatedRadioStation) {
      _radioStation = updatedRadioStation;
      notifyListeners(); // Notify listeners of changes
    }, onError: (error) {
      throw error;
    });
  }

  @override
  void dispose() {
    AzuraCastAPI.closeWebsocketConnection();
    super.dispose();
  }
}


