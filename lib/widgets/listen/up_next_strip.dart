import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/app_constants.dart';
import '../../controller/schedule_controller.dart';
import '../../themes/avvento_colors.dart';
import '../common/skeletons.dart';

/// On now / Up next / Later, in the listener's own time zone. Hidden until
/// the schedule loads.
class UpNextStrip extends StatelessWidget {
  const UpNextStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final schedule = Get.find<ScheduleController>();

    return Obx(() {
      final entries = schedule.upcoming;
      if (schedule.slots.value == null && !schedule.failed.value) {
        return const UpNextSkeleton();
      }
      if (entries.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(AppConstants.upNext,
                        style: TextStyle(
                            color: c.text,
                            fontSize: 18,
                            height: 24 / 18,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                Text(AppConstants.yourTime(schedule.zoneName),
                    style: TextStyle(
                        color: c.text3,
                        fontSize: 12,
                        height: 16 / 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final e in entries) ...[
                  if (e != entries.first) const SizedBox(width: 10),
                  _SlotCard(entry: e),
                ],
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({required this.entry});

  final ScheduleEntry entry;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final on = entry.label == SlotLabel.onNow;
    final label = switch (entry.label) {
      SlotLabel.onNow => AppConstants.onNowLabel,
      SlotLabel.upNext => AppConstants.upNextLabel,
      SlotLabel.later => AppConstants.laterLabel,
    };
    // Device time zone; 12 or 24 hour as the device is set.
    final time =
        TimeOfDay.fromDateTime(entry.slot.start.toLocal()).format(context);

    return Semantics(
      label: '$label, $time, ${entry.slot.title}',
      excludeSemantics: true,
      child: Container(
        width: 148,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: on ? c.accentSoft : c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: on ? c.accent : c.line, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: on ? c.accentText : c.text3,
                    fontSize: 10,
                    height: 14 / 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8)),
            const SizedBox(height: 4),
            Text(time,
                style: TextStyle(
                    color: c.text,
                    fontSize: 17,
                    height: 22 / 17,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(entry.slot.title,
                style: TextStyle(
                    color: c.text2,
                    fontSize: 13,
                    height: 18 / 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
