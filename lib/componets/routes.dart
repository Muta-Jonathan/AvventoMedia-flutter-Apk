import 'package:get/get_navigation/src/routes/get_route.dart';

import '../navpages/listen_page.dart';
import '../navpages/main_page.dart';
import '../navpages/profile_page.dart';
import '../navpages/schedule_page.dart';

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
    GetPage(name: home, page: () => MainPage()),
    GetPage(name: listen, page: () => ListenPage()),
    GetPage(name: schedule, page: () => SchedulePage()),
    GetPage(name: profile, page: () => ProfilePage()),
  ];
}