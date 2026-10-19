import '../models/presenter_model.dart';
import '../models/radiomodel/podcast_episode_model.dart';
import 'presenter_repository.dart';

/// Sample presenters until the presenters API exists. Sermons borrow real
/// AzuraCast audio (Denis Mukaisa's devotions, Eriiso Ly'Obunnabbi) so play
/// and download can be tried.
class MockPresenterRepository implements PresenterRepository {
  static const _base =
      'https://radio1.avventomedia.org/api/station/avventoradio/public/podcast';
  static const _devotions = '1f1ca6a2-a53b-661c-8d63-3598d4d2bfd9';
  static const _eriiso = '1f1ca6a1-2b1e-66be-8d63-15dd181915de';

  /// (show, episode) pairs with public audio.
  static const _audio = [
    (_devotions, '1f1ca6b5-be6d-6a64-b943-0d9cd50b8aa6'),
    (_devotions, '1f1ca6b5-a085-6c5e-b943-0d9cd50b8aa6'),
    (_devotions, '1f1ca6b5-95d8-62b6-b943-0d9cd50b8aa6'),
    (_devotions, '1f1ca6b5-8a3e-678e-b943-0d9cd50b8aa6'),
    (_devotions, '1f1ca6b5-7e96-680a-b943-0d9cd50b8aa6'),
    (_devotions, '1f1ca6b5-756e-6a16-b943-0d9cd50b8aa6'),
    (_eriiso, '1f1ca6b0-001d-676c-b943-0d9cd50b8aa6'),
    (_eriiso, '1f1ca6af-f5fc-683c-b943-0d9cd50b8aa6'),
    (_eriiso, '1f1ca6af-ec99-6128-b943-0d9cd50b8aa6'),
    (_eriiso, '1f1ca6af-e301-60ac-b943-0d9cd50b8aa6'),
    (_eriiso, '1f1ca6af-d9a5-61ac-b943-0d9cd50b8aa6'),
    (_eriiso, '1f1ca6af-d008-6900-b943-0d9cd50b8aa6'),
  ];

  static const _denisArt = '$_base/$_devotions/art-1792269279.jpg';
  static const _matovuArt = '$_base/$_eriiso/art-1792269237.jpg';

  static int _next = 0;

  static PodcastEpisode _sermon(String id, String title, String presenter,
      {String summary = '', int daysAgo = 0, String art = ''}) {
    final (show, episode) = _audio[_next++ % _audio.length];
    final published = DateTime.now().subtract(Duration(days: daysAgo));
    return PodcastEpisode(
      id: 'mock-$id',
      title: title,
      description: summary,
      playlistMediaArtist: presenter,
      playlistMediaAlbum: presenter,
      publishedAt: published.millisecondsSinceEpoch ~/ 1000,
      downloadLink: '$_base/$show/episode/$episode/download.mp3',
      publicLink: '',
      isPublished: true,
      art: art,
      media: '',
    );
  }

  static final List<Presenter> _presenters = _build();

