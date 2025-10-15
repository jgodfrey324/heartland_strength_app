// Widget for week schedule structure in the program details page
import 'package:flutter/material.dart';
import 'package:heartlandstrengthapp/utils/workout_utils.dart';
import 'package:heartlandstrengthapp/widgets/workout_card.dart';
import '../add_workout_modal.dart';
import '../../services/train_service.dart';

class WeekSchedule extends StatelessWidget {
  final int durationWeeks;
  final String programId;
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

                        // The rectangle container with min height 500
                        Container(
                          constraints: const BoxConstraints(minHeight: 500),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: workoutsForDay.isEmpty
                              ? Center(
                                  child: Text(
                                    'No workouts',
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                )
                              : WorkoutCard(
                                  workouts: workoutsForDay,
                                  onWorkoutTap: (workout) => handleWorkoutTapped(
                                    context: context,
                                    workout: workout,
                                    trainService: TrainService(),
                                    mounted: true,
                                  ),
                                ),
                        ),

                        const SizedBox(height: 8),

                        DragTarget<String>(
                          builder: (context, candidateData, rejectedData) {
                            return ElevatedButton(
                              onPressed: () => _showAddWorkoutModal(context, weekIndex, dayIndex),
                              child: const Text('+ Workout'),
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
