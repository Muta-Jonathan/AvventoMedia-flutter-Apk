import 'package:avvento_radio/pages/podcast_page.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../pages/listen_page.dart';
import '../pages/main_page.dart';
import '../pages/online_radio_page.dart';
import '../pages/profile_page.dart';
import '../pages/watch_page.dart';

class Routes {
  static String home = "/";
  static String listen = "/listen";
  static String watch = "/watch";
  static String profile = "/profile";
  static String podcast = "/podcast";
  static String onlineRadio = "/onlineRadio";

  static  String getHomeRoute() => home;
  static  String getListenRoute() => listen;
  static  String getScheduleRoute() => watch;
  static  String getProfileRoute() => profile;
  static  String getPodcastRoute() => podcast;
  static  String getOnlineRadioRoute() => onlineRadio;

  static List<GetPage> routes = [
    GetPage(name: home, page: () => const MainPage()),
    GetPage(name: listen, page: () => const ListenPage()),
    GetPage(name: watch, page: () => const WatchPage()),
    GetPage(name: profile, page: () => const ProfilePage()),
    GetPage(name: podcast, page: () => const PodcastPage()),
    GetPage(name: onlineRadio, page: () => const OnlineRadioPage()),
  ];
}