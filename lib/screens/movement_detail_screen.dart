// Navigation from train_screen, shows movement details and logging
import 'package:flutter/material.dart';
import '../services/train_service.dart';

class MovementDetailScreen extends StatelessWidget {
  final Movement movement;

  const MovementDetailScreen({super.key, required this.movement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movement.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                movement.description,
                style: const TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(height: 24),

            // Table header
            const Text(
              'Workout Log',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Simple static table for now
            Table(
              border: TableBorder.all(),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              children: const [
                TableRow(
                  decoration: BoxDecoration(color: Colors.black12),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Sets', textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Reps', textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('KG', textAlign: TextAlign.center),
                    ),
                  ],
                ),
                // Placeholder row - you can later make this dynamic
                TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('3', textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('10', textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('50', textAlign: TextAlign.center),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
