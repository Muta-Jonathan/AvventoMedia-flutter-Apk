import 'package:avvento_radio/models/exploremodels/programs.dart';

class Explore {
  String status;
  List<Programs> programs;

  Explore({
    required this.status,
    required this.programs,
  });

  factory Explore.fromJson(Map<String, dynamic> json) {
    var programsList = json['programs'] as List;
    List<Programs> programList =
    programsList.map((programJson) => Programs.fromJson(programJson)).toList();

    return Explore(
      status: json['status'],
      programs: programList,
    );
  }
}

