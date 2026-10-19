/// One programme in the radio schedule. Times are absolute instants (UTC),
/// shown in the listener's own time zone with [DateTime.toLocal].
class ScheduleSlot {
  const ScheduleSlot({
    required this.title,
    required this.start,
    required this.end,
  });

  final String title;
  final DateTime start;
  final DateTime end;

  bool isOn(DateTime now) => !now.isBefore(start) && now.isBefore(end);

  Duration get length => end.difference(start);

  /// AzuraCast schedule item: epoch seconds, so no time zone maths.
  factory ScheduleSlot.fromJson(Map<String, dynamic> json) => ScheduleSlot(
        title: (json['title'] ?? json['name'] ?? '') as String,
        start: DateTime.fromMillisecondsSinceEpoch(
            (json['start_timestamp'] as num).toInt() * 1000,
            isUtc: true),
        end: DateTime.fromMillisecondsSinceEpoch(
            (json['end_timestamp'] as num).toInt() * 1000,
            isUtc: true),
      );
}
