import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'audio_player_controller.dart';

/// Counts open dialogs / bottom sheets on the root navigator.
class PopupRouteObserver extends NavigatorObserver {
  final RxInt openPopups = 0.obs;

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route is PopupRoute) runOutsideBuild(() => openPopups.value++);
  }

  @override
  void didPop(Route route, Route? previousRoute) => _closed(route);

  @override
  void didRemove(Route route, Route? previousRoute) => _closed(route);

  void _closed(Route route) {
    if (route is! PopupRoute) return;
    runOutsideBuild(() {
      if (openPopups.value > 0) openPopups.value--;
    });
  }
}
