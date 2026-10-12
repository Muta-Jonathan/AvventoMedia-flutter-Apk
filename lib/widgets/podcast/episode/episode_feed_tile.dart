import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../components/app_constants.dart';
import '../../../controller/episode_progress_controller.dart';
import '../../../models/radiomodel/podcast_episode_model.dart';
import '../podcast_palette.dart';

/// "TODAY", "OCT 4", or "OCT 4, 2024" outside this year.
String episodeDateLabel(int publishedAt, {DateTime? now}) {
  final date = DateTime.fromMillisecondsSinceEpoch(publishedAt * 1000);
  final today = now ?? DateTime.now();
  if (DateUtils.isSameDay(date, today)) return AppConstants.today.toUpperCase();
  final pattern = date.year == today.year ? 'MMM d' : 'MMM d, y';
  return DateFormat(pattern).format(date).toUpperCase();
}

/// Published in the last week.
bool isNewEpisode(int publishedAt, {DateTime? now}) {
  final date = DateTime.fromMillisecondsSinceEpoch(publishedAt * 1000);
  return (now ?? DateTime.now()).difference(date) < const Duration(days: 7);
}

/// Play pill label: "Played", "12 min left", "48 min", or "Play".
String episodeTimeLabel(EpisodeProgress p) {
  if (p.played) return AppConstants.played;
  final remaining = p.remaining;
  if (remaining == null) return AppConstants.play;
  final minutes = (remaining.inSeconds / 60).ceil();
  return p.position > Duration.zero
      ? AppConstants.minLeft(minutes)
      : AppConstants.minutes(minutes);
}

/// Editorial episode row: date, bold title, 2-line summary, then a play
/// pill with time left, a download button and ⋯.
class EpisodeFeedTile extends StatelessWidget {
  const EpisodeFeedTile({
    super.key,
    required this.episode,
    required this.progress,
    required this.isCurrent,
    required this.isPlaying,
    required this.onTap,
    required this.onPlayTap,
    required this.onMore,
    required this.download,
  });

  final PodcastEpisode episode;
  final EpisodeProgress progress;
  final bool isCurrent;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onPlayTap;
  final VoidCallback onMore;
  final Widget download;

  @override
  Widget build(BuildContext context) {
    final palette = PodcastPalette(context);
    final showNew =
        !isCurrent && !progress.played && isNewEpisode(episode.publishedAt);
    final titleColor = isCurrent
        ? palette.highlight
        : progress.played
            ? palette.played
            : palette.title;
    final summary = episode.description.trim();

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: palette.divider, width: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(children: [
                if (showNew)
                  TextSpan(
                      text: '${AppConstants.newLabel} · ',
                      style: TextStyle(color: palette.highlight)),
                TextSpan(text: episodeDateLabel(episode.publishedAt)),
              ]),
              style: TextStyle(
                color: palette.muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              episode.title,
              style: TextStyle(
                color: titleColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            if (summary.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: palette.summary, fontSize: 13, height: 1.5),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                EpisodePlayPill(
                  label: episodeTimeLabel(progress),
                  fraction: progress.played ? 0 : progress.fraction,
                  active: isCurrent,
                  playing: isPlaying,
                  onTap: onPlayTap,
                ),
                const Spacer(),
                download,
                Semantics(
                  button: true,
                  label: AppConstants.moreLower,
                  child: InkResponse(
                    onTap: onMore,
                    radius: 22,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child:
                          Icon(Icons.more_horiz_rounded, color: palette.muted),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Play/pause pill with time left; amber for the loaded episode.
class EpisodePlayPill extends StatelessWidget {
  const EpisodePlayPill({
    super.key,
    required this.label,
    required this.fraction,
    required this.active,
    required this.playing,
    required this.onTap,
  });

  final String label;
  final double fraction;
  final bool active;
  final bool playing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = PodcastPalette(context);
    final bg = active ? PodcastPalette.accent : palette.button;
    final fg = active ? Colors.black : palette.title;
    final dotFg = active ? PodcastPalette.accent : palette.button;

    return Semantics(
      button: true,
      label: playing ? AppConstants.pause : AppConstants.play,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            height: 32,
            padding: const EdgeInsets.fromLTRB(5, 0, 14, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
                  child: Icon(
                    playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 16,
                    color: dotFg,
                  ),
                ),
                const SizedBox(width: 8),
                if (fraction > 0 && fraction < 1) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: SizedBox(
                      width: 36,
                      height: 3,
                      child: LinearProgressIndicator(
                        value: fraction,
                        color: fg,
                        backgroundColor: active
                            ? Colors.black.withValues(alpha: 0.2)
                            : palette.track,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                ExcludeSemantics(
                  child: Text(label,
                      style: TextStyle(
                          color: fg,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
