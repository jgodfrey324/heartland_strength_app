// Entry point for training screen
import 'package:flutter/material.dart';

class TrainScreen extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const TrainScreen({Key? key, this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Train Content'));
  }
}
