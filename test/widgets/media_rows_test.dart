import 'package:avvento_media/models/youtubemodels/youtube_playlist_item_model.dart';
import 'package:avvento_media/themes/dark_theme.dart';
import 'package:avvento_media/widgets/common/media_list_row.dart';
import 'package:avvento_media/widgets/youtube/media_rows.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

YouTubePlaylistItemModel video({String duration = '', String live = ''}) =>
    YouTubePlaylistItemModel(
      id: 'v',
      title: 'Night 1',
      description: '',
      thumbnailUrl: '',
      videoId: 'v',
      channelTitle: '',
      channelName: '',
      duration: duration,
      liveBroadcastContent: live,
      publishedAt: DateTime(2026, 3, 2),
    );

void main() {
  /// The text on the picture's corner, or null.
  String? badge(WidgetTester tester) =>
      tester.widget<MediaListRow>(find.byType(MediaListRow)).badge;

  Future<void> show(WidgetTester tester, YouTubePlaylistItemModel v) async {
    await tester.pumpWidget(MaterialApp(
        theme: darkTheme, home: Scaffold(body: videoRow(v, query: 'night'))));
    await tester.pump();
  }

  testWidgets('a length stored as ISO shows on the picture', (tester) async {
    await show(tester, video(duration: 'PT1H12M40S'));
    expect(badge(tester), '01:12:40');
    expect(find.text('01:12:40'), findsOneWidget);
    expect(find.text('Mar 2'), findsOneWidget);
  });

  testWidgets('a length stored already formatted shows too', (tester) async {
    await show(tester, video(duration: '12:40'));
    expect(badge(tester), '12:40');
  });

  testWidgets('a live video says Live, an unknown length shows nothing',
      (tester) async {
    await show(tester, video(duration: 'P0D', live: 'live'));
    expect(badge(tester), 'Live');

    await show(tester, video());
    expect(badge(tester), isNull);
  });
}
