import 'package:avvento_media/componets/app_constants.dart';
import 'package:flutter/material.dart';
import '../componets/prayer_request_field.dart';

class PrayerRequestPage extends StatelessWidget {
  const PrayerRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:   Theme.of(context).colorScheme.surface,
      body:  CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor:   Theme.of(context).colorScheme.surface,
            floating: true,
            iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
            title: Text(AppConstants.prayerRequest,style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary
            ),),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: AppConstants.left_main, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20,),
                  PrayerRequestField(),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }
}
