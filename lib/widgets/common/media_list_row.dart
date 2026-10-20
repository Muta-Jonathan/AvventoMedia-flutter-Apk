import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../components/app_constants.dart';
import '../../search/highlight.dart';
import '../../themes/avvento_colors.dart';

/// A row for a video or a playlist: 128 wide 16:9 thumbnail, a title with the
/// searched words marked, and a line of details. Used wherever videos and
/// playlists are listed or found, so they look the same everywhere.
///
/// A playlist ([stacked]) shows a thin bar peeking out above its thumbnail,
/// like a pile of videos.
class MediaListRow extends StatelessWidget {
  const MediaListRow({
    super.key,
    required this.cover,
    required this.title,
    required this.details,
    this.query = '',
    this.badge,
    this.stacked = false,
    this.liveNow = false,
    this.downloaded = false,
    this.dimmed = false,
    this.onTap,
  });

  final String cover;
  final String title;

  /// "24 videos · Oct 18", "1:12:40 · Mar 2".
  final String details;

  /// Words to mark in [title].
  final String query;

  /// Shown on the thumbnail's corner: the video's length.
  final String? badge;

  final bool stacked;

  /// Shows a LIVE NOW badge.
  final bool liveNow;
  final bool downloaded;

  /// A channel that isn't on air, for example.
  final bool dimmed;
  final VoidCallback? onTap;

  /// "1:12:40" or "18:40".
  static String length(Duration d) {
    final h = d.inHours, m = d.inMinutes % 60, s = d.inSeconds % 60;
    String two(int n) => n.toString().padLeft(2, '0');
    return h > 0 ? '$h:${two(m)}:${two(s)}' : '$m:${two(s)}';
  }

  /// "Mar 2", or "Dec 20, 2025" from another year.
  static String date(DateTime d, {DateTime? now}) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final thisYear = (now ?? DateTime.now()).year;
    final base = '${months[d.month - 1]} ${d.day}';
    return d.year == thisYear ? base : '$base, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final titleStyle = TextStyle(
        color: c.text,
        fontSize: 15,
        height: 20 / 15,
        fontWeight: FontWeight.w600);
    final placeholder = ColoredBox(color: c.surface2);

    final thumbnail = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            cover.isEmpty
                ? placeholder
                : CachedNetworkImage(
                    imageUrl: cover,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => placeholder,
                    errorWidget: (_, __, ___) => placeholder,
                  ),
            if (badge != null)
              Positioned(
                right: 6,
                bottom: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    // Over any picture, so a fixed dark pill and white text.
                    color: const Color(0xCC000000),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(badge!,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          height: 14 / 11,
                          fontWeight: FontWeight.w700,
                          fontFeatures: [FontFeature.tabularFigures()])),
                ),
              ),
          ],
        ),
      ),
    );

    return Semantics(
      button: onTap != null,
      label: [
        title,
        if (liveNow) AppConstants.liveNow,
        if (badge != null) badge!,
        details,
      ].where((e) => e.isNotEmpty).join(', '),
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          opacity: dimmed ? 0.7 : 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 128,
                  child: Column(
                    children: [
                      if (stacked)
                        Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Color.lerp(c.surface2, c.text3, 0.45),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                          ),
                        ),
                      thumbnail,
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(TextSpan(
                          children: highlightSpans(title, query,
                              style: titleStyle, background: c.accentSoft))),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (liveNow)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                        color: c.liveDot,
                                        shape: BoxShape.circle)),
                                const SizedBox(width: 5),
                                Text(AppConstants.liveNow,
                                    style: TextStyle(
                                        color: c.liveText,
                                        fontSize: 10,
                                        height: 14 / 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.8)),
                              ],
                            ),
                          if (downloaded)
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                  color: c.accent, shape: BoxShape.circle),
                              child: Icon(Icons.check_rounded,
                                  size: 9, color: c.onAccent),
                            ),
                          Text(details,
                              style: TextStyle(
                                  color: c.text3,
                                  fontSize: 12,
                                  height: 16 / 12,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
