import 'package:avvento_media/pages/podcast_page.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../pages/listen_page.dart';
import '../pages/main_page.dart';
import '../pages/online_radio_page.dart';
import '../pages/podcast_episode_list_page.dart';
import '../pages/podcast_list_page.dart';
import '../pages/prayer_request_page.dart';
import '../pages/profile_page.dart';
import '../pages/watch_page.dart';

class Routes {
  static String home = "/";
  static String listen = "/listen";
  static String watch = "/watch";
  static String profile = "/profile";
  static String podcast = "/podcast";
  static String podcastList = "/podcastList";
  static String podcastEpisodeList = "/podcastEpisodeList";
  static String onlineRadio = "/onlineRadio";
  static String liveTv = "/liveTv";
  static String prayerRequest = "/prayerRequest";

  static  String getHomeRoute() => home;
  static  String getListenRoute() => listen;
  static  String getScheduleRoute() => watch;
  static  String getProfileRoute() => profile;
  static  String getPodcastRoute() => podcast;
  static  String getPodcastListRoute() => podcastList;
  static  String getPodcastEpisodeListRoute() => podcastEpisodeList;
  static  String getOnlineRadioRoute() => onlineRadio;
  static  String getLiveTvRoute() => liveTv;
  static  String getPrayerRequestRoute() => prayerRequest;

  static List<GetPage> routes = [
    GetPage(name: home, page: () => const MainPage()),
    GetPage(name: listen, page: () => const ListenPage()),
    GetPage(name: watch, page: () => const WatchPage()),
    GetPage(name: profile, page: () => const ProfilePage()),
    GetPage(name: podcast, page: () => const PodcastPage()),
    GetPage(name: podcastList, page: () => const PodcastListPage()),
    GetPage(name: podcastEpisodeList, page: () => const PodcastEpisodeListPage()),
    GetPage(name: onlineRadio, page: () => const OnlineRadioPage()),
    GetPage(name: liveTv, page: () => const WatchPage()),
    GetPage(name: prayerRequest, page: () => const PrayerRequestPage()),
  ];
}