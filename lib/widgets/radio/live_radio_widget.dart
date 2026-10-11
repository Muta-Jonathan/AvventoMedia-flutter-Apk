import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/models/radiomodel/radio_model.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../apis/firestore_service_api.dart';
import '../../controller/audio_player_controller.dart';

class LiveRadioWidget extends StatefulWidget {
  const LiveRadioWidget({super.key});

  @override
  State<LiveRadioWidget> createState() => _LiveRadioWidget();
}

class _LiveRadioWidget extends State<LiveRadioWidget> {
  final _radioAPI = Get.put(FirestoreServiceAPI());

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _radioAPI.fetchRadio(),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          List liveTvList = snapshot.data!.docs;

          if (liveTvList.isNotEmpty) {
            DocumentSnapshot documentSnapshot = liveTvList.first;
            RadioModel radioModel = RadioModel.fromSnapShot(documentSnapshot);
            return _buildRadioBanner(context, radioModel);
          } else {
            return const SizedBox.shrink();
          }
        } else {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: LoadingWidget(),
          );
        }
      },
    );
  }

  Widget _buildRadioBanner(BuildContext context, RadioModel radioModel) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.leftMain),
      child: GestureDetector(
        onTap: () {
          final audioController = Get.find<AudioPlayerController>();
          audioController.isLive.value = true;
          audioController.isPlayerActive.value = true;
          audioController.isMiniPlayerVisible.value = true;
          // Defer until the PlayerPanel is in the tree
          WidgetsBinding.instance.addPostFrameCallback((_) {
            audioController.panelController.expand();
          });
        },
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: colorScheme.secondary,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Background image — full bleed, dimmed
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: radioModel.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: colorScheme.secondary),
                  errorWidget: (_, __, ___) => Container(color: colorScheme.secondary),
                ),
              ),
              // Dark overlay for readability
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.75),
                        Colors.black.withValues(alpha: 0.45),
                        Colors.black.withValues(alpha: 0.65),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Row(
                  children: [
                    // Radio icon container
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(
                        CupertinoIcons.antenna_radiowaves_left_right,
                        color: Colors.amber.shade400,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Text section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                radioModel.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 5,
                                      height: 5,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      radioModel.status.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 9,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tap to tune in now',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Play button
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade700,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.play_fill,
                        color: Colors.black,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
