import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus as void Function(List<ConnectivityResult> event)?);
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    if(connectivityResult == ConnectivityResult.none) {
      Get.rawSnackbar(
        messageText: const TextOverlay(label: AppConstants.noInternet, color: Colors.white),
        isDismissible: false,
        duration: const Duration(days: 1),
        backgroundColor: Colors.red[400]!,
        icon: const Icon(CupertinoIcons.wifi_exclamationmark, color: Colors.white),
        margin: EdgeInsets.zero,
        snackStyle: SnackStyle.GROUNDED,
        snackPosition: SnackPosition.TOP
      );
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    }
  }
}