import 'package:get/get.dart';

import '../apis/presenter_repository.dart';
import '../models/presenter_model.dart';

/// The presenters list, loaded once and shared by the list page, the
/// Listen home rail and "Go to presenter".
class PresentersController extends GetxController {
  PresentersController({PresenterRepository? repository})
      : repository = repository ?? PresenterRepository.create();

  final PresenterRepository repository;

  /// Null until loaded.
  final Rxn<List<Presenter>> presenters = Rxn<List<Presenter>>();
  final RxBool failed = false.obs;

  @override
  void onInit() {
    super.onInit();
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
}
