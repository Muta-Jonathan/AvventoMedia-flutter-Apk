import '../apis/firestore_service_api.dart';
import '../apis/podcast_repository.dart';
import '../components/app_constants.dart';
import '../models/livetvmodel/livetv_model.dart';
import '../models/presenter_model.dart';
import '../models/radiomodel/podcast_episode_model.dart';
import '../models/radiomodel/radio_model.dart';
import '../models/radiomodel/radio_podcast_model.dart';
import '../models/youtubemodels/youtube_playlist_item_model.dart';
import '../models/youtubemodels/youtube_playlist_model.dart';
import 'search_models.dart';

/// Turns the app's content into [SearchEntry]s. Pure functions, so they can
/// be tested without Firebase.
abstract class SearchEntries {
  /// "AvventoProductions" → "Avvento Main".
  static String sourceOfChannel(String channelName) => switch (channelName) {
        AppConstants.avventoKidsChannel => SearchSources.kids,
        AppConstants.avventoMusicChannel => SearchSources.music,
        AppConstants.avventoMainChannel => SearchSources.main,
        _ => '',
      };

  static DateTime _at(int seconds) =>
      DateTime.fromMillisecondsSinceEpoch(seconds * 1000);

  /// The presenter, each series and each sermon (series parts and singles).
  static List<SearchEntry> fromPresenter(Presenter p) => [
        SearchEntry(
          kind: SearchKind.presenter,
          id: p.id,
          title: p.name,
          subtitle: [
            AppConstants.sermonCount(p.sermonCount),
            if (p.genre.isNotEmpty) p.genre,
          ].join(' · '),
          source: SearchSources.radio,
          cover: p.image,
          keywords: p.genre,
          count: p.sermonCount,
          publishedAt: p.latestAt > 0 ? _at(p.latestAt) : null,
          payload: p,
        ),
        for (final s in p.series)
          SearchEntry(
            kind: SearchKind.series,
            id: s.id,
            title: s.title,
            subtitle: '${p.name} · ${AppConstants.partCount(s.parts.length)}',
            presenter: p.name,
            source: SearchSources.radio,
            cover: s.cover,
            count: s.parts.length,
            publishedAt: s.parts.isEmpty
                ? null
                : _at(s.parts
                    .map((e) => e.publishedAt)
                    .reduce((a, b) => a > b ? a : b)),
            payload: (p, s),
          ),
        for (final e in p.allSermons)
          SearchEntry(
            kind: SearchKind.sermon,
            id: e.id,
            title: e.title,
            subtitle: p.name,
            presenter: p.name,
            source: SearchSources.radio,
            cover: e.art,
            keywords: e.description,
            publishedAt: _at(e.publishedAt),
            payload: (e, p.name),
          ),
      ];

  static SearchEntry fromPodcast(RadioPodcast show) => SearchEntry(
        kind: SearchKind.podcast,
        id: show.id,
        title: show.title,
        subtitle: AppConstants.episodeCount(show.episodes),
        source: SearchSources.radio,
        cover: show.art,
        keywords: show.author,
        count: show.episodes,
        publishedAt: show.lastUpdated,
        payload: show,
      );

  static List<SearchEntry> fromEpisodes(
          RadioPodcast show, List<PodcastEpisode> episodes) =>
      [
        for (final e in episodes)
          SearchEntry(
            kind: SearchKind.episode,
            id: e.id,
            title: e.title,
            subtitle: show.title,
            source: SearchSources.radio,
            cover: e.art,
            keywords: '${show.title} ${e.description}',
            publishedAt: _at(e.publishedAt),
            payload: (e, show.title),
          ),
      ];

  /// "PT1H12M40S" → 1:12:40.
  static Duration? parseIsoDuration(String iso) {
    final m = RegExp(r'^PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?$').firstMatch(iso);
    if (m == null || iso == 'PT') return null;
    int n(int i) => int.tryParse(m.group(i) ?? '') ?? 0;
    return Duration(hours: n(1), minutes: n(2), seconds: n(3));
  }

  static SearchEntry fromPlaylist(YoutubePlaylistModel p) => SearchEntry(
        kind: SearchKind.playlist,
        id: p.id,
        title: p.title,
        subtitle: '${sourceOfChannel(p.channelName)} · ${p.itemCount} videos',
        source: sourceOfChannel(p.channelName),
        cover: p.thumbnailUrl,
        keywords: p.description,
        count: p.itemCount,
        publishedAt: p.publishedAt,
        payload: p,
      );

