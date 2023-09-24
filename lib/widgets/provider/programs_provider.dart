import 'package:flutter/foundation.dart';

import '../../models/exploremodels/programs.dart';
import '../explore/explore_fetch_data.dart';

class ProgramsProvider with ChangeNotifier {
  List<Programs> _jobList = [];

  List<Programs> get jobList => _jobList;

  Future<void> fetchData() async {
    try {
      final List<Programs> programs = await ExploreDataFetcher.fetchPrograms();
      _jobList = programs;
      notifyListeners();
    } catch (e) {
      // Handle error gracefully
    }
  }
}
