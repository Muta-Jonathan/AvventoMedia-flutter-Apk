import 'package:get/get.dart';

import '../models/radiomodel/radio_model.dart';

class RadioController extends GetxController {
  Rx<RadioModel?> selectedPlaylist = Rx<RadioModel?>(null);

  void selectedRadio(RadioModel? playlist) {
    selectedPlaylist.value = playlist;
  }
}
