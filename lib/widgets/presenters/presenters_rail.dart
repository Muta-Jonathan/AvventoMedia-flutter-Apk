import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/app_constants.dart';
import '../../controller/presenters_controller.dart';
import '../../routes/routes.dart';
import '../../themes/avvento_colors.dart';
import 'presenter_portrait.dart';

/// Horizontal rail of presenters: 80 portrait (accent ring when there's a
/// new sermon), name (2 lines, 3 above 115% text) and "37 sermons". Hidden
/// until there are presenters.
class PresentersRail extends StatelessWidget {
  const PresentersRail({super.key, this.limit = 8});

  final int limit;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final scale = MediaQuery.textScalerOf(context).scale(1);

    return Obx(() {
      final controller = Get.find<PresentersController>();
      final presenters = controller.presenters.value;
      if (presenters == null || presenters.isEmpty) {
        return const SizedBox.shrink();
      }
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final p in presenters.take(limit)) ...[
              if (p != presenters.first) const SizedBox(width: 12),
              Semantics(
                button: true,
                label: [
                  p.name,
                  AppConstants.sermonCount(p.sermonCount),
                  if (controller.hasNew(p)) AppConstants.newSermon,
                ].join(', '),
                excludeSemantics: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () =>
                      Get.toNamed(Routes.getPresenterRoute(), arguments: p.id),
                  child: SizedBox(
                    width: 92,
                    child: Column(
                      children: [
                        PresenterPortrait(
                            name: p.name,
                            image: p.image,
                            size: 78,
                            ring: controller.hasNew(p)),
                        const SizedBox(height: 10),
                        Text(p.name,
                            textAlign: TextAlign.center,
                            maxLines: scale > 1.15 ? 3 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: c.text,
                                fontSize: 13,
                                height: 17 / 13,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(AppConstants.sermonCount(p.sermonCount),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: c.text3,
                                fontSize: 12,
                                height: 16 / 12,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}
