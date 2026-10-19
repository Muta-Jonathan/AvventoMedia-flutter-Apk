import 'package:flutter/material.dart';

import '../../components/app_constants.dart';
import '../../themes/avvento_colors.dart';
import 'shimmer.dart';

/// Placeholders with the geometry of the real content, so nothing jumps
/// when it loads. Each is its own [Shimmer].

/// Rows of the presenters list: 56 portrait, name and "37 sermons · Genre".
class PresenterRowsSkeleton extends StatelessWidget {
  const PresenterRowsSkeleton({super.key, this.count = 8});

  final int count;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Shimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            for (var i = 0; i < count; i++)
              Container(
                constraints: const BoxConstraints(minHeight: 76),
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: c.line))),
                child: const Row(
                  children: [
                    SkeletonBox.circle(56),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 170, height: 16),
                          SizedBox(height: 8),
                          SkeletonBox(width: 120, height: 13),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A presenter's page: portrait and name, the action row and a grid of
/// series covers.
class PresenterPageSkeleton extends StatelessWidget {
  const PresenterPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final cover = (constraints.maxWidth - 40 - 12) / 2;
      return Shimmer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              const Row(
                children: [
                  SkeletonBox.circle(112),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 70, height: 11),
                        SizedBox(height: 8),
                        SkeletonBox(height: 24),
                        SizedBox(height: 8),
                        SkeletonBox(width: 130, height: 14),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: const [
                  Expanded(child: SkeletonBox(height: 48, radius: 24)),
                  SizedBox(width: 10),
                  SkeletonBox.circle(48),
                  SizedBox(width: 10),
                  SkeletonBox.circle(48),
                ],
              ),
              const SizedBox(height: 22),
              const SkeletonBox(height: 48, radius: 14),
              const SizedBox(height: 18),
              Row(
                children: [
                  for (var i = 0; i < 2; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    SizedBox(
                      width: cover,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: cover, height: cover, radius: 14),
                          const SizedBox(height: 10),
                          const SkeletonBox(height: 15),
                          const SizedBox(height: 6),
                          const SkeletonBox(width: 60, height: 12),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// Episode rows of a feed: overline, title, summary, play pill and the two
/// round buttons.
class EpisodeRowsSkeleton extends StatelessWidget {
  const EpisodeRowsSkeleton({super.key, this.count = 5});

  final int count;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Shimmer(
      child: Column(
        children: [
          for (var i = 0; i < count; i++)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: c.line))),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 90, height: 11),
                  SizedBox(height: 8),
                  SkeletonBox(height: 17),
                  SizedBox(height: 8),
                  SkeletonBox(width: 220, height: 13),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      SkeletonBox(width: 99, height: 32, radius: 16),
                      Spacer(),
                      SkeletonBox.circle(44),
                      SizedBox(width: 10),
                      SkeletonBox.circle(44),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// The "Up next" strip: three 148-wide cards.
class UpNextSkeleton extends StatelessWidget {
  const UpNextSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).avvento;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
          child: Text(AppConstants.upNext,
              style: TextStyle(
                  color: c.text,
                  fontSize: 18,
                  height: 24 / 18,
                  fontWeight: FontWeight.w700)),
        ),
        Shimmer(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  const SkeletonBox(width: 148, height: 96, radius: 14),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The presenters rail: round portraits with a name and a count.
class PresentersRailSkeleton extends StatelessWidget {
  const PresentersRailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
        child: Row(
          children: [
            for (var i = 0; i < 5; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              const SizedBox(
                width: 92,
                child: Column(
                  children: [
                    SkeletonBox.circle(78),
                    SizedBox(height: 10),
                    SkeletonBox(width: 70, height: 13),
                    SizedBox(height: 6),
                    SkeletonBox(width: 50, height: 12),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The podcasts section: a heading and a rail of 136 covers.
class PodcastRailsSkeleton extends StatelessWidget {
  const PodcastRailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 10),
            child: SkeletonBox(width: 160, height: 16),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Row(
              children: [
                for (var i = 0; i < 4; i++) ...[
                  if (i > 0) const SizedBox(width: 12),
                  const SizedBox(
                    width: 136,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 136, height: 136, radius: 12),
                        SizedBox(height: 8),
                        SkeletonBox(height: 14),
                        SizedBox(height: 6),
                        SkeletonBox(width: 70, height: 12),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
