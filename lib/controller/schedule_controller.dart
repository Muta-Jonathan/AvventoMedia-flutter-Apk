import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../apis/schedule_repository.dart';
import '../models/schedule_slot.dart';

enum SlotLabel { onNow, upNext, later }

class ScheduleEntry {
  const ScheduleEntry(this.slot, this.label);
  final ScheduleSlot slot;
  final SlotLabel label;
}

/// The "Up next" strip: what's on now and the next programmes. Recomputed
/// every minute and when the app comes back to the foreground.
class ScheduleController extends GetxController with WidgetsBindingObserver {
  ScheduleController({
    ScheduleRepository? repository,
    DateTime Function()? clock,
    this.tick = const Duration(minutes: 1),
  })  : repository = repository ?? ScheduleRepository.create(),
        _clock = clock ?? DateTime.now;

  /// Slots shown on the strip.
  static const shown = 3;

  /// Refetch at most this often.
  static const _refetchEvery = Duration(minutes: 15);

  final ScheduleRepository repository;
  final DateTime Function() _clock;
  final Duration tick;

  final Rxn<List<ScheduleSlot>> slots = Rxn<List<ScheduleSlot>>();
  final RxBool failed = false.obs;
  late final Rx<DateTime> now = _clock().obs;

  Timer? _timer;
  DateTime? _loadedAt;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(tick, (_) => refresh());
    load();
  }

  Future<void> load() async {
    _loadedAt = _clock();
    failed.value = false;
    try {
      slots.value = await repository.fetchSlots();
    } catch (_) {
      // Keep what we have; only an empty strip is a failure.
      failed.value = slots.value == null;
    }
  }

  /// Moves "now" forward; fetches again when the strip is running dry.
  void refresh() {
    now.value = _clock();
    final stale =
        _loadedAt == null || now.value.difference(_loadedAt!) >= _refetchEvery;
    if (stale && upcoming.length < shown) load();
  }

  /// On now (if anything), then the next programmes.
  List<ScheduleEntry> get upcoming {
    final t = now.value;
    final list = (slots.value ?? const <ScheduleSlot>[])
        .where((s) => s.end.isAfter(t))
        .take(shown)
        .toList();
    return [
      for (var i = 0; i < list.length; i++)
        ScheduleEntry(
            list[i],
            list[i].isOn(t) && i == 0
                ? SlotLabel.onNow
                : (i == 0 || (i == 1 && list[0].isOn(t))
                    ? SlotLabel.upNext
                    : SlotLabel.later)),
    ];
  }

  /// "EAT", "BST"… for the device's current zone.
  String get zoneName => now.value.toLocal().timeZoneName;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refresh();
      load();
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
