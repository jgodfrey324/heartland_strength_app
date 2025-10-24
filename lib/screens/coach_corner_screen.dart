// Main screen for coach's corner content
import 'package:flutter/material.dart';

class CoachCornerScreen extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const CoachCornerScreen({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Coach\'s Corner Content'));
  }
}
