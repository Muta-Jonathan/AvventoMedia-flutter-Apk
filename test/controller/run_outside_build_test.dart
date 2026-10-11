import 'package:avvento_media/controller/audio_player_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('Rx update from a build does not dirty an Obx mid-build',
      (tester) async {
    final value = 0.obs;

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        children: [
          Obx(() => Text('${value.value}')),
          // Sibling built after the Obx that updates the Rx during its build,
          // like GetObserver.didPush on the first route.
          Builder(builder: (_) {
            runOutsideBuild(() => value.value = 1);
            return const SizedBox();
          }),
        ],
      ),
    ));
    expect(tester.takeException(), isNull);

    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });
}
