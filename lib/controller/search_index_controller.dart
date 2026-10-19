import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../apis/podcast_repository.dart';
import '../models/presenter_model.dart';
import '../search/search_models.dart';
import '../search/search_source.dart';
import 'presenters_controller.dart';

/// The local search index and the Recent searches. The index fills in
/// batches from the app's caches the first time Search opens, so results
/// appear before everything has loaded and Search works offline.
class SearchIndexController extends GetxController {
  /// [source] exists for tests.
  SearchIndexController({SearchSource? source}) : _source = source;

  static const _historyKey = 'search_history';

  /// Recent searches kept.
  static const maxRecent = 20;

  final SearchSource? _source;

  final RxList<SearchEntry> entries = <SearchEntry>[].obs;
  final RxBool loading = false.obs;
  final RxList<String> recent = <String>[].obs;

  bool _started = false;

  @override
  void onInit() {
    super.onInit();
    _loadRecent();
  }

  /// Fills the index once.
  Future<void> ensureLoaded() async {
    if (_started) return;
    _started = true;
    loading.value = true;
    try {
      await for (final batch in (_source ?? _appSource()).load()) {
        entries.addAll(batch);
      }
    } catch (_) {
      // Whatever arrived is searchable.
    } finally {
      loading.value = false;
    }
  }

  SearchSource _appSource() {
    final presenters = Get.find<PresentersController>();
    return AppSearchSource(
      presenters: () async {
        if (presenters.presenters.value == null) await presenters.load();
        return presenters.presenters.value ?? const <Presenter>[];
      },
      podcasts: PodcastRepository.instance.fetchPodcasts,
    );
  }

  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    recent.assignAll(prefs.getStringList(_historyKey) ?? const []);
  }

  Future<void> _saveRecent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, recent.toList());
  }

  /// Newest first, no repeats.
  Future<void> addRecent(String term) async {
    final t = term.trim();
    if (t.isEmpty) return;
    recent
      ..removeWhere((r) => r.toLowerCase() == t.toLowerCase())
      ..insert(0, t);
    if (recent.length > maxRecent) recent.removeRange(maxRecent, recent.length);
    await _saveRecent();
  }

  Future<void> removeRecent(String term) async {
    recent.remove(term);
    await _saveRecent();
  }

  Future<void> clearRecent() async {
    recent.clear();
    await _saveRecent();
  }
}
