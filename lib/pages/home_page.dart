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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              floating: true,
              iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
              title: Text(AppConstants.appName,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Column(
                children: [
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
