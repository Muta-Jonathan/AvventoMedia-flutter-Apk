import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/app_constants.dart';
import '../components/episode_playback.dart';
import '../controller/download_controller.dart';
import '../controller/episode_progress_controller.dart';
import '../models/radiomodel/downloaded_episode_model.dart';
import '../routes/routes.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/podcast/episode/episode_actions_sheet.dart';
import '../widgets/podcast/episode/episode_feed_tile.dart';
import '../widgets/podcast/player_state_builder.dart';
import '../widgets/podcast/podcast_palette.dart';

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  final _editing = ValueNotifier(false);

  @override
  void dispose() {
    _editing.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final downloads = Get.find<DownloadController>();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: onPrimary),
        title: Text(AppConstants.downloads, style: TextStyle(color: onPrimary)),
        actions: [
          Obx(() => downloads.downloads.isEmpty
              ? const SizedBox.shrink()
              : _EditToggle(editing: _editing)),
        ],
      ),
      body: DownloadsView(editing: _editing),
    );
  }
}

class _EditToggle extends StatelessWidget {
  const _EditToggle({required this.editing});

  final ValueNotifier<bool> editing;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<bool>(
        valueListenable: editing,
        builder: (context, on, _) => TextButton(
          onPressed: () => editing.value = !on,
          child: Text(
            on ? AppConstants.done : AppConstants.edit,
            style: TextStyle(
                color: PodcastPalette(context).highlight,
                fontSize: 15,
                fontWeight: FontWeight.w600),
          ),
        ),
      );
}

enum _Filter { all, unplayed, inProgress, played }

/// Saved episodes grouped by show, with storage used, filters, the download
/// queue and an edit mode for deleting. Shared by the page and the home
/// chips; pass [editing] when the host shows the Edit button.
class DownloadsView extends StatefulWidget {
  const DownloadsView({super.key, this.editing});

  final ValueNotifier<bool>? editing;

  @override
  State<DownloadsView> createState() => _DownloadsViewState();
}

class _DownloadsViewState extends State<DownloadsView> {
  late final ValueNotifier<bool> _editing =
      widget.editing ?? ValueNotifier(false);
  final Set<String> _selected = {};
  _Filter _filter = _Filter.all;
  late final DownloadController _downloads = Get.find();
  Future<StorageInfo?>? _storage;
  int _storageFor = -1;

  @override
  void initState() {
    super.initState();
    _editing.addListener(_onEditingChanged);
  }

  void _onEditingChanged() => setState(_selected.clear);

  @override
  void dispose() {
    _editing.removeListener(_onEditingChanged);
    if (widget.editing == null) _editing.dispose();
    super.dispose();
  }

  bool _matches(EpisodeProgress p) => switch (_filter) {
        _Filter.all => true,
        _Filter.unplayed => !p.played,
        _Filter.inProgress => !p.played && p.position > Duration.zero,
        _Filter.played => p.played,
      };

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final all = _downloads.sorted;
      final tasks = _downloads.tasks.values.toList();
      final paused = _downloads.paused.value;

      if (all.isEmpty && tasks.isEmpty) {
        return EmptyState(
          icon: Icons.download_rounded,
          color: PodcastPalette.accent,
          title: AppConstants.noDownloads,
          message: AppConstants.noDownloadsMessage,
          actionLabel: AppConstants.browsePodcasts,
          actionIcon: Icons.podcasts_rounded,
          onAction: () => Get.toNamed(Routes.getPodcastListRoute()),
        );
      }

      // Refresh free space when what we store changes.
      if (_storageFor != _downloads.totalBytes) {
        _storageFor = _downloads.totalBytes;
        _storage = _downloads.storage();
      }

