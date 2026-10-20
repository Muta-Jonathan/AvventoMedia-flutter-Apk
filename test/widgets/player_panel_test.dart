import 'package:avvento_media/widgets/audio_players/player_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const minHeight = 70.0;
  // Below the 600px test screen so the barrier stays tappable.
  const maxHeight = 500.0;

  late PlayerPanelController controller;
  late List<double> reported;

  Future<void> pumpPanel(WidgetTester tester, {bool mount = true}) async {
    controller = PlayerPanelController();
    reported = [];
    if (!mount) return;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PlayerPanel(
          controller: controller,
          minHeight: minHeight,
          maxHeight: maxHeight,
          onChanged: reported.add,
          builder: (height, percentage) => Text(
            'content',
            key: ValueKey('h:${height.round()}'),
          ),
        ),
      ),
    ));
  }

  double panelHeight(WidgetTester tester) =>
      tester.getSize(find.byType(Material).last).height;

  testWidgets('starts collapsed at minHeight', (tester) async {
    await pumpPanel(tester);
    expect(panelHeight(tester), minHeight);
  });

  /// The panel's own background and the shadow it casts.
  (double background, double shadow) panelPaint(WidgetTester tester) {
    final material = tester.widget<Material>(find.byType(Material).last);
    final box = tester.widget<DecoratedBox>(find.descendant(
        of: find.byType(Material).last, matching: find.byType(DecoratedBox)));
    final shadows = (box.decoration as BoxDecoration).boxShadow!;
    return (material.color!.a, shadows.first.color.a);
  }

  testWidgets('collapsed, nothing is painted behind the bar', (tester) async {
    await pumpPanel(tester);

    final (background, shadow) = panelPaint(tester);
    expect(background, 0);
    expect(shadow, 0);
  });

  testWidgets('opened, the panel is solid and casts its shadow',
      (tester) async {
    await pumpPanel(tester);
    controller.expand();
    await tester.pumpAndSettle();

    final (background, shadow) = panelPaint(tester);
    expect(background, 1);
    expect(shadow, greaterThan(0));
  });

  testWidgets('it turns solid as it opens, not all at once', (tester) async {
    await pumpPanel(tester);
    controller.expand();
    await tester.pump(); // The first frame starts the clock.
    await tester.pump(const Duration(milliseconds: 40));

    final (background, _) = panelPaint(tester);
    expect(background, inExclusiveRange(0, 1));
    await tester.pumpAndSettle();
  });

  testWidgets('expand() and collapse() animate and report progress',
      (tester) async {
    await pumpPanel(tester);

    controller.expand();
    await tester.pumpAndSettle();
    expect(panelHeight(tester), maxHeight);
    expect(reported.last, 1.0);

    controller.collapse();
    await tester.pumpAndSettle();
    expect(panelHeight(tester), minHeight);
    expect(reported.last, 0.0);
  });

  testWidgets('a short drag up snaps back, a longer one expands',
      (tester) async {
    await pumpPanel(tester);
    final panel = find.text('content');

    // 10 % of the range: below the 20 % threshold.
    await tester.timedDrag(
        panel, const Offset(0, -43), const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(panelHeight(tester), minHeight);

    // 40 % of the range.
    await tester.timedDrag(
        panel, const Offset(0, -172), const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(panelHeight(tester), maxHeight);
  });

  testWidgets('a fast fling down collapses even when short', (tester) async {
    await pumpPanel(tester);
    controller.expand();
    await tester.pumpAndSettle();

    await tester.fling(find.text('content'), const Offset(0, 60), 2000);
    await tester.pumpAndSettle();
    expect(panelHeight(tester), minHeight);
  });

  testWidgets('tapping the barrier collapses the panel', (tester) async {
    await pumpPanel(tester);
    controller.expand();
    await tester.pumpAndSettle();
    controller.collapse();
    await tester.pump(const Duration(milliseconds: 50));

    // Mid-collapse the barrier is still up; tap above the panel.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(panelHeight(tester), minHeight);
  });

  testWidgets('expand() before the panel mounts applies once it attaches',
      (tester) async {
    await pumpPanel(tester, mount: false);
    controller.expand();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PlayerPanel(
          controller: controller,
          minHeight: minHeight,
          maxHeight: maxHeight,
          builder: (_, __) => const Text('content'),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(panelHeight(tester), maxHeight);
  });
}
