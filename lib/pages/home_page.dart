import 'package:avvento_media/widgets/hightlights/hightlights_widget.dart';
import 'package:avvento_media/widgets/radio/live_radio_widget.dart';
import 'package:flutter/material.dart';

import '../componets/app_constants.dart';
import '../widgets/liveTv/live_tv_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Theme.of(context).colorScheme.background,
              floating: true,
              title: const Text(AppConstants.appName),
            ),
            const SliverToBoxAdapter(
              child: Column(
                children: [
                  Divider(),
                  HightlightsWidget(),
                  SizedBox(height: 20,),
                  LiveTvWidget(),
                  SizedBox(height: 20,),
                  LiveRadioWidget()
                ],
              ),
            ),
          ],
        ),
    );
  }
}
