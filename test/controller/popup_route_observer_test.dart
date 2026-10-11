import 'package:avvento_media/controller/popup_route_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PopupRouteObserver observer;
  late GlobalKey<NavigatorState> navKey;

  Future<void> pumpApp(WidgetTester tester) async {
    observer = PopupRouteObserver();
    navKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: navKey,
      navigatorObservers: [observer],
      home: const Scaffold(),
    ));
  }

  testWidgets('counts dialogs and bottom sheets', (tester) async {
    await pumpApp(tester);
    final context = navKey.currentContext!;

    showDialog(context: context, builder: (_) => const Text('dialog'));
    await tester.pumpAndSettle();
    expect(observer.openPopups.value, 1);

    showModalBottomSheet(context: context, builder: (_) => const Text('sheet'));
    await tester.pumpAndSettle();
    expect(observer.openPopups.value, 2);

    navKey.currentState!.pop();
    await tester.pumpAndSettle();
    navKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(observer.openPopups.value, 0);
  });

  testWidgets('ignores page routes', (tester) async {
    await pumpApp(tester);

    navKey.currentState!
        .push(MaterialPageRoute(builder: (_) => const Scaffold()));
    await tester.pumpAndSettle();
    expect(observer.openPopups.value, 0);

    navKey.currentState!.pop();
    await tester.pumpAndSettle();
    expect(observer.openPopups.value, 0);
  });
}
