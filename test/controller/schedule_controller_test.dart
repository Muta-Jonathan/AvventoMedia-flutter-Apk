import 'package:avvento_media/apis/schedule_repository.dart';
import 'package:avvento_media/controller/schedule_controller.dart';
import 'package:avvento_media/models/schedule_slot.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _Repo implements ScheduleRepository {
  _Repo(this.slots);
  List<ScheduleSlot> slots;
  int fetches = 0;
  @override
  Future<List<ScheduleSlot>> fetchSlots() async {
    fetches++;
    return slots;
  }
}

ScheduleSlot slot(String title, int startMin, int endMin) => ScheduleSlot(
      title: title,
      start: DateTime.utc(2026, 10, 20, 9).add(Duration(minutes: startMin)),
      end: DateTime.utc(2026, 10, 20, 9).add(Duration(minutes: endMin)),
    );

void main() {
  late DateTime clock;
  late _Repo repo;
  late ScheduleController controller;

  setUp(() async {
    clock = DateTime.utc(2026, 10, 20, 9, 15);
    repo = _Repo([
      slot('Sermons', 0, 30),
      slot('Eriiso', 30, 90),
      slot('Desire of Ages', 90, 120),
      slot('Hymns', 120, 180),
    ]);
    controller = ScheduleController(
        repository: repo, clock: () => clock, tick: const Duration(hours: 1));
    Get.put(controller);
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(Get.reset);

  List<String> labels() =>
      [for (final e in controller.upcoming) '${e.label.name}:${e.slot.title}'];

  test('on now, up next, later', () {
    expect(labels(), [
      'onNow:Sermons',
      'upNext:Eriiso',
      'later:Desire of Ages',
    ]);
  });

  test('moves on as time passes', () {
    clock = DateTime.utc(2026, 10, 20, 9, 31);
    controller.refresh();
    expect(labels(), [
      'onNow:Eriiso',
      'upNext:Desire of Ages',
      'later:Hymns',
    ]);
  });

  test('between programmes the first is up next', () {
    repo.slots = [slot('A', 0, 20), slot('B', 40, 60), slot('C', 60, 90)];
    controller.slots.value = repo.slots;
    clock = DateTime.utc(2026, 10, 20, 9, 30);
    controller.refresh();
    expect(labels(), ['upNext:B', 'later:C']);
  });

  test('refetches when the strip runs dry and the data is old', () async {
    expect(repo.fetches, 1);
    clock = DateTime.utc(2026, 10, 20, 11, 30); // Only Hymns left, 2 h later.
    controller.refresh();
    await Future<void>.delayed(Duration.zero);
    expect(repo.fetches, 2);
  });

  test('does not refetch while the strip is full', () async {
    clock = DateTime.utc(2026, 10, 20, 9, 20);
    controller.refresh();
    await Future<void>.delayed(Duration.zero);
    expect(repo.fetches, 1);
  });

  test('names the device time zone', () {
    expect(controller.zoneName, isNotEmpty);
  });

  group('AzuraCast schedule', () {
    test('reads epoch seconds as UTC instants and drops tiny gaps', () {
      final slots = AzuraCastScheduleRepository.parseSlots([
        {
          'title': 'Classic sermons',
          'start_timestamp': 1792447200, // 2026-10-20 01:00 +03:00
          'end_timestamp': 1792450800,
        },
        {
          'title': 'Pre-program window',
          'start_timestamp': 1792461420,
          'end_timestamp': 1792461600,
        },
        {
          'title': 'Desire Of Ages',
          'start_timestamp': 1792461600,
          'end_timestamp': 1792463400,
        },
      ]);
      expect(slots.map((s) => s.title), ['Classic sermons', 'Desire Of Ages']);
      expect(slots.first.start, DateTime.utc(2026, 10, 19, 22));
      expect(slots.first.start.isUtc, isTrue);
      // Shown in the device's zone.
      expect(slots.first.start.toLocal().isAtSameMomentAs(slots.first.start),
          isTrue);
    });
  });
}
