import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../apis/presenter_repository.dart';
import '../models/presenter_model.dart';

/// The presenters list, loaded once and shared by the list page, the
/// Listen home rail and "Go to presenter". Also remembers which presenters
/// you've opened, for the new-sermon ring.
class PresentersController extends GetxController {
  PresentersController({PresenterRepository? repository, DateTime Function()? clock})
      : repository = repository ?? PresenterRepository.create(),
        _now = clock ?? DateTime.now;

  static const _seenKey = 'presenters_seen';

  /// How long a new sermon keeps the ring if you never open the presenter.
  static const newFor = Duration(days: 14);

  final PresenterRepository repository;
  final DateTime Function() _now;

  /// Null until loaded.
  final Rxn<List<Presenter>> presenters = Rxn<List<Presenter>>();
  final RxBool failed = false.obs;

  /// Presenter id → newest upload you'd seen when you last opened them.
  final RxMap<String, int> _seen = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSeen();
    load();
  }

  Future<void> load() async {
    failed.value = false;
    try {
      presenters.value = await repository.fetchPresenters();
    } catch (_) {
      failed.value = true;
    }
  }

  /// The presenter called [name] (e.g. an episode's artist), if loaded.
  Presenter? byName(String name) {
    final key = name.trim().toLowerCase();
    if (key.isEmpty) return null;
    return presenters.value
        ?.firstWhereOrNull((p) => p.name.toLowerCase() == key);
  }

  Future<Presenter> detail(String id) => repository.fetchPresenter(id);

  /// Ring: a sermon from the last [newFor] that came after your last visit.
  bool hasNew(Presenter p) {
    if (p.latestAt <= 0) return false;
    final latest = DateTime.fromMillisecondsSinceEpoch(p.latestAt * 1000);
    if (_now().difference(latest) > newFor) return false;
    return p.latestAt > (_seen[p.id] ?? 0);
  }

  /// Opening a presenter clears their ring until something newer arrives.
  Future<void> markSeen(Presenter p) async {
    if ((_seen[p.id] ?? 0) >= p.latestAt) return;
    _seen[p.id] = p.latestAt;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_seenKey, json.encode(Map.of(_seen)));
  }

  Future<void> _loadSeen() async {
    final raw = (await SharedPreferences.getInstance()).getString(_seenKey);
    if (raw == null) return;
    _seen.addAll((json.decode(raw) as Map)
        .map((k, v) => MapEntry(k as String, (v as num).toInt())));
  }
}
