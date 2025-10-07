// UI helpers for training screen
import 'package:flutter/material.dart';
import '../services/train_service.dart';

Future<void> handleWorkoutTapped({
  required BuildContext context,
  required Workout workout,
  required TrainService trainService,
  required bool mounted,
}) async {
  final movements = await trainService.getMovementsByIds(workout.movementIds);

  if (!mounted) return;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(workout.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: movements.isEmpty
            ? [const Text('No movements')]
            : movements
                .map((m) => ListTile(
                      title: Text(m.name),
                      subtitle: Text(m.description),
                    ))
                .toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    ),
  );
}
