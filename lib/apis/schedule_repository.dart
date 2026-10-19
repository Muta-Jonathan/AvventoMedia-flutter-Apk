import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/schedule_slot.dart';

/// Where the radio schedule comes from.
abstract class ScheduleRepository {
  static ScheduleRepository create() => AzuraCastScheduleRepository();

  /// Today's and tomorrow's slots, soonest first.
  Future<List<ScheduleSlot>> fetchSlots();
}

/// AzuraCast's public schedule: playlists with start and end instants.
class AzuraCastScheduleRepository implements ScheduleRepository {
  AzuraCastScheduleRepository({http.Client? client})
      : _client = client ?? http.Client();

  static const url =
      'https://radio1.avventomedia.org/api/station/avventoradio/schedule';

  /// Gaps between programmes ("Pre-program window") are a few minutes long.
  static const minLength = Duration(minutes: 10);

  final http.Client _client;

  @override
  Future<List<ScheduleSlot>> fetchSlots() async {
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Schedule ${response.statusCode}');
    }
    return parseSlots(json.decode(response.body) as List);
  }

  static List<ScheduleSlot> parseSlots(List items) => [
        for (final item in items)
          ScheduleSlot.fromJson(Map<String, dynamic>.from(item))
      ].where((s) => s.length >= minLength).toList()
        ..sort((a, b) => a.start.compareTo(b.start));
}
