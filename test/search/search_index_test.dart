import 'package:avvento_media/apis/mock_presenter_repository.dart';
import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/controller/search_index_controller.dart';
import 'package:avvento_media/models/radiomodel/radio_podcast_model.dart';
import 'package:avvento_media/search/search_models.dart';
import 'package:avvento_media/search/search_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Source implements SearchSource {
  _Source(this.batches);
  final List<Object> batches; // Lists of entries, or an error to throw.

  @override
  Stream<List<SearchEntry>> load() async* {
    for (final b in batches) {
      if (b is Error || b is Exception) throw b;
      yield b as List<SearchEntry>;
    }
  }
}

SearchEntry entry(String title) => SearchEntry(
    kind: SearchKind.sermon, id: title, title: title, payload: title);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(Get.reset);

  group('entries from the app data', () {
    test('a presenter gives the presenter, its series and every sermon',
        () async {
      final p = await MockPresenterRepository().fetchPresenter('denis-mukaisa');
      final entries = SearchEntries.fromPresenter(p);

      expect(
          entries.where((e) => e.kind == SearchKind.presenter), hasLength(1));
      expect(entries.where((e) => e.kind == SearchKind.series), hasLength(1));
      expect(entries.where((e) => e.kind == SearchKind.sermon),
          hasLength(p.allSermons.length));

      final presenter = entries.first;
      expect(presenter.title, 'Ev. Denis Mukaisa');
      expect(presenter.subtitle, contains('Christian Living'));
      final series = entries.firstWhere((e) => e.kind == SearchKind.series);
      expect(series.presenter, 'Ev. Denis Mukaisa');
      expect(series.count, 3);
      final sermon = entries.firstWhere((e) => e.kind == SearchKind.sermon);
      expect(sermon.presenter, 'Ev. Denis Mukaisa');
      expect(sermon.source, SearchSources.radio);
    });

    test('a podcast and its episodes', () {
      final show = RadioPodcast(
          id: 'ot',
          title: 'Old Testament KJV Dramatized',
          description: '',
          author: 'Faith Comes By Hearing',
          email: '',
          art: '',
          isPublished: true,
          episodes: 748,
          categories: const [],
          episodesLink: '',
          lastUpdated: DateTime(2026));
      final entry = SearchEntries.fromPodcast(show);
      expect(entry.kind, SearchKind.podcast);
      expect(entry.subtitle, '748 episodes');
      expect(entry.keywords, contains('Faith Comes By Hearing'));
    });

    test('channel names become the sources in the filter sheet', () {
      expect(SearchEntries.sourceOfChannel(AppConstants.avventoMainChannel),
          SearchSources.main);
      expect(SearchEntries.sourceOfChannel(AppConstants.avventoMusicChannel),
          SearchSources.music);
      expect(SearchEntries.sourceOfChannel(AppConstants.avventoKidsChannel),
          SearchSources.kids);
      expect(SearchEntries.sourceOfChannel('other'), '');
    });

    test('YouTube lengths', () {
      expect(SearchEntries.parseIsoDuration('PT1H12M40S'),
          const Duration(hours: 1, minutes: 12, seconds: 40));
      expect(SearchEntries.parseIsoDuration('PT4M5S'),
          const Duration(minutes: 4, seconds: 5));
      expect(
          SearchEntries.parseIsoDuration('PT45S'), const Duration(seconds: 45));
      expect(SearchEntries.parseIsoDuration('PT'), isNull);
      expect(SearchEntries.parseIsoDuration(''), isNull);
    });
  });

  group('the index', () {
    test('fills in batches, once', () async {
      final index = SearchIndexController(
          source: _Source([
        [entry('a')],
        [entry('b'), entry('c')],
      ]));
      Get.put(index);

      await index.ensureLoaded();
      await index.ensureLoaded();
      expect(index.entries.map((e) => e.title), ['a', 'b', 'c']);
      expect(index.loading.value, isFalse);
    });

    test('keeps what loaded when a later step fails', () async {
      final index = SearchIndexController(
          source: _Source([
        [entry('a')],
        Exception('offline'),
      ]));
      Get.put(index);

      await index.ensureLoaded();
      expect(index.entries.map((e) => e.title), ['a']);
      expect(index.loading.value, isFalse);
    });
  });

  group('Recent searches', () {
    test('newest first, no repeats, kept to 20', () async {
      final index = Get.put(SearchIndexController(source: _Source([])));
      await index.addRecent('daniel');
      await index.addRecent('psalms');
      await index.addRecent('Daniel');
      expect(index.recent, ['Daniel', 'psalms']);

      for (var i = 0; i < 30; i++) {
        await index.addRecent('term $i');
      }
      expect(index.recent, hasLength(SearchIndexController.maxRecent));
      expect(index.recent.first, 'term 29');
    });

    test('ignores blanks, and can remove one or clear all', () async {
      final index = Get.put(SearchIndexController(source: _Source([])));
      await index.addRecent('   ');
      expect(index.recent, isEmpty);

      await index.addRecent('a');
      await index.addRecent('b');
      await index.removeRecent('a');
      expect(index.recent, ['b']);
      await index.clearRecent();
      expect(index.recent, isEmpty);
    });

    test('are remembered', () async {
      final first = SearchIndexController(source: _Source([]));
      await first.addRecent('desire of ages');

      final next = Get.put(SearchIndexController(source: _Source([])));
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      expect(next.recent, ['desire of ages']);
    });
  });
}
