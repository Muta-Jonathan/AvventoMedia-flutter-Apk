import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class ShareController extends GetxController {
  RxString sharedText = ''.obs; // Observable variable to store shared text

  void shareText(String text) {
    sharedText.value = text;
  }
}