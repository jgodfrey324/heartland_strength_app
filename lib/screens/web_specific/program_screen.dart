// Entry point for programming screen
import 'package:flutter/material.dart';

class ProgramScreen extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const ProgramScreen({super.key, this.userData});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Programming Content'));
  }
}
