import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../components/app_constants.dart';
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
