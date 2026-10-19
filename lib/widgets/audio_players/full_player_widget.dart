import 'package:avvento_media/components/app_constants.dart';
import 'package:avvento_media/components/utils.dart';
import 'package:avvento_media/controller/audio_player_controller.dart';
import 'package:avvento_media/widgets/audio_players/controls.dart';
import 'package:avvento_media/widgets/audio_players/episode_player.dart';
import 'package:avvento_media/themes/avvento_colors.dart';
import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:avvento_media/widgets/providers/radio_station_provider.dart';
import 'package:avvento_media/widgets/text/text_overlay_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

/// The full-screen inline player that is rendered inside the expanded PlayerPanel.
/// This replaces the route-based OnlineRadioPage / PodcastPage when the panel is expanded.
class FullPlayerWidget extends StatefulWidget {
  const FullPlayerWidget({super.key});

  @override
  State<FullPlayerWidget> createState() => _FullPlayerWidgetState();
}

class _FullPlayerWidgetState extends State<FullPlayerWidget> {
  late AudioPlayerController _controller;

  bool _radioInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AudioPlayerController>();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLive = _controller.isLive.value;
      return isLive ? _buildRadioPlayer(context) : const EpisodePlayer();
    });
  }

  // ---------------------------------------------------------------------------
  // RADIO PLAYER
  // ---------------------------------------------------------------------------
  Widget _buildRadioPlayer(BuildContext context) {
    return Consumer<RadioStationProvider>(
      builder: (context, radioProvider, _) {
        if (radioProvider.radioStation == null) {
          return const Center(child: LoadingWidget());
        }

        // Initialize audio source once a usable stream URL arrives
        if (!_radioInitialized) {
          if (radioProvider.radioStation!.streamUrl.isEmpty) {
            return const Center(child: LoadingWidget());
          }
          _radioInitialized = true;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final station = radioProvider.radioStation!;
            final item = AudioPlayerController.liveItem(station);
            if (!_controller.audioPlayer.playerState.playing) {
              await _controller.setAudioSource(station.streamUrl, item);
            }
          });
        } else {
          _controller.updateRadioProgram(
            radioProvider.radioStation!.nowPlayingTitle,
            radioProvider.radioStation!.artist,
            radioProvider.radioStation!.imageUrl,
            Utils.parseDuration(radioProvider.radioStation!.duration),
            Utils.parseDuration(radioProvider.radioStation!.elapsed),
          );
        }

        final station = radioProvider.radioStation!;
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final paddingWidth = screenWidth * 0.05;
        final paddingTop = screenHeight * 0.02;

        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Drag handle
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                // Header row
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingWidth),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(CupertinoIcons.chevron_down),
                        color: Theme.of(context).colorScheme.onPrimary,
                        onPressed: () => _controller.panelController.collapse(),
                      ),
                      // "● LIVE" over the station, like "PLAYING FROM"
                      // over the show in the episode player.
                      const Expanded(child: _LiveHeader()),
                      IconButton(
                        icon: Icon(CupertinoIcons.share,
                            color: Theme.of(context).colorScheme.onPrimary),
                        onPressed: () => Utils.share(
                            '${AppConstants.shareStream}, \n ${AppConstants.webRadioUrl}'),
                      ),
                    ],
                  ),
                ),
                // Artwork
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.02),
                  child: Container(
                    width: screenWidth * 0.85,
                    height: screenHeight * 0.38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: station.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (_, __) =>
                            const Center(child: LoadingWidget()),
                        errorWidget: (_, __, ___) => Icon(
                          Icons.error,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                // Same title, artist and times as the episode player. Live
                // radio can't seek: the bar follows the song.
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: PlayerTitle(
                        title: station.nowPlayingTitle, artist: station.artist),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(28, 20, 28, paddingTop),
                  child: PlayerProgress(
                    position: Utils.parseDuration(station.elapsed),
                    total: Utils.parseDuration(station.duration),
                  ),
                ),
                Controls(audioPlayerController: _controller),
                SizedBox(height: screenHeight * 0.08),
                TextOverlay(
                  label: AppConstants.avventoSlogan,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LiveHeader extends StatelessWidget {
  const _LiveHeader();

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Semantics(
      label: '${AppConstants.liveSpoken}, ${AppConstants.radioName}',
      excludeSemantics: true,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration:
                    BoxDecoration(color: c.liveDot, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(AppConstants.live,
                  style: TextStyle(
                      color: c.liveText,
                      fontSize: 11,
                      height: 14 / 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.88)),
            ],
          ),
          const SizedBox(height: 2),
          Text(AppConstants.radioName,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: c.text,
                  fontSize: 14,
                  height: 19 / 14,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
