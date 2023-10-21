import 'package:avvento_media/models/livetvmodel/liveTvModel.dart';
import 'package:get/get.dart';

class LiveTvController extends GetxController {
  Rx<LiveTvModel?> selectedTv = Rx<LiveTvModel?>(null);

  void setSelectedTv(LiveTvModel liveTvModel) {
    selectedTv.value = liveTvModel;
  }
}