      return ValueListenableBuilder<bool>(
        valueListenable: _editing,
        builder: (context, editing, _) => PlayerStateBuilder(
          builder: (context, currentId, playing, progress) {
            EpisodeProgress p(String id) =>
                progress[id] ?? const EpisodeProgress();
            final shown = all.where((d) => _matches(p(d.episode.id))).toList();
            final queue = [for (final d in shown) d.episode];
            final groups = <String, List<DownloadedEpisode>>{};
            for (final d in shown) {
              groups.putIfAbsent(d.showTitle, () => []).add(d);
            }

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      if (widget.editing == null && all.isNotEmpty)
                        Align(
                          alignment: Alignment.centerRight,
                          child: _EditToggle(editing: _editing),
                        ),
                      _StorageCard(
                          used: _downloads.totalBytes, storage: _storage),
                      const SizedBox(height: 16),
                      _FilterRow(
                        selected: _filter,
                        onSelected: (f) => setState(() => _filter = f),
                      ),
                      if (tasks.isNotEmpty && !editing) ...[
                        _SectionHeader(
                          title: AppConstants.downloadingCount(tasks.length),
                          action: paused
                              ? AppConstants.resumeAll
                              : AppConstants.pauseAll,
                          onAction: paused
                              ? _downloads.resumeAll
                              : _downloads.pauseAll,
                        ),
                        _Card(children: [
                          for (final t in tasks)
                            _QueueRow(
                              task: t,
                              onCancel: () => _downloads.cancel(t.episode.id),
                            ),
                        ]),
                      ],
                      for (final entry in groups.entries) ...[
                        _ShowHeader(
                          title: entry.key,
                          art: entry.value.first.episode.art,
                          meta: '${entry.value.length} · '
                              '${formatBytes(entry.value.fold(0, (s, d) => s + d.bytes))}',
                        ),
                        _Card(children: [
                          for (final d in entry.value)
                            _DownloadRow(
                              item: d,
                              progress: p(d.episode.id),
                              isCurrent: d.episode.id == currentId,
                              isPlaying: d.episode.id == currentId && playing,
                              editing: editing,
                              selected: _selected.contains(d.episode.id),
                              onTap: () {
                                final i = queue.indexOf(d.episode);
                                if (editing) {
                                  setState(() =>
                                      _selected.contains(d.episode.id)
                                          ? _selected.remove(d.episode.id)
                                          : _selected.add(d.episode.id));
                                } else {
                                  EpisodePlayback.open(queue, i);
                                }
                              },
                              onPlayTap: () => EpisodePlayback.toggle(
                                  queue, queue.indexOf(d.episode)),
                              onMore: () => EpisodeActionsSheet.show(
                                  context, d.episode,
                                  showTitle: d.showTitle),
                            ),
                        ]),
                      ],
                    ],
                  ),
                ),
                if (editing)
                  _EditBar(
                    selectedCount: _selected.length,
                    selectedBytes: all
                        .where((d) => _selected.contains(d.episode.id))
                        .fold(0, (s, d) => s + d.bytes),
                    allSelected: _selected.length == all.length,
                    onSelectAll: () => setState(() {
                      if (_selected.length == all.length) {
                        _selected.clear();
                      } else {
                        _selected.addAll(all.map((d) => d.episode.id));
                      }
                    }),
                    onDelete: _selected.isEmpty
                        ? null
                        : () async {
                            final ids = _selected.toList();
                            setState(_selected.clear);
                            await _downloads.removeAll(ids);
                            if (_downloads.downloads.isEmpty) {
                              _editing.value = false;
                            }
                          },
                  ),
              ],
            );
          },
        ),
      );
    });
  }
}

class _StorageCard extends StatelessWidget {
  const _StorageCard({required this.used, required this.storage});

  final int used;
  final Future<StorageInfo?>? storage;

