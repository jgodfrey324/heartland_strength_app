// UI helpers for training screen
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/train_service.dart';

/// Handles tap on a workout card by showing details in a dialog.
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: workout.movements.map((wm) {
            final movement = movementMap[wm.movementId];
            if (movement == null) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movement.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  ...wm.sets.entries.map((entry) {
                    final set = entry.value;
                    final reps = set['reps'];
                    final weight = set['weightPercent'];
                    return Text("• $reps reps @ $weight%");
                  }),
                ],
              ),
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

/// Fetches a workout as raw map (use only if you need raw data, otherwise use TrainService).
Future<Map<String, dynamic>?> fetchWorkout(String workoutId) async {
  final doc = await FirebaseFirestore.instance
      .collection('workouts')
      .doc(workoutId)
      .get();

  return doc.data();
}

void showSlideInModal(BuildContext context, Widget child) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: false, // Don't close on outside tap
      barrierColor: Colors.black54, // Optional backdrop color
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5, // 50% width
            height: MediaQuery.of(context).size.height,     // 100% height
            child: Material(
              color: Colors.white,
              elevation: 8,
              child: child,
            ),
          ),
        );
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(1, 0), // Slide in from the right
          end: Offset.zero,
        ).animate(animation);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    ),
  );
}
