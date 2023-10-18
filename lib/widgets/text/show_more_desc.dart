import 'package:avvento_radio/componets/app_constants.dart';
import 'package:avvento_radio/componets/utils.dart';
import 'package:avvento_radio/widgets/text/text_overlay_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../icons/boxed_icon_widget.dart';

class ShowMoreDescription extends StatefulWidget {
  final String description;

  const ShowMoreDescription({super.key, required this.description});

  @override
  ShowMoreDescriptionState createState() => ShowMoreDescriptionState();
}

class ShowMoreDescriptionState extends State<ShowMoreDescription> {
  bool isExpanded = false;
  final int wordLimit = 20; // Set the word limit here

  @override
  Widget build(BuildContext context) {
    final words = widget.description.split(' ');
    final showReadMoreLink = words.length > wordLimit;
    return SizedBox(
      height: Utils.calculateHeight(context, 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
              Flexible(
                child: TextOverlay(
                  label: widget.description,
                  fontSize: 16,
                  maxLines: 6, // Show all lines if expanded
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
          const SizedBox(height: 20),
              if (showReadMoreLink)
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      backgroundColor: Theme.of(context).colorScheme.background,
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
                                        label: AppConstants.about,
                                        color: Theme.of(context).colorScheme.onSecondary,
                                        fontSize: 20,
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
                              SingleChildScrollView(
                                child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  child: TextOverlay(
                                    label: widget.description,
                                    fontSize: 16,
                                    maxLines: 150, // Show all lines in the bottom sheet
                                    color: Theme.of(context).colorScheme.onSecondary,
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
                      color: Colors.orange, fontSize: 14,
                      underline: true),
                  ),
            ],
      ),
    );
  }
}