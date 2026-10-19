import 'dart:convert';

import 'package:avvento_media/apis/mock_presenter_repository.dart';
import 'package:avvento_media/apis/presenter_repository.dart';
import 'package:avvento_media/controller/presenters_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, dynamic> episodeJson(String id, String title, int publishAt) => {
      'id': id,
      'title': title,
      'description': '',
      'playlist_media': {'artist': 'Pr. Test', 'album': ''},
      'publish_at': publishAt,
      'links': {
        'download': 'https://example.org/$id.mp3',
        'public': '',
        'media': ''
      },
      'is_published': true,
      'art': '',
    };

void main() {
  tearDown(Get.reset);

  test('without the API switch the mock is used', () {
    expect(PresenterRepository.create(), isA<MockPresenterRepository>());
  });

  test('mock presenters: summaries by sermon count, details with sermons',
      () async {
    final repo = MockPresenterRepository();
    final list = await repo.fetchPresenters();
    expect(list.first.name, 'Pr. Okello Samuel');
    expect(list.map((p) => p.name), contains('Sis. Kisakye Florence'));
    expect(list.every((p) => p.series.isEmpty && p.singles.isEmpty), isTrue);

    final kiiza = await repo.fetchPresenter('kiiza-samuel-akiki');
    final parts = kiiza.series.single.parts.map((e) => e.title).toList();
    expect(parts.first, 'Victory Amidst Troubles Pt. 1');
    expect(parts.last, 'Victory Amidst Troubles Pt. 6');
    expect(kiiza.allSermons, hasLength(6));
  });

  test('API repository parses summaries and a presenter', () async {
    final repo = ApiPresenterRepository('https://api.example.org/',
        client: MockClient((r) async {
      if (r.url.path == '/presenters') {
        return http.Response(
            json.encode([
              {
                'id': 'a',
                'name': 'Pr. A',
                'genre': 'Prayer',
                'sermon_count': 2
              },
              {
                'id': 'b',
                'name': 'Ev. B',
                'genre': 'Health',
                'sermon_count': 9
              },
            ]),
            200);
      }
      return http.Response(
          json.encode({
            'id': 'b',
            'name': 'Ev. B',
            'sermon_count': 9,
            'series_count': 1,
            'series': [
              {
                'id': 's',
                'title': 'Series',
                'parts': [episodeJson('p1', 'Series Pt. 1', 10)],
              }
            ],
            'singles': [
              episodeJson('old', 'Old', 100),
              episodeJson('new', 'New', 200),
            ],
          }),
          200);
    }));

    final list = await repo.fetchPresenters();
    expect(list.map((p) => p.id), ['b', 'a']); // Most sermons first.

    final b = await repo.fetchPresenter('b');
    expect(b.series.single.parts.single.title, 'Series Pt. 1');
    expect(b.singles.map((e) => e.id), ['new', 'old']); // Newest first.
    expect(b.latest?.id, 'new');
  });

  test('controller finds a presenter by an episode artist', () async {
    final controller =
        Get.put(PresentersController(repository: MockPresenterRepository()));
    await Future<void>.delayed(Duration.zero);
    expect(controller.byName('ev. denis mukaisa')?.id, 'denis-mukaisa');
    expect(controller.byName('Amazing Facts'), isNull);
    expect(controller.byName(''), isNull);
  });
}
