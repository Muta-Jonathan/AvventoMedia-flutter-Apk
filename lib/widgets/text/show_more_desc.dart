import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../icons/boxed_icon_widget.dart';

class ShowMoreDescription extends StatefulWidget {
  final String description;
  final String modalTitle;

  const ShowMoreDescription({super.key, required this.description, this.modalTitle = AppConstants.about});

  @override
  ShowMoreDescriptionState createState() => ShowMoreDescriptionState();
}

class ShowMoreDescriptionState extends State<ShowMoreDescription> {
  bool isExpanded = false;
  final int wordLimit = 20;

  @override
  Widget build(BuildContext context) {
    final words = widget.description.split(' ');
    final showReadMoreLink = words.length > wordLimit;
    return IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
                Flexible(
                  child: TextOverlay(
                    label: widget.description,
                    fontSize: 16,
                    maxLines: 6, // Show all lines if expanded
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
            const SizedBox(height: 15),
                if (showReadMoreLink)
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        backgroundColor:   Theme.of(context).colorScheme.surface,
                        context: context,
                        builder: (context) {
                          return Column(
                              children: [
                                const SizedBox(height: 20),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12, right: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextOverlay(
                                          label: widget.modalTitle,
                                          color: Theme.of(context).colorScheme.onSecondary,
                                          fontSize: AppConstants.fontSize18,
                                          fontWeight: FontWeight.bold),
                                      GestureDetector(
                                        onTap: () =>  Get.back(),
                                        child: BoxedIcon(
                                          backgroundColor: Colors.white.withOpacity(0.2),
                                          icon: Icons.close_rounded,
                                          borderRadius: 20,
                                          iconColor: Theme.of(context).colorScheme.onSecondary,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Container(
                                      padding: const EdgeInsets.all(16.0),
                                      child: TextOverlay(
                                        label: widget.description,
                                        fontSize: 16,
                                        maxLines: widget.description.length, // Show all lines in the bottom sheet
                                        color: Theme.of(context).colorScheme.onSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                          );
                        },
                      );
                    },
                    child: const TextOverlay(
                        label: AppConstants.readMore,
                        color: Colors.amber, fontSize: 14,
                        underline: true),
                    ),
              ],
        ),
    );
  }
}