  static List<Presenter> _build() {
    const kiiza = 'Bro. Kiiza Samuel Akiki';
    const michael = 'Bro. Ahimbisibwe Michael';
    const denis = 'Ev. Denis Mukaisa';
    const matovu = 'Ev. Jonathan Matovu';

    Presenter summary(String id, String name, int sermons, String genre,
            {String image = ''}) =>
        Presenter(
            id: id,
            name: name,
            image: image,
            genre: genre,
            sermonCount: sermons,
            seriesCount: 0);

    return [
      summary('okello-samuel', 'Pr. Okello Samuel', 37, 'Prophecy'),
      Presenter(
        id: 'denis-mukaisa',
        name: denis,
        image: _denisArt,
        genre: 'Christian Living',
        sermonCount: 34,
        seriesCount: 9,
        series: [
          SermonSeries(
            id: 'final-forerunner',
            title: 'Final Forerunner',
            cover: _denisArt,
            parts: [
              for (var i = 1; i <= 3; i++)
                _sermon('ff$i', 'Final Forerunner Pt. $i', denis,
                    daysAgo: 60 - i, art: _denisArt),
            ],
          ),
        ],
        singles: [
          _sermon('s1', 'Standing Firm in the Last Days', denis,
              summary:
                  'A call to faithfulness from Daniel and Revelation for believers today.',
              daysAgo: 7,
              art: _denisArt),
          _sermon('s2', 'The Power of a Praying Church', denis,
              summary:
                  'What happens when a congregation prays together, from Acts 12.',
              daysAgo: 14,
              art: _denisArt),
          _sermon('s3', 'Grace That Is Greater', denis,
              summary: 'Grace that forgives and grace that changes the heart.',
              daysAgo: 21,
              art: _denisArt),
        ],
      ),
      summary('wasoga-moses', 'Pr. Wasoga Moses', 31, 'Prophecy'),
      Presenter(
        id: 'jonathan-matovu',
        name: matovu,
        image: _matovuArt,
        genre: 'Prayer',
        sermonCount: 21,
        seriesCount: 0,
        singles: [
          for (var i = 1; i <= 4; i++)
            _sermon('jm$i', 'Eriiso Ly’Obunnabbi ${21 - i}', matovu,
                daysAgo: i * 7, art: _matovuArt),
        ],
      ),
      summary('peter-ssemambo', 'Elder Peter Ssemambo', 18, 'Christian Living'),
      summary('benjamin-habaasa', 'Ev. Benjamin Habaasa', 15, 'Prophecy'),
      summary('kephas-akim', 'Ev. Kephas Akim', 9, 'Prayer'),
      Presenter(
        id: 'kiiza-samuel-akiki',
        name: kiiza,
        image: '',
        genre: 'Christian Living',
        sermonCount: 6,
        seriesCount: 1,
        series: [
          SermonSeries(
            id: 'victory-amidst-troubles',
            title: 'Victory Amidst Troubles',
            cover: '',
            parts: [
              for (final (i, summary) in const [
                (
                  1,
                  'Joseph sold by his brothers, and how God works through betrayal.'
                ),
                (
                  2,
                  'Faithfulness in Potiphar’s house when no one is watching.'
                ),
                (3, 'In prison but not forgotten: waiting on God’s timing.'),
                (4, 'Interpreting dreams: the gifts God gives in hard places.'),
                (5, 'From the prison to the palace in a single day.'),
                (6, 'Forgiving the brothers: what you meant for evil.'),
              ])
                _sermon('vat$i', 'Victory Amidst Troubles Pt. $i', kiiza,
                    summary: summary, daysAgo: 40 - i),
            ],
          ),
        ],
      ),
      Presenter(
        id: 'ahimbisibwe-michael',
        name: michael,
        image: '',
        genre: 'Christian Living',
        sermonCount: 3,
        seriesCount: 1,
        series: [
          SermonSeries(
            id: 'mind-of-christ',
            title: 'The Mind of Christ',
            cover: '',
            parts: [
              for (final (i, summary) in const [
                (1, 'Letting the mind of Christ shape everyday decisions.'),
                (2, 'Humility, service and the example of Philippians 2.'),
                (3, 'Thinking on whatever is true, noble and pure.'),
              ])
                _sermon('moc$i', 'The Mind of Christ Pt. $i', michael,
                    summary: summary, daysAgo: 30 - i),
            ],
          ),
        ],
      ),
      summary('kisakye-florence', 'Sis. Kisakye Florence', 3, 'Health'),
      summary('kaweesi-tadeo', 'Dr. Kaweesi Tadeo', 3, 'Health'),
    ];
  }

  @override
  Future<List<Presenter>> fetchPresenters() async => [
        for (final p in _presenters)
          Presenter(
            id: p.id,
            name: p.name,
            image: p.image,
            genre: p.genre,
            sermonCount: p.sermonCount,
            seriesCount: p.seriesCount,
          ),
      ];

  @override
  Future<Presenter> fetchPresenter(String id) async =>
      _presenters.firstWhere((p) => p.id == id);
}
