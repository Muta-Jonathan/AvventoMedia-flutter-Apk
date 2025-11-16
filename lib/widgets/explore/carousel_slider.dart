import 'dart:async';

import 'package:avvento_media/widgets/common/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'carousel_card.dart';
import '../providers/programs_provider.dart';

class CarouselSlider extends StatefulWidget {
  const CarouselSlider({super.key});

  @override
  _CarouselSliderState createState() => _CarouselSliderState();
}

class _CarouselSliderState extends State<CarouselSlider> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final programsProvider = Provider.of<ProgramsProvider>(context, listen: false);
    try {
      await programsProvider.fetchData();
    } catch (e) {
      // Handle error gracefully
    }
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      final programsProvider = Provider.of<ProgramsProvider>(context, listen: false);
      final items = programsProvider.jobList;

      if (items.isEmpty) return;

      int nextPage = (_currentIndex + 1) % items.length;
      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }


  @override
  void dispose() {
    _controller.dispose();
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final programsProvider = Provider.of<ProgramsProvider>(context);
    final items = programsProvider.jobList;

    if (items.isEmpty) {
      return const Center(child: LoadingWidget());
    }

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _controller,
            itemCount: items.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (_, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: CarouselCard(explore: item)
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            items.length,
                (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentIndex == index ? 10 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentIndex == index ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).iconTheme.color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

