import 'dart:io';

import 'package:flutter/material.dart' show ThemeMode;

import '../controller/settings_controller.dart' show RemovePlayed;

class AppConstants {
  static const String appName = "AvventoMedia";
  static const String radioName = "AvventoRadio";
  static const String nowPlaying = "Now Playing";
  static const String avventoSlogan = "Flying the Gospel to the Whole World!";
  static const String missNot = "Programs You shouldn't miss";
  static const String liveTv = "LIVE TV";
  static const String live = "LIVE";
  static const String liveSpoken = "Live";
  static const String avventoMusic = "Music";
  static const String avventoKids = "Kids";
  static const String avventoMain = "Avvento Productions";
  static const String liveNow = "LIVE NOW";
  static const String liveRadio = "Live Radio";
  static const String onAIR = "ON AIR";
  static const String pip = "Picture In Picture";
  static const String readMore = "Read more";
  static const String about = "About";
  static const String description = "Description";
  static const String exitApp = "Tap back again to exit!";
  static const String noInternet = "OOPS! IT SEEMS YOU'RE NOT CONNECTED TO THE INTERNET.";
  static const String showMore = "Show More";
  static const String from = "from";
  static const String share = "Share";
  static const String cancel = "Cancel";
  static const String searchContent = "Search Content";
  static const String noResults = "No results found.";
  static const String noSearchResults = "No search history yet";


  /// ***************** API ****************
  static const String highlightsAPI = "highlights";
  static const String liveTvAPI = "liveTv";
  static const String radioAPI = "radio";
  static const String apiKeysAPI = "apiKeys";
  static const String desiredPlaylistId = "desiredPlaylistId";
  static const String youtube = "youtube";
  static const String playlists = "playlists";
  static const String spreakerUrl = 'https://api.spreaker.com/v2/shows';
  static const azuracastAPI ='https://radio1.avventomedia.org/api/nowplaying/avventoradio';
  static const azuracastPodcastAPI ='https://radio1.avventomedia.org/api/station/avventoradio/podcasts';
  static const azuracastWebSocketAPI ='wss://radio1.avventomedia.org/api/live/nowplaying/websocket';
  static const avventoEmail ='avventohomeproductions@gmail.com';
  static const youtubePlaylistAPI ='https://www.googleapis.com/youtube/v3/playlists';
  static const youtubePlaylistItemsAPI ='https://www.googleapis.com/youtube/v3/playlistItems';
  static const youtubeVideoAPI ='https://www.googleapis.com/youtube/v3/videos';


/// ***************** PROFILE PAGE ****************
  static const String more = "More";
  static const String general = "GENERAL";
  static const String prayerRequest = "Prayer Request";
  static const String avventoWebsiteTitle = "Visit AvventoMedia Website";
  static const String avventoWebsite = "https://avventomedia.org";
  static const String avventoYoutubeChannel = "AvventoProductions";
  static const String avventoYoutubeChannelLink = "https://www.youtube.com/@AvventoProductions";
  static const String shareApp = "Share AvventoMedia App";
  static const String shareAppLinkAndroid = "https://play.google.com/store/apps/details?id=tv.avventomedia.app";
  static const String shareAppLinkIOS = "https://apps.apple.com/us/app/avventomedia/id6756179416";
  static String get shareAppLink => Platform.isIOS ? shareAppLinkIOS : shareAppLinkAndroid;
  static const String shareAppMessage = "Experience the joy of uplifting gospel music and inspiring stories with the AvventoMedia app! Download now and let your heart sing!";


  static const String radio = "RADIO";
  static const String webRadio = "Avvento Web Radio";
  static const String webRadioUrl = "https://avventomedia.org/avventoradio";

  static const String radioSchedule = "AvventoRadio Schedule";
  static const String radioScheduleUrl = "https://radio1.avventomedia.org/public/avventoradio/schedule";

  static const String podcastBroadcasts = "Podcasts Website";
  static const String podcastBroadcastsUrl = "https://radio1.avventomedia.org/public/1/podcasts";
  static const String avventoRadioTelegram = "Join Us on Telegram";
  static const String avventoRadioTelegramUrl = "https://t.me/avventoRadio";

