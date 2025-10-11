// Workout header for add_workout_modal
import 'package:flutter/material.dart';

class WorkoutHeader extends StatelessWidget {
  final bool isEditing;
  final int weekIndex;
  final int dayIndex;

  const WorkoutHeader({
    super.key,
    required this.isEditing,
    required this.weekIndex,
    required this.dayIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 5,
          width: 40,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Text(
          isEditing
              ? 'Edit Workout'
              : 'Add Workout for Week ${weekIndex + 1}, Day ${dayIndex + 1}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
