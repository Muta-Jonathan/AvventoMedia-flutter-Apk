import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/app_constants.dart';
import '../controller/presenters_controller.dart';
import '../models/presenter_model.dart';
import '../routes/routes.dart';
import '../themes/avvento_colors.dart';
import '../themes/avvento_theme.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_widget.dart';
import '../widgets/presenters/presenter_portrait.dart';

/// Presenters · See all: search, genre chips and a list that keeps full
/// names readable at any text size.
class PresentersPage extends StatefulWidget {
  const PresentersPage({super.key});

  static const genres = [
    AppConstants.allGenres,
    'Christian Living',
    'Prophecy',
    'Health',
    'Prayer',
  ];

  @override
  State<PresentersPage> createState() => _PresentersPageState();
}

class _PresentersPageState extends State<PresentersPage> {
  final _search = TextEditingController();
  String _genre = AppConstants.allGenres;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Presenter> _filter(List<Presenter> all) {
    final q = _search.text.trim().toLowerCase();
    return [
      for (final p in all)
        if ((_genre == AppConstants.allGenres || p.genre == _genre) &&
            (q.isEmpty || p.name.toLowerCase().contains(q)))
          p
    ];
  }

  void _clear() => setState(() {
        _search.clear();
        _genre = AppConstants.allGenres;
      });

  @override
  Widget build(BuildContext context) =>
      AvventoThemeScope(child: Builder(builder: _buildPage));

  Widget _buildPage(BuildContext context) {
    final c = Theme.of(context).avvento;
    final controller = Get.find<PresentersController>();

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final all = controller.presenters.value;
          final shown = all == null ? const <Presenter>[] : _filter(all);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      tooltip:
                          MaterialLocalizations.of(context).backButtonTooltip,
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 22, color: c.text),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 10,
                    children: [
                      Text(AppConstants.presenters,
                          style: TextStyle(
                              fontFamily: AvventoTheme.newsreader,
                              color: c.text,
                              fontSize: 28,
                              height: 34 / 28,
                              fontWeight: FontWeight.w600)),
                      if (all != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('${all.length}',
                              style: TextStyle(
                                  color: c.text3,
                                  fontSize: 14,
                                  height: 20 / 14,
                                  fontWeight: FontWeight.w500)),
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _searchField(c)),
              SliverToBoxAdapter(child: _chips(c)),
              if (all == null && !controller.failed.value)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: LoadingWidget()),
                )
              else if (all == null)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.wifi_off_rounded,
                    color: c.accent,
                    title: AppConstants.presentersLoadFailed,
                    message: '',
                    actionLabel: AppConstants.retry,
                    actionIcon: Icons.refresh_rounded,
                    onAction: controller.load,
                  ),
                )
              else if (shown.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.search_rounded,
                    color: c.accent,
                    title: AppConstants.noPresentersFound,
                    message: _search.text.trim().isEmpty
                        ? ''
                        : AppConstants.noResultsFor(_search.text.trim()),
                    actionLabel: AppConstants.clearSearch,
                    onAction: _clear,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList.builder(
                    itemCount: shown.length,
                    itemBuilder: (context, i) => _PresenterRow(
                      presenter: shown[i],
                      onTap: () => Get.toNamed(Routes.getPresenterRoute(),
                          arguments: shown[i].id),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _searchField(AvventoColors c) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      constraints: const BoxConstraints(minHeight: 48),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.line),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 20, color: c.text3),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              style: TextStyle(
                  color: c.text, fontSize: 15, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: AppConstants.searchPresenters,
                hintStyle: TextStyle(
                    color: c.text3, fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          if (_search.text.isNotEmpty)
            IconButton(
              tooltip: AppConstants.clearSearch,
              icon: Icon(Icons.close_rounded, size: 18, color: c.text3),
              onPressed: () => setState(_search.clear),
            ),
        ],
      ),
    );
  }

  Widget _chips(AvventoColors c) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          for (final g in PresentersPage.genres) ...[
            if (g != PresentersPage.genres.first) const SizedBox(width: 8),
            Semantics(
              button: true,
              selected: g == _genre,
              child: InkWell(
                borderRadius: BorderRadius.circular(17),
                onTap: () => setState(() => _genre = g),
                // 34 chip in a 44 hit area.
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Center(
                    widthFactor: 1,
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 34),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: g == _genre ? c.text : Colors.transparent,
                        borderRadius: BorderRadius.circular(17),
                        border:
                            Border.all(color: g == _genre ? c.text : c.line),
                      ),
                      alignment: Alignment.center,
                      child: Text(g,
                          style: TextStyle(
                              color: g == _genre ? c.bg : c.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 56 portrait, full name (wraps, never shortened), "37 sermons · Prophecy".
class _PresenterRow extends StatelessWidget {
  const _PresenterRow({required this.presenter, required this.onTap});

  final Presenter presenter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 76),
        decoration:
            BoxDecoration(border: Border(bottom: BorderSide(color: c.line))),
        child: Row(
          children: [
            PresenterPortrait(
                name: presenter.name,
                image: presenter.image,
                size: 56,
                ring: Get.find<PresentersController>().hasNew(presenter),
                ringGap: 2,
                ringWidth: 2),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(presenter.name,
                        style: TextStyle(
                            color: c.text,
                            fontSize: 16,
                            height: 21 / 16,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                        '${AppConstants.sermonCount(presenter.sermonCount)} · ${presenter.genre}',
                        style: TextStyle(
                            color: c.text2,
                            fontSize: 13,
                            height: 18 / 13,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 22, color: c.text3),
          ],
        ),
      ),
    );
  }
}
