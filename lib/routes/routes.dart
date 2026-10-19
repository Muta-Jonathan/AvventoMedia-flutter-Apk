import '../pages/downloads_page.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../pages/favorites_page.dart';
import '../pages/listen_page.dart';
import '../pages/live_tv_list_page.dart';
import '../pages/main_page.dart';
import '../pages/my_playlists_page.dart';
import '../pages/podcast_episode_list_page.dart';
import '../pages/presenter_page.dart';
import '../pages/presenters_page.dart';
import '../pages/series_page.dart';
import '../pages/podcast_list_page.dart';
import '../pages/prayer_request_page.dart';
import '../pages/profile_page.dart';
import '../pages/search_page.dart';
import '../pages/watch_page.dart';
import '../pages/youtube_kids_playlist_item_page.dart';
import '../pages/youtube_kids_playlist_page.dart';
import '../pages/youtube_main_playlist_item_page.dart';
import '../pages/youtube_main_playlist_page.dart';
import '../pages/youtube_music_playlist_item_page.dart';
import '../pages/youtube_music_playlist_page.dart';
import '../pages/youtube_watch_page.dart';

class Routes {
  static String home = "/";
  static String listen = "/listen";
  static String profile = "/profile";
  static String podcastList = "/podcastList";
  static String podcastEpisodeList = "/podcastEpisode/List";
  static String presenters = "/presenters";
  static String presenter = "/presenter";
  static String presenterSeries = "/presenter/series";
  static String liveTv = "/liveTv";
  static String liveTvList = "/liveTv/list";
  static String prayerRequest = "/prayerRequest";
  static String youtubeMusicPlaylist = "/youtube/music/playlist";
  static String youtubeMusicPlaylistItem = "/youtube/music/playlist/item";
  static String youtubeKidsPlaylist = "/youtube/kids/playlist";
  static String youtubeKidsPlaylistItem = "/youtube/kids/playlist/item";
  static String youtubeMainPlaylist = "/youtube/avventoProductions/playlist";
  static String youtubeMainPlaylistItem = "/youtube/avventoProductions/playlist/item";
  static String watchYoutube = "/watch/youtube/video";
  static String search = "/search";
  static String libraryFavorites = "/library/favorites";
  static String libraryPlaylists = "/library/playlists";
  static String downloads = "/library/downloads";

  static  String getHomeRoute() => home;
  static  String getListenRoute() => listen;
  static  String getProfileRoute() => profile;
  static  String getPodcastListRoute() => podcastList;
  static  String getPodcastEpisodeListRoute() => podcastEpisodeList;
  static  String getPresentersRoute() => presenters;
  /// Pass the presenter id as the route argument.
  static  String getPresenterRoute() => presenter;
  /// Pass (presenter, series) as the route argument.
  static  String getPresenterSeriesRoute() => presenterSeries;
  static  String getLiveTvRoute() => liveTv;
  static  String getLiveTvListRoute() => liveTvList;
  static  String getPrayerRequestRoute() => prayerRequest;
  static  String getYoutubeMusicPlaylistRoute() => youtubeMusicPlaylist;
  static  String getYoutubeMusicPlaylistItemRoute() => youtubeMusicPlaylistItem;
  static  String getYoutubeKidsPlaylistRoute() => youtubeKidsPlaylist;
  static  String getYoutubeMainPlaylistRoute() => youtubeMainPlaylist;
  static  String getYoutubeKidsPlaylistItemRoute() => youtubeKidsPlaylistItem;
  static  String getYoutubeMainPlaylistItemRoute() => youtubeMainPlaylistItem;
  static  String getWatchYoutubeRoute() => watchYoutube;
  static  String getSearchRoute() => search;
  static  String getLibraryFavoritesRoute() => libraryFavorites;
  static  String getLibraryPlaylistsRoute() => libraryPlaylists;
  static  String getDownloadsRoute() => downloads;

  static List<GetPage> routes = [
    GetPage(name: home, page: () => const MainPage()),
    GetPage(name: listen, page: () => const ListenPage()),
    GetPage(name: profile, page: () => const ProfilePage()),
    GetPage(name: podcastList, page: () => const PodcastListPage()),
    GetPage(name: podcastEpisodeList, page: () => const PodcastEpisodeListPage()),
    GetPage(name: presenters, page: () => const PresentersPage()),
    GetPage(name: presenter, page: () => const PresenterPage()),
    GetPage(name: presenterSeries, page: () => const SeriesPage()),
    GetPage(name: liveTv, page: () => const WatchPage()),
    GetPage(name: liveTvList, page: () => const LiveTvListPage()),
    GetPage(name: prayerRequest, page: () => const PrayerRequestPage()),
    GetPage(name: youtubeMusicPlaylist, page: () => const YoutubeMusicPlaylistPage()),
    GetPage(name: youtubeMusicPlaylistItem, page: () => const YoutubeMusicPlaylistItemPage()),
    GetPage(name: youtubeKidsPlaylist, page: () => const YoutubeKidsPlaylistPage()),
    GetPage(name: youtubeMainPlaylist, page: () => const YoutubeMainPlaylistPage()),
    GetPage(name: youtubeKidsPlaylistItem, page: () => const YoutubeKidsPlaylistItemPage()),
    GetPage(name: youtubeMainPlaylistItem, page: () => const YoutubeMainPlaylistItemPage()),
    GetPage(name: watchYoutube, page: () => const YoutubeWatchPage()),
    GetPage(name: search, page: () => const SearchPage()),
    GetPage(name: libraryFavorites, page: () => const FavoritesPage()),
    GetPage(name: libraryPlaylists, page: () => const MyPlaylistsPage()),
    GetPage(name: downloads, page: () => const DownloadsPage()),
  ];
}