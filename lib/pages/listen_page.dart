import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../components/app_constants.dart';
import '../controller/connectivity_controller.dart';
import '../controller/presenters_controller.dart';
import '../controller/schedule_controller.dart';
import '../routes/routes.dart';
import '../themes/avvento_colors.dart';
import '../themes/avvento_theme.dart';
import '../widgets/listen/continue_listening_rail.dart';
import '../widgets/listen/live_hero_card.dart';
import '../widgets/listen/podcast_rails.dart';
import '../widgets/listen/section_header.dart';
import '../widgets/listen/up_next_strip.dart';
import '../widgets/presenters/presenters_rail.dart';
import '../widgets/providers/radio_podcast_provider.dart';

/// Listen home: the live radio, what's on next, where you left off,
/// presenters and podcasts.
class ListenPage extends StatefulWidget {
  const ListenPage({super.key});

  @override
  ListenPageState createState() => ListenPageState();
}

class ListenPageState extends State<ListenPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<RadioPodcastProvider>().fetchAllPodcasts();
      }
    });
  }

  Future<void> _refresh() => Future.wait([
        context.read<RadioPodcastProvider>().fetchAllPodcasts(),
        Get.find<PresentersController>().load(),
        Get.find<ScheduleController>().load(),
      ]);

  @override
  Widget build(BuildContext context) {
    // The other tabs and the nav bar use the app theme's surface, so take it
    // from outside the redesign scope.
    final background = Theme.of(context).colorScheme.surface;
    return AvventoThemeScope(
        child: Builder(builder: (context) => _buildPage(context, background)));
  }

  Widget _buildPage(BuildContext context, Color background) {
    final c = Theme.of(context).avvento;
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: c.accent,
          backgroundColor: c.surface,
          onRefresh: _refresh,
          child: ListView(
            children: [
              const _Header(),
              const _OfflineBanner(),
              const LiveHeroCard(),
              const UpNextStrip(),
              const ContinueListeningRail(),
              ListenSectionHeader(
                title: AppConstants.presenters,
                action: AppConstants.seeAll,
                onAction: () => Get.toNamed(Routes.getPresentersRoute()),
              ),
              const PresentersRail(),
              const PodcastRails(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// Logo, "Listen" and search. The slot before search is for the Offline pill.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 10, 0),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Container(
                width: 36,
                height: 36,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Image.asset('assets/icon/icon.png', fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(AppConstants.listenTitle,
                    style: TextStyle(
                        fontFamily: AvventoTheme.newsreader,
                        color: c.text,
                        fontSize: 28,
                        height: 34 / 28,
                        fontWeight: FontWeight.w600)),
              ),
            ),
            Obx(() => Get.find<ConnectivityController>().offline.value
                ? const _OfflinePill()
                : const SizedBox.shrink()),
            IconButton(
              tooltip: AppConstants.search,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              icon: Icon(Icons.search_rounded, size: 24, color: c.text),
              onPressed: () => Get.toNamed(Routes.getSearchRoute()),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflinePill extends StatelessWidget {
  const _OfflinePill();

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: c.surface2, borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 14, color: c.text),
          const SizedBox(width: 6),
          Text(AppConstants.offline,
              style: TextStyle(
                  color: c.text,
                  fontSize: 12,
                  height: 1,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// One line under the header while offline.
class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Obx(() {
      if (!Get.find<ConnectivityController>().offline.value) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Semantics(
          button: true,
          label:
              '${AppConstants.showingDownloadsOnly} ${AppConstants.openDownloads}',
          excludeSemantics: true,
          child: Material(
            color: c.surface2,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => Get.toNamed(Routes.getDownloadsRoute()),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 6, 10, 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(AppConstants.showingDownloadsOnly,
                            style: TextStyle(
                                color: c.text2,
                                fontSize: 13,
                                height: 19 / 13,
                                fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(width: 8),
                      Text(AppConstants.downloads,
                          style: TextStyle(
                              color: c.accentText,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                      Icon(Icons.chevron_right_rounded,
                          size: 20, color: c.accentText),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
