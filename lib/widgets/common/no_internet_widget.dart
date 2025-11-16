import 'package:flutter/material.dart';

class NoConnectionMessage extends StatelessWidget {
  const NoConnectionMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.amber[100]!.withOpacity(0.2),
          border: Border.all(
            color: Colors.amber, // Orange border color
            width: 1.0, // Border width
          ),
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
        ),
        child: const Text(
          "No internet connection",
          style: TextStyle(
            color: Colors.amber, // Text color
          ),
        ),
      ),
    );
  }
}
