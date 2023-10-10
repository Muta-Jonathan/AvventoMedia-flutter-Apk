import 'package:flutter/material.dart';
import '../../apis/azuracast_api.dart';
import '../../models/radiomodel/radio_station_model.dart';

class RadioStationProvider extends ChangeNotifier {
  RadioStation? _radioStation;

  RadioStation? get radioStation => _radioStation;

  Future<void> fetchRadioStation() async {
    _radioStation = await AzuraCastAPI.fetchRadioStation();
    notifyListeners();
  }

}
