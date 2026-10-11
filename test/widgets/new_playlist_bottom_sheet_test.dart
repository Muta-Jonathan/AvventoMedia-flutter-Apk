import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/controller/audio_player_controller.dart';
import 'package:avvento_media/controller/library_controller.dart';
import 'package:avvento_media/widgets/common/new_playlist_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/fake_audio_player.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.put(AudioPlayerController(
        player: FakeAudioPlayer(), startAudioService: false));
    Get.put(LibraryController());
  });

  tearDown(Get.reset);

  testWidgets('confirms with the new playlist name', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => NewPlaylistBottomSheet.show(context),
            child: const Text('new'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('new'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Gospel');
    await tester.tap(find.text(AppConstants.createPlaylist));
    await tester.pumpAndSettle();

    expect(find.text('Playlist "Gospel" created'), findsOneWidget);

    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    }
  });
}
