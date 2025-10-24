// Main screen for program details
import 'package:flutter/material.dart';

class ProgramDetailsScreen extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const ProgramDetailsScreen({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Program Details'));
  }
}
