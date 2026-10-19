import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../components/app_constants.dart';
import '../../../controller/episode_progress_controller.dart';
import '../../../models/radiomodel/podcast_episode_model.dart';
import '../../../themes/avvento_colors.dart';

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

/// "PART 3 · 45 MIN" when [lead] is given, else "OCT 11 · 51 MIN". The
/// length is only known once the episode has been loaded.
String episodeOverline(PodcastEpisode episode, EpisodeProgress progress,
    {String? lead}) {
  lead ??= episodeDateLabel(episode.publishedAt);
  final length = progress.duration;
  final text = length == null
      ? lead
      : '$lead · ${AppConstants.minutes((length.inSeconds / 60).ceil())}';
  return text.toUpperCase();
}

/// Episode row (design 1b): overline, title (never clamped), 2-line
/// summary, then the play pill, download state, download button and ⋯.
/// When not [available] (offline and not downloaded) it is dimmed and
/// can't be played.
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
    this.downloadLabel,
    this.available = true,
    this.overlineLead,
    this.title,
    this.showSummary = true,
    this.horizontalMargin = 20,
  });

  final PodcastEpisode episode;
  final EpisodeProgress progress;
  final bool isCurrent;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onPlayTap;
  final VoidCallback onMore;
  final Widget download;
  final Widget? downloadLabel;
  final bool available;

  /// Replaces the date in the overline, e.g. "Chapter 3".
  final String? overlineLead;

  /// Display title; defaults to the episode's.
  final String? title;
  final bool showSummary;

  /// Page margin; 0 inside a card that has its own padding.
  final double horizontalMargin;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final showNew = overlineLead == null &&
        !isCurrent &&
        !progress.played &&
        isNewEpisode(episode.publishedAt);
    final titleColor = isCurrent
        ? c.accentText
        : progress.played
            ? c.text3
            : c.text;
    final summary = showSummary ? episode.description.trim() : '';
    final title = this.title ?? episode.title;

    return Opacity(
      opacity: available ? 1 : 0.45,
      child: InkWell(
        onTap: available ? onTap : null,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
          // The action row's 44 hit areas supply the rest of the bottom gap.
          padding: const EdgeInsets.only(top: 14, bottom: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: c.line)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(children: [
                  if (showNew)
                    TextSpan(
                        text: '${AppConstants.newLabel} · ',
                        style: TextStyle(color: c.accentText)),
                  TextSpan(
                      text: episodeOverline(episode, progress,
                          lead: overlineLead)),
                ]),
                style: TextStyle(
                  color: c.text3,
                  fontSize: 11,
                  height: 14 / 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.66,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontSize: 16,
                  height: 21 / 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (summary.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(color: c.text2, fontSize: 13, height: 19 / 13),
                ),
              ],
              const SizedBox(height: 2),
              Row(
                children: [
                  EpisodePlayPill(
                    label: available
                        ? episodeTimeLabel(progress)
                        : AppConstants.notDownloaded,
                    semanticsLabel: available
                        ? '${isPlaying ? AppConstants.pause : AppConstants.play} $title'
                        : AppConstants.notAvailableOffline,
                    fraction: progress.played ? 0 : progress.fraction,
                    active: isCurrent,
                    playing: isPlaying,
                    onTap: available ? onPlayTap : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: downloadLabel ?? const SizedBox.shrink(),
                    ),
                  ),
                  download,
                  // Pulled into the page margin, as in the design.
                  Transform.translate(
                    offset: const Offset(10, 0),
                    child: Semantics(
                      button: true,
                      label: AppConstants.moreLower,
                      child: InkResponse(
                        onTap: onMore,
                        radius: 22,
                        child: SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(Icons.more_horiz_rounded,
                              size: 22, color: c.text3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Play/pause pill with time left; accent for the loaded episode. The pill
/// is 32 tall inside a 44 hit area.
class EpisodePlayPill extends StatelessWidget {
  const EpisodePlayPill({
    super.key,
    required this.label,
    this.semanticsLabel,
    required this.fraction,
    required this.active,
    required this.playing,
    required this.onTap,
  });

  final String label;
  final String? semanticsLabel;
  final double fraction;
  final bool active;
  final bool playing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final bg = active ? c.accent : c.surface2;
    final fg = active ? c.onAccent : c.text;
    final showBar = active || (fraction > 0 && fraction < 1);

    return Semantics(
      button: true,
      enabled: onTap != null,
      label:
          semanticsLabel ?? (playing ? AppConstants.pause : AppConstants.play),
      child: GestureDetector(
        // Catches taps in the padding that makes up the 44 target.
        behavior: HitTestBehavior.translucent,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Material(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Container(
                constraints: const BoxConstraints(minHeight: 32),
                padding: const EdgeInsets.fromLTRB(4, 4, 14, 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                          color: active ? c.onAccent : c.text,
                          shape: BoxShape.circle),
                      child: Icon(
                        playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 16,
                        color: active ? c.accent : c.bg,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (showBar) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: SizedBox(
                          width: 32,
                          height: 3,
                          child: LinearProgressIndicator(
                            value:
                                active ? fraction.clamp(0.08, 1.0) : fraction,
                            color: active ? c.onAccent : c.accentText,
                            backgroundColor: active
                                ? Colors.black.withValues(alpha: 0.22)
                                : c.line,
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
        ),
      ),
    );
  }
}
