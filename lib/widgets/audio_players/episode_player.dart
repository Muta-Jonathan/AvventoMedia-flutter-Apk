import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart' as rx;

import '../../components/app_constants.dart';
import '../../components/utils.dart';
import '../../controller/audio_player_controller.dart';
import '../../controller/library_controller.dart';
import '../../controller/podcast_episode_controller.dart';
import '../../controller/settings_controller.dart';
import '../../models/radiomodel/podcast_episode_model.dart';
import '../../models/saved_item_model.dart';
import '../../themes/avvento_colors.dart';
import '../../themes/avvento_theme.dart';
import '../common/loading_widget.dart';
import '../common/save_bottom_sheet.dart';
import '../podcast/episode/episode_actions_sheet.dart';
import '../podcast/episode/episode_download_button.dart';
import '../podcast/podcast_palette.dart';

/// "27:04", or "1:02:09" past an hour.
String formatPlayerTime(Duration d) {
  final h = d.inHours, m = d.inMinutes % 60, s = d.inSeconds % 60;
  String two(int n) => n.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '${d.inMinutes}:${two(s)}';
}

/// Full-screen podcast episode player (Listen v2, option A): playing from,
/// cover, title, progress, shuffle · previous · play · next · download,
/// then speed, favorite and save.
class EpisodePlayer extends StatelessWidget {
  const EpisodePlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return AvventoThemeScope(
      child: Builder(builder: (context) {
        final c = Theme.of(context).avvento;
        final audio = Get.find<AudioPlayerController>();
        final episodes = Get.find<PodcastEpisodeController>();
        return Material(
          color: c.bg,
          child: Obx(() {
            final episode = episodes.selectedEpisode.value;
            final item = audio.currentMediaItemRx.value;
            if (episode == null || item == null) {
              return const Center(child: LoadingWidget());
            }
            return _EpisodePlayerBody(
                episode: episode, title: item.title, artist: item.artist);
          }),
        );
      }),
    );
  }
}

class _EpisodePlayerBody extends StatelessWidget {
  const _EpisodePlayerBody(
      {required this.episode, required this.title, required this.artist});

  final PodcastEpisode episode;
  final String title;
  final String? artist;

  String get _show => episode.playlistMediaAlbum.isNotEmpty
      ? episode.playlistMediaAlbum
      : AppConstants.podcasts;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final audio = Get.find<AudioPlayerController>();
    final coverSize =
        (MediaQuery.sizeOf(context).width - 72).clamp(160.0, 318.0);
    final line2 = c.text.withValues(alpha: 0.16);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 4),
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                    color: line2, borderRadius: BorderRadius.circular(3)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: AppConstants.closePlayer,
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        size: 28, color: c.text),
                    onPressed: audio.panelController.collapse,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(AppConstants.playingFrom,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: c.text3,
                                fontSize: 11,
                                height: 14 / 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.88)),
                        const SizedBox(height: 2),
                        Text(_show,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: c.text,
                                fontSize: 14,
                                height: 19 / 14,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: AppConstants.share,
                    icon:
                        Icon(Icons.ios_share_rounded, size: 22, color: c.text),
                    onPressed: () => Utils.share(
                        '${AppConstants.sharePodcastMessage}\n${episode.publicLink}'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 40,
                        offset: const Offset(0, 18)),
                  ],
                ),
                child:
                    PodcastArt(url: episode.art, size: coverSize, radius: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontFamily: AvventoTheme.newsreader,
                          color: c.text,
                          fontSize: 22,
                          height: 28 / 22,
                          fontWeight: FontWeight.w600)),
                  if (artist != null && artist!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(artist!,
                        style: TextStyle(
                            color: c.text2,
                            fontSize: 15,
                            height: 21 / 15,
                            fontWeight: FontWeight.w500)),
                  ],
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(28, 20, 28, 0),
              child: _Progress(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: _Controls(episode: episode, show: _show),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
              child: _Utilities(episode: episode, show: _show),
            ),
          ],
        ),
      ),
    );
  }
}

