import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:avvento_media/componets/app_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/text/name_text_field.dart';

class PrayerRequestPage extends StatelessWidget {
  const PrayerRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body:  CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Theme.of(context).colorScheme.background,
            floating: true,
            title: const Text(AppConstants.prayerRequest),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  const SizedBox(height: 20,),
                  NameTextField(name: 'Text',),
                  const Divider(),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }
}
