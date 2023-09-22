import 'package:get/get_navigation/src/routes/get_route.dart';

import '../pages/listen_page.dart';
import '../pages/main_page.dart';
import '../pages/profile_page.dart';
import '../pages/schedule_page.dart';

class Routes {
  static String home = "/";
  static String listen = "/listen";
  static String schedule = "/schedule";
  static String profile = "/profile";

  static  String getHomeRoute() => home;
  static  String getListenRoute() => listen;
  static  String getScheduleRoute() => schedule;
  static  String getProfileRoute() => profile;

  static List<GetPage> routes = [
    GetPage(name: home, page: () => const MainPage()),
    GetPage(name: listen, page: () => const ListenPage()),
    GetPage(name: schedule, page: () => const SchedulePage()),
    GetPage(name: profile, page: () => const ProfilePage()),
  ];
}