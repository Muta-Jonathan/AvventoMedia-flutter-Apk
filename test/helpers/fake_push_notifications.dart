import 'package:avvento_media/controller/settings_controller.dart';

/// In-memory [PushNotifications]; [grant] decides the permission prompt.
class FakePushNotifications implements PushNotifications {
  FakePushNotifications({this.grant = true});

  bool grant;
  @override
  bool enabled = false;

  @override
  Future<bool> enable() async => enabled = grant;

  @override
  Future<void> disable() async => enabled = false;
}