  static const String youtubeChannels = "YOUTUBE CHANNELS";
  static const String musicYoutubeChannel = "AvventoMusic";
  static const String musicYoutubeChannelLink = "https://www.youtube.com/@avventomusic";
  static const String kidsYoutubeChannel = "AvventoKids";
  static const String kidsYoutubeChannelLink = "https://www.youtube.com/@avventokids";

  static const String preferences = "PREFERENCES";
  static const String notifications = "Allow notifications";
  static const String darkMode = "Dark Mode";
  static const String darkModeMessage =
      "Auto follows your phone’s system setting.";

  static const String tiktok = "Follow us on Tiktok";
  static const String tiktokWebsite = "https://www.tiktok.com/@avventomedia_official";
  static const String facebook = "Like us on Facebook";
  static const String facebookWebsite = "https://www.facebook.com/AvventoProductions/";

  static const String report = "Report a Problem";

  static const String kofiName = "avventomedia";
  static const String kofiText = "Donate to AvventoMedia"
      "";
  static const String donateTitle = "Give a Lift to the Gospel 🚀🌍";
  static const String donateMessage = "Your contribution means a lot as we fly the gospel to the whole world. Please consider donating to us today.";
  static const String donateButton = "Support Us on YouTube";
  static const String avventoJoinYtUrl = "https://www.youtube.com/@AvventoProductions/join";


  /// ***************** PRAYER REQUEST PAGE ****************
  static const String prayerHeadline = "How can we pray for you?";
  static const String prayerSubtitle =
      "Share your request and our team will pray with you.";
  static const String prayerYourDetails = "YOUR DETAILS";
  static const String prayerPrayForSection = "PRAY FOR";
  static const String prayerYourRequest = "YOUR REQUEST";
  static const String prayerHintName = "Full name";
  static const String prayerHintPhone = "Phone number";
  static const String prayerSearchCountry = "Search country";
  static const String prayerHintEmail = "Email address";
  static const String prayerHintPrayFor = "Who or what should we pray for?";
  static const String prayerHintMessage = "Write your prayer request…";
  static const List<String> prayerTopics = [
    "Myself", "Family", "Health", "Work", "Finances", "Church",
  ];
  static const int prayerMaxLength = 1000;
  static const String prayerErrorName = "Enter your name (letters only)";
  static const String prayerErrorPhone = "Enter your phone number";
  static const String prayerErrorEmail = "Enter a valid email address";
  static const String prayerErrorPrayFor = "Tell us who or what to pray for";
  static const String prayerErrorMessage = "Write your prayer request";
  static const String prayerSend = "Send Request";
  static const String prayerSending = "Sending…";
  static const String prayerSent = "Request sent";
  static String prayerSentMessage(String firstName) =>
      "Hey $firstName, your prayer request was sent successfully. "
      "We'll be praying with you.";
  static const String prayerSendAnother = "Send another request";
  static const String prayerRequestError =
      "Couldn't send your prayer request. Please try again.";


  /// ***************** SHARE MESSAGE ****************
  static const String shareStream = "Take a look at AvventoRadio 💫 streaming now";
  static const String webTvUrl = "https://avventomedia.org/watch-live";

