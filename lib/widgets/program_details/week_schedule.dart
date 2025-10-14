// Widget for week schedule structure in the program details page
import 'package:flutter/material.dart';
import 'package:heartlandstrengthapp/utils/workout_utils.dart';
import '../custom_button.dart';
import '../add_workout_modal.dart';
import '../../services/train_service.dart';

class WeekSchedule extends StatelessWidget {
  final int durationWeeks;
  final String programId;

  /// The program schedule map from Firestore
  /// Example:
  /// {
  ///   'week0': {
  ///     'day0': ['workoutId1', 'workoutId2'],
  ///     'day1': [],
  ///     ...
  ///   },
  ///   'week1': { ... }
  /// }
  final Map<String, Map<String, List<String>>> schedule;

  /// Map of all workouts keyed by workoutId to display titles
  final Map<String, Workout> workoutsById;

  const WeekSchedule({
    super.key,
    required this.durationWeeks,
    required this.programId,
    required this.schedule,
    required this.workoutsById,
  });

  void _showAddWorkoutModal(BuildContext context, int weekIndex, int dayIndex) {
    showSlideInModal(
      context,
      AddWorkoutModal(
        programId: programId,
        weekIndex: weekIndex,
        dayIndex: dayIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(durationWeeks, (weekIndex) {
        final weekKey = 'week$weekIndex';
        final weekSchedule = schedule[weekKey] ?? {};

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Week ${weekIndex + 1}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(7, (dayIndex) {
                final dayKey = 'day$dayIndex';
                final workoutIdsForDay = weekSchedule[dayKey] ?? [];

                // Get Workout objects from IDs
                final workoutsForDay = workoutIdsForDay
                    .map((id) => workoutsById[id])
                    .whereType<Workout>()
                    .toList();

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      children: [
                        Text('Day ${dayIndex + 1}'),
                        const SizedBox(height: 4),

                        // Display each workout on this day
                        if (workoutsForDay.isNotEmpty)
                          ...workoutsForDay.map((workout) {
                            return GestureDetector(
                              onTap: () => handleWorkoutTapped(
                                context: context,
                                workout: workout,
                                trainService: TrainService(),
                                mounted: true,
                              ),
                              child: Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(workout.title),
                                ),
                              ),
                            );
                          }).toList(),

                        const SizedBox(height: 8),

                        // Always show the + Workout button below workouts
                        DragTarget<String>(
                          builder: (context, candidateData, rejectedData) {
                            return CustomButton(
                              text: '+ Workout',
                              onPressed: () => _showAddWorkoutModal(context, weekIndex, dayIndex),
                            );
                          },
                          onAccept: (data) {
                            // TODO: Handle drop logic later if needed
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
          ],
        );
      }),
    );
  }
}
