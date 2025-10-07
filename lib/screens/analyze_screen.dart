// Entry point for analysis screen
import 'package:flutter/material.dart';

class AnalyzeScreen extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const AnalyzeScreen({Key? key, this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Analyze Content'));
  }
}
