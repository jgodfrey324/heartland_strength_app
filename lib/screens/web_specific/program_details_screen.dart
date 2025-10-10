// Entry point for program details. Reached by clicking on program in program_screen
import 'package:flutter/material.dart';

class ProgramDetailsScreen extends StatelessWidget {
  final String programId;
  final Map<String, dynamic> programData;

  const ProgramDetailsScreen({
    super.key,
    required this.programId,
    required this.programData,
  });

  @override
  Widget build(BuildContext context) {
    final title = programData['title'] ?? 'Unnamed Program';
    final description = programData['description'] ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(description),
            const SizedBox(height: 24),
            const Text('Program details will go here...'),
          ],
        ),
      ),
    );
  }
}
