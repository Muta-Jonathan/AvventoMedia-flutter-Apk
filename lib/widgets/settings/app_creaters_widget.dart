import 'package:avvento_media/componets/app_constants.dart';
import 'package:flutter/material.dart';

class AppCreatorsWidget extends StatelessWidget {
  const AppCreatorsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppConstants.from,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              fontSize: 14,
              //fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4,),
          const Text(
            AppConstants.appName,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
