import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 3.0,
        color: Colors.amber,
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}