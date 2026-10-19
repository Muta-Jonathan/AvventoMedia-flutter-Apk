import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

import '../../components/app_constants.dart';
import '../../controller/audio_player_controller.dart';
import '../../controller/connectivity_controller.dart';
import '../../models/radiomodel/radio_station_model.dart';
import '../../themes/avvento_colors.dart';
import '../../themes/avvento_theme.dart';
import '../providers/radio_station_provider.dart';
import 'equalizer_bars.dart';

/// What's on the radio now: cover, LIVE badge, song, artist and a round
/// Play / Pause. Tapping the card opens the full radio player.
class LiveHeroCard extends StatelessWidget {
  const LiveHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioPlayerController>();
    final radio = context.watch<RadioStationProvider>();
    final station = radio.radioStation;

    return StreamBuilder<PlayerState>(
      stream: audio.audioPlayer.playerStateStream,
      initialData: audio.audioPlayer.playerState,
      builder: (context, snapshot) => Obx(() {
        final loaded = audio.liveLoaded;
        final playing = loaded &&
            (snapshot.data?.playing ?? false) &&
            snapshot.data?.processingState != ProcessingState.completed;
        return _card(context, audio, station, playing, radio);
      }),
    );
  }

  Widget _card(BuildContext context, AudioPlayerController audio,
      RadioStation? station, bool playing, RadioStationProvider radio) {
    final c = Theme.of(context).avvento;
    // Nothing to start while offline; a stream already playing can pause.
    final offline = ConnectivityController.isOffline && !playing;
    final ready = station != null && station.streamUrl.isNotEmpty;
    final label = playing ? AppConstants.playingLive : AppConstants.listenLive;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.line),
      ),
      child: Column(
        children: [
          Semantics(
            button: true,
            label: [
              AppConstants.liveRadio,
              if (station != null) station.nowPlayingTitle,
              if (station != null && station.artist.isNotEmpty) station.artist,
            ].join(', '),
            excludeSemantics: true,
            child: InkWell(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              onTap: audio.openLive,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Opacity(
                        opacity: offline ? 0.45 : 1,
                        child: SizedBox.square(
                          dimension: 120,
                          child: station == null || station.imageUrl.isEmpty
                              ? ColoredBox(color: c.surface2)
                              : CachedNetworkImage(
                                  imageUrl: station.imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) =>
                                      ColoredBox(color: c.surface2),
                                  errorWidget: (_, __, ___) =>
                                      ColoredBox(color: c.surface2),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    _LiveBadge(),
                                    Text(AppConstants.radioName,
                                        style: TextStyle(
                                            color: c.text3,
                                            fontSize: 12,
                                            height: 16 / 12,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                    station?.nowPlayingTitle ??
                                        AppConstants.connecting,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: AvventoTheme.newsreader,
                                        color: c.text,
                                        fontSize: 20,
                                        height: 25 / 20,
                                        fontWeight: FontWeight.w600)),
                                if (station != null &&
                                    station.artist.isNotEmpty)
                                  Text(station.artist,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: c.text2,
                                          fontSize: 14,
                                          height: 20 / 14,
                                          fontWeight: FontWeight.w500)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            EqualizerBars(
                                color: c.accentText, playing: playing),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: offline
                ? _NoConnection(onRetry: () async {
                    final connectivity = Get.find<ConnectivityController>();
                    await connectivity.recheck();
                    if (!connectivity.offline.value) radio.reconnect();
                  })
                : Row(
                    children: [
                      Semantics(
                        button: true,
                        enabled: ready,
                        label: playing
                            ? AppConstants.pauseLiveRadio
                            : AppConstants.playLiveRadio,
                        excludeSemantics: true,
                        child: Material(
                          color: ready ? c.accent : c.surface2,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: ready
                                ? () => audio.liveLoaded
                                    ? (playing ? audio.pause() : audio.play())
                                    : audio.playLive(station)
                                : null,
                            child: SizedBox.square(
                              dimension: 52,
                              child: Icon(
                                  playing
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 28,
                                  color: c.onAccent),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(label,
                            style: TextStyle(
                                color: c.text,
                                fontSize: 15,
                                height: 20 / 15,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          color: c.liveSoft, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 7,
              height: 7,
              decoration:
                  BoxDecoration(color: c.liveDot, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(AppConstants.liveBadge,
              style: TextStyle(
                  color: c.liveText,
                  fontSize: 11,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.88)),
        ],
      ),
    );
  }
}

/// "No connection" and a Retry pill in place of the play button.
class _NoConnection extends StatelessWidget {
  const _NoConnection({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Row(
      children: [
        Expanded(
          child: Text(AppConstants.noConnection,
              style: TextStyle(
                  color: c.text2,
                  fontSize: 13,
                  height: 19 / 13,
                  fontWeight: FontWeight.w500)),
        ),
        OutlinedButton(
          onPressed: onRetry,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(44, 44),
            padding: const EdgeInsets.symmetric(horizontal: 18),
            foregroundColor: c.text,
            side: BorderSide(color: c.line, width: 1.5),
            shape: const StadiumBorder(),
            textStyle:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          child: const Text(AppConstants.retry),
        ),
      ],
    );
  }
}
