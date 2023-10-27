import 'package:avvento_media/componets/app_constants.dart';
import 'package:flutter/material.dart';
import '../componets/prayer_request_field.dart';

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
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  SizedBox(height: 20,),
                  PrayerRequestField(),
                  Divider(),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }
}
