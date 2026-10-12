import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/controller/audio_player_controller.dart';
import 'package:avvento_media/controller/library_controller.dart';
import 'package:avvento_media/models/custom_playlist_meta.dart';
import 'package:avvento_media/pages/favorites_page.dart';
import 'package:avvento_media/pages/my_playlists_page.dart';
import 'package:avvento_media/pages/playlist_detail_page.dart';
import 'package:avvento_media/themes/dark_theme.dart';
import 'package:avvento_media/widgets/common/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_audio_player.dart';

/// Empty library screens show a visible pictogram, a title and guidance,
/// including in dark mode (where onSurface matches the background).
void main() {
  tearDown(Get.reset);

  Future<void> pump(WidgetTester tester, Widget page) async {
    SharedPreferences.setMockInitialValues({});
    Get.put(AudioPlayerController(
        player: FakeAudioPlayer(), startAudioService: false));
    Get.put(LibraryController());
    await tester.pumpWidget(GetMaterialApp(theme: darkTheme, home: page));
    await tester.pumpAndSettle();
  }

  void expectVisiblePictogram(WidgetTester tester) {
    final icon = tester.widget<Icon>(find.descendant(
        of: find.byType(EmptyState), matching: find.byType(Icon)).first);
    expect(icon.color, isNot(darkTheme.colorScheme.surface));
  }

  testWidgets('favorites', (tester) async {
    await pump(tester, const FavoritesPage());

    expect(find.text(AppConstants.noFavorites), findsOneWidget);
    expect(find.text(AppConstants.noFavoritesMessage), findsOneWidget);
    expectVisiblePictogram(tester);
  });

  testWidgets('playlists, with a working New Playlist button',
      (tester) async {
    await pump(tester, const MyPlaylistsPage());

    expect(find.text(AppConstants.noPlaylists), findsOneWidget);
    expect(find.text(AppConstants.noPlaylistsMessage), findsOneWidget);
    expectVisiblePictogram(tester);

    await tester.tap(find.descendant(
        of: find.byType(EmptyState),
        matching: find.text(AppConstants.newPlaylist)));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsOneWidget);
  });

  testWidgets('empty playlist', (tester) async {
    await pump(
      tester,
      PlaylistDetailPage(
        playlist: CustomPlaylistMeta(
            id: 'p1', title: 'Favourites', createdAt: DateTime(2026)),
      ),
    );

    expect(find.text(AppConstants.emptyPlaylist), findsOneWidget);
    expect(find.text(AppConstants.emptyPlaylistMessage), findsOneWidget);
    expectVisiblePictogram(tester);
  });

  testWidgets('playlists view can offer a New Playlist row (home chips)',
      (tester) async {
    await pump(tester, const Scaffold(body: PlaylistsView(showCreateRow: true)));
    await Get.find<LibraryController>().createPlaylist('Gospel');
    await tester.pumpAndSettle();

    expect(find.text('Gospel'), findsOneWidget);
    await tester.tap(find.text(AppConstants.newPlaylist));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsOneWidget);
  });
}