  static SearchEntry fromVideo(YouTubePlaylistItemModel v) => SearchEntry(
        kind: SearchKind.video,
        id: v.id,
        title: v.title,
        subtitle: sourceOfChannel(v.channelName),
        source: sourceOfChannel(v.channelName),
        cover: v.thumbnailUrl,
        keywords: v.description,
        publishedAt: v.publishedAt,
        duration: parseIsoDuration(v.duration),
        payload: v,
      );

  /// Only a channel whose status says so is live; the rest are off air.
  static bool isOnAir(String status) => status == AppConstants.liveNow;

  static SearchEntry fromLiveTv(LiveTvModel t) => SearchEntry(
        kind: SearchKind.live,
        id: 'tv-${t.name}',
        title: t.name,
        live: isOnAir(t.status),
        subtitle:
            isOnAir(t.status) ? AppConstants.liveNowLabel : AppConstants.offAir,
        source: SearchSources.main,
        cover: t.imageUrl,
        keywords: t.description,
        payload: t,
      );

  static SearchEntry fromRadio(RadioModel r) => SearchEntry(
        kind: SearchKind.live,
        id: 'radio-${r.name}',
        title: r.name,
        live: isOnAir(r.status),
        subtitle:
            isOnAir(r.status) ? AppConstants.liveNowLabel : AppConstants.offAir,
        source: SearchSources.radio,
        cover: r.imageUrl,
        payload: r,
      );
}

/// Where the index gets its content: batches as they become available, so
/// results appear before everything has loaded.
abstract class SearchSource {
  Stream<List<SearchEntry>> load();
}

/// The app's own caches: presenters, podcasts and their episodes, and the
/// offline YouTube, live TV and radio data.
class AppSearchSource implements SearchSource {
  AppSearchSource({
    required this.presenters,
    required this.podcasts,
    FirestoreServiceAPI? firestore,
    PodcastRepository? podcastRepository,
  })  : _firestore = firestore,
        _podcastRepository = podcastRepository;

  final Future<List<Presenter>> Function() presenters;
  final Future<List<RadioPodcast>> Function() podcasts;
  final FirestoreServiceAPI? _firestore;
  final PodcastRepository? _podcastRepository;

  @override
  Stream<List<SearchEntry>> load() async* {
    final firestore = _firestore ?? FirestoreServiceAPI.instance;
    final repository = _podcastRepository ?? PodcastRepository.instance;

    // Each step may fail (offline, nothing cached): the rest still loads.
    Future<List<SearchEntry>> guarded(
        Future<List<SearchEntry>> Function() f) async {
      try {
        return await f();
      } catch (_) {
        return const [];
      }
    }

    yield await guarded(() async => [
          for (final p in await presenters()) ...SearchEntries.fromPresenter(p)
        ]);

    yield await guarded(() async => [
          for (final t in await firestore.loadLiveTvOffline())
            SearchEntries.fromLiveTv(t),
          for (final r in await firestore.loadRadioOffline())
            SearchEntries.fromRadio(r),
        ]);

    for (final channel in const [
      AppConstants.avventoMainChannel,
      AppConstants.avventoMusicChannel,
      AppConstants.avventoKidsChannel,
    ]) {
      yield await guarded(() async {
        final out = <SearchEntry>[];
        for (final playlist in await firestore.loadPlaylistsOffline(channel)) {
          out.add(SearchEntries.fromPlaylist(playlist));
          for (final v in await firestore.loadPlaylistItemsOffline(
              channel, playlist.id)) {
            out.add(SearchEntries.fromVideo(v));
          }
        }
        return out;
      });
    }

    List<RadioPodcast> shows = const [];
    try {
      shows = await podcasts();
    } catch (_) {}
    yield [for (final s in shows) SearchEntries.fromPodcast(s)];

    // The episodes, a show at a time; they are big (the Old Testament has 748).
    for (final show in shows) {
      yield await guarded(() async => SearchEntries.fromEpisodes(
          show, await repository.fetchEpisodes(show.id)));
    }
  }
}