  @override
  Widget build(BuildContext context) {
    final palette = PodcastPalette(context);
    return FutureBuilder<StorageInfo?>(
      future: storage,
      builder: (context, snap) {
        final info = snap.data;
        final total = info?.total ?? 0;
        final other =
            info == null ? 0 : (total - info.free - used).clamp(0, total);
        Widget legend(Color c, String label) => Row(children: [
              Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                      color: c, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 5),
              Text(label, style: TextStyle(color: palette.muted, fontSize: 11)),
            ]);

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
              color: palette.card, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(AppConstants.usedByApp(formatBytes(used)),
                      style: TextStyle(
                          color: palette.title,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
                if (info != null)
                  Text(AppConstants.freeSpace(formatBytes(info.free)),
                      style: TextStyle(color: palette.muted, fontSize: 13)),
              ]),
              if (info != null && total > 0) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: SizedBox(
                    key: const ValueKey('storage-bar'),
                    height: 6,
                    // Stretch: childless ColoredBoxes are 0px tall otherwise.
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // A sliver of amber stays visible for small sizes.
                          Expanded(
                              flex: (used / total * 1000).ceil().clamp(8, 1000),
                              child: const ColoredBox(
                                  color: PodcastPalette.accent)),
                          Expanded(
                              flex:
                                  (other / total * 1000).round().clamp(0, 1000),
                              child: ColoredBox(color: palette.muted)),
                          Expanded(
                              flex: (info.free / total * 1000)
                                  .round()
                                  .clamp(1, 1000),
                              child: ColoredBox(color: palette.track)),
                        ]),
                  ),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  legend(PodcastPalette.accent, AppConstants.episodesLegend),
                  const SizedBox(width: 14),
                  legend(palette.muted, AppConstants.otherApps),
                ]),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.selected, required this.onSelected});

  final _Filter selected;
  final ValueChanged<_Filter> onSelected;

  static const _labels = {
    _Filter.all: AppConstants.all,
    _Filter.unplayed: AppConstants.unplayed,
    _Filter.inProgress: AppConstants.inProgress,
    _Filter.played: AppConstants.played,
  };

  @override
  Widget build(BuildContext context) {
    final palette = PodcastPalette(context);
    return Wrap(
      spacing: 8,
      children: [
        for (final f in _Filter.values)
          Semantics(
            button: true,
            selected: f == selected,
            child: Material(
              color: f == selected ? PodcastPalette.accent : palette.card,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => onSelected(f),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  child: Text(_labels[f]!,
                      style: TextStyle(
                          color: f == selected ? Colors.black : palette.title,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(
      {required this.title, required this.action, required this.onAction});

  final String title;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final palette = PodcastPalette(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 0, 4),
      child: Row(children: [
        Expanded(
          child: Text(title,
              style: TextStyle(
                  color: palette.summary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.7)),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(action,
              style: TextStyle(color: palette.highlight, fontSize: 13)),
        ),
      ]),
    );
  }
}

class _ShowHeader extends StatelessWidget {
  const _ShowHeader(
      {required this.title, required this.art, required this.meta});

  final String title;
  final String art;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final palette = PodcastPalette(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 22, 4, 8),
      child: Row(children: [
        PodcastArt(url: art, size: 26, radius: 6),
        const SizedBox(width: 10),
        Expanded(
          child: Text(title.isEmpty ? AppConstants.downloads : title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: palette.title,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
        ),
        Text(meta, style: TextStyle(color: palette.muted, fontSize: 12)),
      ]),
    );
  }
}

/// Rounded card with hairline separators between [children].
class _Card extends StatelessWidget {
  const _Card({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = PodcastPalette(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: ColoredBox(
        color: palette.card,
        child: Column(children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(height: 0.5, thickness: 0.5, color: palette.divider),
            children[i],
          ],
        ]),
      ),
    );
  }
}

class _QueueRow extends StatelessWidget {
  const _QueueRow({required this.task, required this.onCancel});

  final DownloadTask task;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final palette = PodcastPalette(context);
    final got = formatBytes(task.received);
    final total = task.total == null ? null : formatBytes(task.total!);
    final percent =
        task.fraction == null ? '' : ' · ${(task.fraction! * 100).round()}%';
    final status = switch (task.status) {
      DownloadStatus.downloading =>
        total == null ? got : '$got of $total$percent',
      DownloadStatus.paused => total == null
          ? AppConstants.paused
          : '${AppConstants.paused} · $got of $total',
      DownloadStatus.waitingForWifi => AppConstants.waitingForWifiShort,
      DownloadStatus.waiting => AppConstants.waiting,
    };
    final running = task.status == DownloadStatus.downloading;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(children: [
        PodcastArt(url: task.episode.art, size: 44),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.episode.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: palette.title,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: running ? task.fraction : (task.fraction ?? 0),
                  minHeight: 3,
                  color: running ? PodcastPalette.accent : palette.muted,
                  backgroundColor: palette.track,
                ),
              ),
              const SizedBox(height: 5),
              Text(status,
                  style: TextStyle(color: palette.muted, fontSize: 11)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Semantics(
          button: true,
          label: AppConstants.cancelDownload,
          child: Material(
            color: palette.button,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onCancel,
              child: SizedBox(
                width: 32,
                height: 32,
                child: Icon(Icons.close_rounded,
                    size: 16, color: palette.subtitle),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _DownloadRow extends StatelessWidget {
  const _DownloadRow({
    required this.item,
    required this.progress,
    required this.isCurrent,
    required this.isPlaying,
    required this.editing,
    required this.selected,
    required this.onTap,
    required this.onPlayTap,
    required this.onMore,
  });

  final DownloadedEpisode item;
  final EpisodeProgress progress;
  final bool isCurrent;
  final bool isPlaying;
  final bool editing;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onPlayTap;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final palette = PodcastPalette(context);
    final episode = item.episode;
    final titleColor = isCurrent
        ? palette.highlight
        : progress.played
            ? palette.played
            : palette.title;

    return Material(
      color: editing && selected
          ? PodcastPalette.accent.withValues(alpha: 0.08)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
          child: Row(children: [
            if (editing) ...[
              Semantics(
                checked: selected,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        selected ? PodcastPalette.accent : Colors.transparent,
                    border: Border.all(
                        color: selected ? PodcastPalette.accent : palette.muted,
                        width: 2),
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded,
                          size: 14, color: Colors.black)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(episodeDateLabel(episode.publishedAt),
                      style: TextStyle(
                          color: palette.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6)),
                  const SizedBox(height: 4),
                  Text(episode.title,
                      style: TextStyle(
                          color: titleColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.3)),
                  const SizedBox(height: 10),
                  Row(children: [
                    if (!editing) ...[
                      EpisodePlayPill(
                        label: episodeTimeLabel(progress),
                        fraction: progress.played ? 0 : progress.fraction,
                        active: isCurrent,
                        playing: isPlaying,
                        onTap: onPlayTap,
                      ),
                      const SizedBox(width: 8),
                    ],
                    const Icon(Icons.download_rounded,
                        size: 14, color: PodcastPalette.accent),
                    const SizedBox(width: 4),
                    Text(formatBytes(item.bytes),
                        style: TextStyle(color: palette.muted, fontSize: 11)),
                  ]),
                ],
              ),
            ),
            if (!editing)
              Semantics(
                button: true,
                label: AppConstants.moreLower,
                child: InkResponse(
                  onTap: onMore,
                  radius: 22,
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Icon(Icons.more_horiz_rounded, color: palette.muted),
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

class _EditBar extends StatelessWidget {
  const _EditBar({
    required this.selectedCount,
    required this.selectedBytes,
    required this.allSelected,
    required this.onSelectAll,
    required this.onDelete,
  });

  final int selectedCount;
  final int selectedBytes;
  final bool allSelected;
  final VoidCallback onSelectAll;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final palette = PodcastPalette(context);
    return Container(
      decoration: BoxDecoration(
        color: palette.card,
        border: Border(top: BorderSide(color: palette.divider, width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 10, 16, 10),
      child: SafeArea(
        top: false,
        child: Row(children: [
          TextButton(
            onPressed: onSelectAll,
            child: Text(
                allSelected ? AppConstants.clear : AppConstants.selectAll,
                style: TextStyle(color: palette.highlight, fontSize: 14)),
          ),
          Expanded(
            child: Text(
              selectedCount == 0
                  ? AppConstants.selectEpisodes
                  : AppConstants.selectedInfo(
                      selectedCount, formatBytes(selectedBytes)),
              textAlign: TextAlign.center,
              style: TextStyle(color: palette.muted, fontSize: 13),
            ),
          ),
          FilledButton(
            onPressed: onDelete,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              disabledBackgroundColor: palette.track,
              foregroundColor: Colors.white,
              disabledForegroundColor: palette.muted,
              minimumSize: const Size(0, 40),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
            child: const Text(AppConstants.delete),
          ),
        ]),
      ),
    );
  }
}
