import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/app_constants.dart';
import '../../controller/library_controller.dart';
import '../../models/saved_item_model.dart';
import '../../themes/avvento_colors.dart';
import '../common/save_bottom_sheet.dart';

/// The action row under a podcast or presenter header: an accent pill
/// (Play All / Pause / Resume / Play latest, with an optional second line),
/// then Shuffle, Favorite, Save and an optional Download all.
class FeedActionRow extends StatelessWidget {
  const FeedActionRow({
    super.key,
    required this.playLabel,
    required this.onPlay,
    required this.onShuffle,
    required this.saved,
    this.playSub,
    this.playing = false,
    this.downloadAll,
  });

  final String playLabel;

  /// Under the label, e.g. the episode "Resume" continues.
  final String? playSub;
  final bool playing;
  final VoidCallback? onPlay;
  final VoidCallback? onShuffle;

  /// What Favorite and Save store.
  final SavedItem saved;
  final Widget? downloadAll;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    final library = Get.find<LibraryController>();

    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            child: Material(
              color: c.accent,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: onPlay,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                            playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 20,
                            color: c.onAccent),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Shrinks rather than clips beside four
                              // buttons at large text sizes.
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(playLabel,
                                    style: TextStyle(
                                        color: c.onAccent,
                                        fontSize: 15,
                                        height: 18 / 15,
                                        fontWeight: FontWeight.w700)),
                              ),
                              if (playSub != null)
                                Text(playSub!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color:
                                            c.onAccent.withValues(alpha: 0.8),
                                        fontSize: 11,
                                        height: 13 / 11,
                                        fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _CircleButton(
          icon: CupertinoIcons.shuffle,
          label: AppConstants.shuffle,
          iconColor: c.text,
          onTap: onShuffle,
        ),
        const SizedBox(width: 8),
        Obx(() {
          final fav = library.isFavorite(saved.id);
          return _CircleButton(
            icon: fav ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
            label: AppConstants.addToFavorites,
            iconColor: fav ? c.liveDot : c.text,
            onTap: () => library.toggleFavorite(saved),
          );
        }),
        const SizedBox(width: 8),
        Obx(() {
          final inPlaylist = library.isInAnyPlaylist(saved.id);
          return _CircleButton(
            icon: inPlaylist
                ? CupertinoIcons.bookmark_fill
                : CupertinoIcons.bookmark,
            label: AppConstants.saveToPlaylist,
            iconColor: inPlaylist ? c.accent : c.text,
            onTap: () => SaveBottomSheet.show(context, saved),
          );
        }),
        if (downloadAll != null) ...[
          const SizedBox(width: 8),
          downloadAll!,
        ],
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: Material(
          color: Theme.of(context).avvento.surface2,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox.square(
              dimension: 48,
              child: Icon(icon, size: 20, color: iconColor),
            ),
          ),
        ),
      );
}