/// 4px bar with a thumb; elapsed on the left, and on the right the time
/// left or the length (tap to switch, remembered).
class _Progress extends StatelessWidget {
  const _Progress();

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final player = Get.find<AudioPlayerController>().audioPlayer;
    final settings = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : null;
    final timeStyle = TextStyle(
      color: c.text3,
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w600,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return StreamBuilder<(Duration, Duration, Duration)>(
      stream: rx.Rx.combineLatest3(
          player.positionStream,
          player.bufferedPositionStream,
          player.durationStream,
          (Duration p, Duration b, Duration? d) => (p, b, d ?? Duration.zero)),
      builder: (context, snapshot) {
        final (position, buffered, total) = snapshot.data ??
            (player.position, Duration.zero, player.duration ?? Duration.zero);
        final left =
            total - position < Duration.zero ? Duration.zero : total - position;

        return Column(
          children: [
            ProgressBar(
              progress: position,
              buffered: buffered,
              total: total,
              onSeek: player.seek,
              barHeight: 4,
              baseBarColor: c.text.withValues(alpha: 0.16),
              bufferedBarColor: c.text.withValues(alpha: 0.24),
              progressBarColor: c.accent,
              thumbColor: c.accent,
              thumbRadius: 7,
              thumbGlowRadius: 18,
              thumbGlowColor: c.accentSoft,
              timeLabelLocation: TimeLabelLocation.none,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(formatPlayerTime(position), style: timeStyle),
                const Spacer(),
                Obx(() {
                  final showTotal = settings?.playerShowsTotal.value ?? false;
                  return Semantics(
                    button: true,
                    label: showTotal
                        ? AppConstants.lengthSemantics(total)
                        : AppConstants.timeLeftSemantics(left),
                    hint: AppConstants.switchTimeHint,
                    excludeSemantics: true,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => settings?.setPlayerShowsTotal(!showTotal),
                      // 44 hit area around the small label.
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(minWidth: 44, minHeight: 44),
                        child: Align(
                          alignment: Alignment.centerRight,
                          widthFactor: 1,
                          child: Text(
                              showTotal
                                  ? formatPlayerTime(total)
                                  : '-${formatPlayerTime(left)}',
                              style: timeStyle),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Shuffle · previous · play/pause · next · download.
class _Controls extends StatelessWidget {
  const _Controls({required this.episode, required this.show});

  final PodcastEpisode episode;
  final String show;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final audio = Get.find<AudioPlayerController>();

    Widget skip(IconData icon, String label, bool enabled, VoidCallback onTap) {
      return Semantics(
        button: true,
        enabled: enabled,
        label: label,
        excludeSemantics: true,
        child: InkResponse(
          onTap: enabled ? onTap : null,
          radius: 28,
          child: SizedBox.square(
            dimension: 56,
            child: Icon(icon, size: 36, color: enabled ? c.text : c.text3),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(() {
          final on = audio.shuffleOn.value;
          return Semantics(
            button: true,
            toggled: on,
            label: AppConstants.shuffle,
            excludeSemantics: true,
            child: InkResponse(
              onTap: audio.toggleShuffle,
              radius: 24,
              child: SizedBox.square(
                dimension: 48,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.shuffle,
                        size: 22, color: on ? c.accentText : c.text),
                    const SizedBox(height: 3),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                          color: on ? c.accentText : Colors.transparent,
                          shape: BoxShape.circle),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        Obx(() => skip(Icons.skip_previous_rounded, AppConstants.previous,
            audio.hasPrevious.value, audio.playPrevious)),
        StreamBuilder<PlayerState>(
          stream: audio.audioPlayer.playerStateStream,
          initialData: audio.audioPlayer.playerState,
          builder: (context, snapshot) {
            final state = snapshot.data;
            final completed =
                state?.processingState == ProcessingState.completed;
            final playing = (state?.playing ?? false) && !completed;
            return Semantics(
              button: true,
              label: completed
                  ? AppConstants.replay
                  : playing
                      ? AppConstants.pause
                      : AppConstants.play,
              excludeSemantics: true,
              child: Material(
                color: c.accent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: completed
                      ? audio.replay
                      : playing
                          ? audio.pause
                          : audio.play,
                  child: SizedBox.square(
                    dimension: 72,
                    child: Icon(
                      completed
                          ? Icons.replay_rounded
                          : playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                      size: 36,
                      color: c.onAccent,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        Obx(() => skip(Icons.skip_next_rounded, AppConstants.next,
            audio.hasNext.value, audio.playNext)),
        SizedBox.square(
          dimension: 48,
          child: Center(
            child: EpisodeDownloadButton(
              episode: episode,
              showTitle: show,
              idleColor: c.text,
              onDownloaded: () =>
                  EpisodeActionsSheet.show(context, episode, showTitle: show),
            ),
          ),
        ),
      ],
    );
  }
}

/// Speed · Favorite · Save, each with a label.
class _Utilities extends StatelessWidget {
  const _Utilities({required this.episode, required this.show});

  final PodcastEpisode episode;
  final String show;

  SavedItem _saved(Duration? length) => SavedItem(
        id: episode.id,
        type: 'podcast_episode',
        title: episode.title,
        thumbnailUrl: episode.art,
        groupId: episode.playlistMediaAlbum,
        groupTitle: show,
        url: episode.downloadLink,
        duration: length == null ? null : formatPlayerTime(length),
        description: episode.description,
        publishedAtItem:
            DateTime.fromMillisecondsSinceEpoch(episode.publishedAt * 1000)
                .toIso8601String(),
        savedAt: DateTime.now(),
      );

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final audio = Get.find<AudioPlayerController>();
    final library = Get.find<LibraryController>();
    final labelStyle = TextStyle(
        color: c.text3,
        fontSize: 11,
        height: 14 / 11,
        fontWeight: FontWeight.w600);

    Widget utility(
        {required String label,
        required String semantics,
        required Widget visual,
        required VoidCallback onTap,
        bool? toggled}) {
      return Semantics(
        button: true,
        toggled: toggled,
        label: semantics,
        excludeSemantics: true,
        child: InkResponse(
          onTap: onTap,
          radius: 30,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 56, minHeight: 52),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 24, child: Center(child: visual)),
                const SizedBox(height: 4),
                Text(label, maxLines: 1, style: labelStyle),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(() {
          final speed = audio.speed.value;
          final color = speed != 1 ? c.accentText : c.text;
          return utility(
            label: AppConstants.speed,
            semantics: AppConstants.speedSemantics(_speedLabel(speed)),
            onTap: () => _showSpeedSheet(context),
            visual: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(_speedLabel(speed),
                  maxLines: 1,
                  style: TextStyle(
                      color: color, fontSize: 12, fontWeight: FontWeight.w800)),
            ),
          );
        }),
        Obx(() {
          final fav = library.isFavorite(episode.id);
          return utility(
            label: AppConstants.favorite,
            semantics: AppConstants.favorite,
            toggled: fav,
            onTap: () =>
                library.toggleFavorite(_saved(audio.audioPlayer.duration)),
            visual: Icon(fav ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                size: 22, color: fav ? c.liveDot : c.text),
          );
        }),
        Obx(() {
          final saved = library.isInAnyPlaylist(episode.id);
          return utility(
            label: AppConstants.saveLabel,
            semantics: AppConstants.saveToPlaylist,
            toggled: saved,
            onTap: () => SaveBottomSheet.show(
                context, _saved(audio.audioPlayer.duration)),
            // Bookmark with a plus; filled amber once in a playlist.
            visual: Icon(
                saved ? Icons.bookmark_rounded : Icons.bookmark_add_outlined,
                size: 24,
                color: saved ? c.accent : c.text),
          );
        }),
      ],
    );
  }

  static String _speedLabel(double s) =>
      '${s == s.roundToDouble() ? s.toStringAsFixed(0) : s.toString()}×';

  void _showSpeedSheet(BuildContext context) {
    final audio = Get.find<AudioPlayerController>();
    showModalBottomSheet<void>(
      context: context,
      // Sizes to its content and scrolls if squeezed.
      isScrollControlled: true,
      builder: (sheetContext) {
        final c = Theme.of(sheetContext).avvento;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppConstants.playbackSpeed,
                    style: TextStyle(
                        fontFamily: AvventoTheme.newsreader,
                        color: c.text,
                        fontSize: 20,
                        height: 26 / 20,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 14),
                Obx(() {
                  final current = audio.speed.value;
                  final scaler = MediaQuery.textScalerOf(sheetContext);
                  return GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      mainAxisExtent: scaler.scale(15) + 33, // ≥ 48
                    ),
                    children: [
                      for (final s in audio.speeds)
                        Semantics(
                          button: true,
                          selected: s == current,
                          child: Material(
                            color: s == current ? c.accent : c.surface2,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                audio.setSpeed(s);
                                Navigator.pop(sheetContext);
                              },
                              child: Center(
                                child: Text(_speedLabel(s),
                                    style: TextStyle(
                                        color:
                                            s == current ? c.onAccent : c.text,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
