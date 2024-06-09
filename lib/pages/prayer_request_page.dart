import 'package:avvento_media/componets/app_constants.dart';
import 'package:flutter/material.dart';
import '../componets/prayer_request_field.dart';
import '../componets/utils.dart';

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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: AppConstants.leftMain, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: Utils.calculateHeight(context, 0.03)),
                  const PrayerRequestField(),
                ],
              ),
            )
          ),
        ],
      ),
    );
  }
}
