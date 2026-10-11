import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/controller/audio_player_controller.dart';
import 'package:avvento_media/controller/library_controller.dart';
import 'package:avvento_media/models/saved_item_model.dart';
import 'package:avvento_media/widgets/common/save_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_audio_player.dart';

void main() {
  late LibraryController library;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.put(AudioPlayerController(
        player: FakeAudioPlayer(), startAudioService: false));
    library = Get.put(LibraryController());
  });

  tearDown(Get.reset);

  final item = SavedItem(
    id: 'ep1',
    type: 'podcast',
    title: 'Episode 1',
    thumbnailUrl: '',
    groupId: 'g',
    groupTitle: 'Group',
    savedAt: DateTime(2026),
  );

  Future<void> pumpSaveSheet(WidgetTester tester) async {
    await tester.pumpWidget(GetMaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => SaveBottomSheet.show(context, item),
            child: const Text('save'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('save'));
    await tester.pumpAndSettle();
  }

  testWidgets('"New playlist" from the save sheet creates, saves and confirms',
      (tester) async {
    await pumpSaveSheet(tester);

    await tester.tap(find.byIcon(CupertinoIcons.add_circled_solid));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(TextFormField), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Favourites');
    await tester.tap(find.text(AppConstants.createPlaylist));
    await tester.pumpAndSettle();

    expect(library.playlists.single.title, 'Favourites');
    final items = await library.getPlaylistItems(library.playlists.single.id);
    expect(items.map((i) => i.id), ['ep1']);

    // One confirmation naming the playlist. Regression: Get.snackbar threw
    // "No Overlay widget found" on Flutter 3.47 with get 4.7.2.
    expect(find.text('Saved to Favourites'), findsOneWidget);
    expect(find.text(AppConstants.playlistCreated('Favourites')), findsNothing);
    await _finishSnackbars(tester);
  });

  testWidgets('removing from a playlist offers Undo', (tester) async {
    final playlist = await library.createPlaylist('Favourites');
    await library.addToPlaylist(playlist.id, item);
    await pumpSaveSheet(tester);

    await tester.tap(find.text('Favourites'));
    await tester.pumpAndSettle();
    expect(find.text('Removed from Favourites'), findsOneWidget);
    expect(await library.getPlaylistItems(playlist.id), isEmpty);

    await tester.tap(find.text(AppConstants.undo));
    await tester.pumpAndSettle();
    final items = await library.getPlaylistItems(playlist.id);
    expect(items.map((i) => i.id), ['ep1']);
    await _finishSnackbars(tester);
  });
}

/// Lets GetX snackbar timers finish so the test ends cleanly.
Future<void> _finishSnackbars(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }
}