  /// ***************** PODCAST PAGE ****************
  static const String podcastThumbImage = "https://avventomedia.org/wp-content/uploads/2024/05/podcast_thumbnail.png";
  static const String podcasts = 'Podcasts';
  static const String listenTitle = 'Listen';
  static const String upNext = 'Up next';
  static const String onNowLabel = 'ON NOW';
  static const String upNextLabel = 'UP NEXT';
  static const String laterLabel = 'LATER';
  static const String continueListening = 'Continue listening';
  static const String seriesAndBible = 'Series & Bible';
  static const String dailyAndWeekly = 'Daily & weekly shows';
  static const String playsInOrder = 'Plays in order';
  static const String newestFirstTag = 'Newest first';
  static const String liveBadge = 'LIVE';
  static const String listenLive = 'Listen live';
  static const String playingLive = 'Playing live';
  static const String seeAll = 'See all';
  static const String search = 'Search';
  static const String playLiveRadio = 'Play live radio';
  static const String pauseLiveRadio = 'Pause live radio';
  static const String offline = 'Offline';
  static const String showingDownloadsOnly = 'Showing downloads only.';
  static const String openDownloads = 'Open downloads';
  static const String liveNowLabel = 'Live now';
  static const String offAir = 'Off air';
  static const String loading = 'Loading';
  static const String searchTitle = 'Search';
  static const String searchHint = 'Presenters, podcasts, sermons, videos';
  static const String recent = 'Recent';
  static const String browse = 'Browse';
  static const String topResult = 'Top result';
  static const String filters = 'Filters';
  static const String reset = 'Reset';
  static const String downloadedOnly = 'Downloaded only';
  static const String sermonsAndEpisodes = 'Sermons & episodes';
  static const String videosSection = 'Videos';
  static const String liveSection = 'Live';
  static const String noResultsTitle = 'No results';
  static const String clearFilters = 'Clear filters';
  static const String checkSpelling = 'Check the spelling or try another word.';
  static const String removeRecent = 'Remove from recent searches';
  static const String bible = 'Bible';
  static String nothingHere(String q) => 'Nothing for “$q” in this list. Try another word.';
  static const String searchPlaylists = 'Search playlists';
  static const String searchThisPlaylist = 'Search this playlist';
  static const String searchLive = 'Search live channels';
  static String nothingFor(String q) => 'Nothing for “$q” with these filters.';
  static String noMatchFor(String q) => 'Nothing for “$q”. Check the spelling or try another word.';
  static String showResults(int n) => n == 1 ? 'Show 1 result' : 'Show $n results';
  static String sermonsMatch(int n) => n == 1 ? '1 sermon matches' : '$n sermons match';
  static String filtersCount(int n) => n == 0 ? 'Filters' : 'Filters, $n active';
  static String removeFilter(String label) => 'Remove filter $label';
  static String searchResultsFor(String q) => 'Results for $q';
  static const String navWatch = 'Watch';
  static const String navListen = 'Listen';
  static const String navSearch = 'Search';
  static const String navMore = 'More';
  static const String openPlayer = 'Open player';
  static const String liveSubtitle = 'AvventoRadio · Live';
  static const String noConnection = 'No connection';
  static const String podcastsLoadFailed = "Couldn't load podcasts";
  static String yourTime(String zone) =>
      zone.isEmpty ? 'Your time' : 'Your time · $zone';
  static String seeAllCount(int n) => 'See all $n';

  /// ***************** PADDING ****************
  static const double leftMain = 20;
  static const double rightMain = 20;

  /// ***************** HEIGHT ****************
  static const double height30 = 30;
  static const double height40 = 40;
  static const double height250 = 250;

  /// ***************** WIDTH ****************
  static const double width40 = 40;

  /// ***************** FONT SIZE ****************
  static const double fontSize18 = 18;
  static const double fontSize20 = 20;

  /// ***************** CHANNEL NAMES ****************
  static const String avventoKidsChannel = "AvventoKids";
  static const String avventoMusicChannel = "AvventoMusic";
  static const String avventoMainChannel = "AvventoProductions";

  /// ***************** LIBRARY ****************
  static const String myLibrary = "MY LIBRARY";

