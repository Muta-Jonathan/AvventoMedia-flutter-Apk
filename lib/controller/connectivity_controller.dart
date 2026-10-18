import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

/// Whether the device is offline, for offline row styles and banners.
class ConnectivityController extends GetxController {
  /// [changes] and [check] exist for tests.
  ConnectivityController({
    Stream<List<ConnectivityResult>>? changes,
    Future<List<ConnectivityResult>> Function()? check,
  })  : _changes = changes,
        _check = check;

  final Stream<List<ConnectivityResult>>? _changes;
  final Future<List<ConnectivityResult>> Function()? _check;
  StreamSubscription? _sub;

  /// Starts false: unknown counts as online.
  final RxBool offline = false.obs;

  /// Safe to call when the controller isn't registered (tests, early startup).
  static bool get isOffline =>
      Get.isRegistered<ConnectivityController>() &&
      Get.find<ConnectivityController>().offline.value;

  @override
  void onInit() {
    super.onInit();
    try {
      final check = _check ?? Connectivity().checkConnectivity;
      check().then(_update, onError: (_) {});
      _sub = (_changes ?? Connectivity().onConnectivityChanged)
          .listen(_update, onError: (_) {});
    } catch (_) {
      // No platform plugin.
    }
  }

  void _update(List<ConnectivityResult> result) =>
      offline.value = result.every((r) => r == ConnectivityResult.none);

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
