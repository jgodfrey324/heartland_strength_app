import 'package:flutter/material.dart';
import 'package:heartlandstrengthapp/services/train_service.dart';

typedef WorkoutTapCallback = void Function(Workout workout);

class WorkoutCard extends StatelessWidget {
  final Workout workout;
  final WorkoutTapCallback? onWorkoutTap;

  const WorkoutCard({
    Key? key,
    required this.workout,
    this.onWorkoutTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onWorkoutTap?.call(workout),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                workout.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              // Description
              if (workout.details.isNotEmpty)
                Text(
                  workout.details,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),

              const SizedBox(height: 12),

              // Movements List
              ...workout.movements.asMap().entries.map((entry) {
                final movementIndex = entry.key;
                final wm = entry.value;
                final movementTitle = wm.movementName.isNotEmpty
                    ? wm.movementName
                    : 'Movement ${movementIndex + 1}';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${movementIndex + 1}. $movementTitle',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      ...wm.sets.map((set) {
                        final reps = set['reps'] ?? '-';
                        final weightPercent = set['weightPercent'] ?? '-';
                        return Text(
                          '• $reps reps @ $weightPercent%',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        );
                      }).toList(),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