  // More tab
  static const String supportUs = "Support AvventoMedia";
  static const String supportUsSubtitle = "Tap to see donation options";
  static const String themeAuto = "Auto";
  static const String themeOn = "On";
  static const String themeOff = "Off";
  static const String allowNotifications = "Allow Notifications";
  static const String allowMiniPlayer = "Allow Mini Player";
  static const String followUs = "FOLLOW US";
  static const String getTheApp = "GET THE APP";
  static const String googlePlayStore = "Google Play Store";
  static const String appleAppStore = "Apple App Store";
  static const String supportAndLegal = "SUPPORT & LEGAL";
  static const String termsOfService = "Terms of Service";
  static const String privacyPolicy = "Privacy Policy";
  static const String termsUrl = "https://avventomedia.org/terms/";
  static const String privacyUrl = "https://avventomedia.org/privacy/";
  static const String notificationsDenied =
      "Notifications are off for AvventoMedia in your phone's settings";
  static const String favorites = "Favorites";
  static const String myPlaylists = "My Playlists";
  // Home chips
  static const String homeCatalog = "Catalog";
  static const String homePlaylists = "Playlists";
  static const String newPlaylist = "New Playlist";
  static const String save = "+ Save";
  static const String addToFavorites = "Add to Favorites";
  static const String saveToPlaylist = "Save to Playlist";
  static const String noFavorites = "No favorites yet";
  static const String noPlaylists = "No playlists yet";
  static const String noFavoritesMessage =
      "Tap the heart on any video or podcast to keep it here.";
  static const String noPlaylistsMessage =
      "Create a playlist to collect the videos and podcasts you love.";
  static const String emptyPlaylist = "This playlist is empty";
  static const String emptyPlaylistMessage =
      "Tap Save on a video or podcast and choose this playlist.";
  static const String createPlaylist = "Create";
  static const String alreadySaved = "Already saved";
  static const String savedToFavorites = "Added to Favorites";
  static const String removedFromFavorites = "Removed from Favorites";
  static const String savedToPlaylist = "Saved to playlist";
  static const String playlistNameHint = "Playlist name";
  static String playlistCreated(String title) => 'Playlist "$title" created';
  static String playlistDeleted(String title) => 'Playlist "$title" deleted';
  static const String undo = "Undo";
  static const String playlistNameEmpty = "Please enter a playlist name";
  // Podcast feed & downloads
  static const String podcastLabel = "PODCAST";
  static const String episodes = "Episodes";
  static const String playAll = "Play All";
  static const String pause = "Pause";
  static const String resume = "Resume";
  static const String shuffle = "Shuffle";
  static const String newest = "Newest";
  static const String oldest = "Oldest";
  static const String inOrder = "In order";
  static const String newestFirst = "Newest first";
  static const String oldestFirst = "Oldest first";
  static const String sort = "Sort";
  static const String part = "Part";
  static const String chapter = "Chapter";
  static const String bibleLabel = "BIBLE";
  static const String egwLabel = "ELLEN G. WHITE";
  static const String jumpToBook = "Jump to book";
  static const String presenters = "Presenters";
  static const String presenterLabel = "PRESENTER";
  static const String allGenres = "All";
  static const String searchPresenters = "Search presenters";
  static const String clearSearch = "Clear search";
  static const String noPresentersFound = "No presenters found";
  static const String presentersLoadFailed = "Couldn't load presenters";
  static const String playLatest = "Play latest";
  static const String series = "Series";
  static const String singleSermons = "Single sermons";
  static const String goToPresenter = "Go to presenter";
  static const String newSermon = "new sermon";
  static const String sermonsTab = "Sermons";
  static const String seriesLabel = "SERIES";
  static const String playingFrom = "PLAYING FROM";
  static const String closePlayer = "Close player";
  static const String previous = "Previous";
  static const String next = "Next";
  static const String replay = "Replay";
  static const String speed = "Speed";
  static const String playbackSpeed = "Playback speed";
  static const String favorite = "Favorite";
  static const String saveLabel = "Save";
  static const String switchTimeHint = "Switches between time left and length";
  static const String sharePodcastMessage =
      "Come join me, listen to this podcast on AvventoMedia 💫";
  static const String oldTestament = "Old Testament";
  static const String newTestament = "New Testament";
  static const String played = "Played";
  static const String play = "Play";
  static const String today = "Today";
  static const String newLabel = "NEW";
  static const String moreLower = "more";
  static const String markPlayed = "Mark as played";
  static const String markUnplayed = "Mark as unplayed";
  static const String download = "Download";
  static const String downloads = "Downloads";
  static const String removeDownload = "Remove download";
  static const String cancelDownload = "Cancel download";
  static const String retryDownload = "Retry download";
  static const String queued = "Queued";
  static const String downloadedLabel = "Downloaded";
  static const String failed = "Failed";
  static const String notDownloaded = "Not downloaded";
  static const String notAvailableOffline = "Not available offline";
  static const String remove = "Remove";
  static const String saveToLibrary = "Save to library";
  static const String removeFromLibrary = "Remove from library";
  static const String addToPlaylist = "Add to playlist";
  static const String noDownloads = "No downloads yet";
  static const String noDownloadsMessage =
      "Tap the download icon on any episode to listen offline, even without data.";
  static const String downloading = "Downloading";
  static const String episodesLoadFailed = "Couldn't load episodes";
  static const String episodesLoadFailedMessage =
      "Check your connection and try again. Downloaded episodes still play offline.";
  static const String noEpisodes = "No episodes yet";
  static const String retry = "Retry";
  static const String waitingForWifi =
      "Waiting for Wi-Fi. Wi-Fi only downloads are on in More";
  static const String downloadNow = "Download now";
  static const String playingOffline = "Playing offline";
  static const String waitingForWifiShort = "Waiting for Wi-Fi";
  static const String waiting = "Waiting";
  static const String paused = "Paused";
  static const String pauseAll = "Pause all";
  static const String resumeAll = "Resume all";
  static const String edit = "Edit";
  static const String done = "Done";
  static const String delete = "Delete";
  static const String selectAll = "Select all";
  static const String clear = "Clear";
  static const String selectEpisodes = "Select episodes";
  static const String all = "All";
  static const String unplayed = "Unplayed";
  static const String inProgress = "In progress";
  static const String episodesLegend = "Episodes";
  static const String otherApps = "Other apps";
  static const String browsePodcasts = "Browse podcasts";
  static const String downloadsTitle = "DOWNLOADS";
  static const String downloadWifiOnly = "Download over Wi-Fi only";
  static const String removePlayed = "Remove played episodes";
  static const String removePlayedMessage =
      "Downloaded episodes you have finished are deleted automatically to free up space.";
  static String removePlayedValue(RemovePlayed v) => switch (v) {
        RemovePlayed.off => themeOff,
        RemovePlayed.day => "24 hours",
        RemovePlayed.month => "30 days",
        RemovePlayed.twoMonths => "60 days",
      };
  static String themeLabel(ThemeMode m) => switch (m) {
        ThemeMode.system => themeAuto,
        ThemeMode.dark => themeOn,
        ThemeMode.light => themeOff,
      };
  static String removePlayedOption(RemovePlayed v) =>
      v == RemovePlayed.off ? themeOff : "After ${removePlayedValue(v)}";
  static String usedByApp(String size) => '$size used by AvventoMedia';
  static String freeSpace(String size) => '$size free';
  static String downloadingCount(int n) => 'DOWNLOADING · $n';
  static String selectedInfo(int n, String size) => '$n selected · $size';
  static String downloadsRemoved(int n) => 'Removed $n downloads';
  static String downloaded(String title) => 'Downloaded "$title"';
  static String downloadFailed(String title) => 'Couldn\'t download "$title"';
  static String downloadRemoved(String title) => 'Removed "$title" from downloads';
  static String minLeft(int minutes) => '$minutes min left';
  static String minutes(int minutes) => '$minutes min';
  static String percent(double fraction) => '${(fraction * 100).round()}%';
  static String downloadAll(int n) => 'Download all · $n';
  static String downloadingPercent(double fraction) =>
      'Downloading ${percent(fraction)}';
  static String removeDownloadsQuestion(int n) =>
      n == 1 ? 'Remove 1 download?' : 'Remove $n downloads?';
  static String episodeCount(int n) => n == 1 ? '1 episode' : '$n episodes';
  static String chapterCount(int n) => n == 1 ? '1 chapter' : '$n chapters';
  static String chapterShort(int n) => 'Ch. $n';
  static String noResultsFor(String q) => 'No results for “$q”.';
  static String sermonCount(int n) => n == 1 ? '1 sermon' : '$n sermons';
  static String seriesCount(int n) => '$n series';
  static String partCount(int n) => n == 1 ? '1 part' : '$n parts';
  static String partsOf(int done, int total) => '$done of $total';
  static String listenToPresenter(String name) =>
      'Listen to $name on AvventoMedia 💫';
  static String speedSemantics(String speed) => 'Playback speed, $speed';
  static String timeLeftSemantics(Duration d) => '${_spoken(d)} left';
  static String lengthSemantics(Duration d) => 'Length ${_spoken(d)}';
  static String _spoken(Duration d) {
    final h = d.inHours, m = d.inMinutes % 60, s = d.inSeconds % 60;
    return [
      if (h > 0) '$h ${h == 1 ? 'hour' : 'hours'}',
      if (m > 0) '$m ${m == 1 ? 'minute' : 'minutes'}',
      if (h == 0 && (s > 0 || m == 0)) '$s ${s == 1 ? 'second' : 'seconds'}',
    ].join(' ');
  }
  static String chaptersAbbrev(int n) => '$n ch.';
}
