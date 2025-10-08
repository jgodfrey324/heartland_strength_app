// UI helpers for training screen
import 'package:flutter/material.dart';
import '../services/train_service.dart';

Future<void> handleWorkoutTapped({
  required BuildContext context,
  required Workout workout,
  required TrainService trainService,
  required bool mounted,
}) async {
  final movementIds = workout.movements.map((m) => m.movementId).toList();
  final movementMap = await trainService.getMovementMapByIds(movementIds);

  if (!mounted) return;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(workout.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: workout.movements.map((wm) {
            final movement = movementMap[wm.movementId];
            if (movement == null) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movement.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(movement.description),
                ...wm.sets.entries.map((entry) {
                  final setData = entry.value as Map<String, dynamic>;
                  final reps = setData['reps'];
                  final weightPercent = setData['weightPercent'];
                  return Text("• $reps reps @ $weightPercent%");
                }),
                const SizedBox(height: 8),
              ],
            );
          }).toList(),
        ),
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
