// Widget for week schedule structure in the library details page
import 'package:flutter/material.dart';
import 'package:heartlandstrengthapp/utils/workout_utils.dart';
import 'package:heartlandstrengthapp/widgets/workout_card.dart';
import '../add_workout_modal.dart';
import '../../services/train_service.dart';

class WeekSchedule extends StatefulWidget {
  final int durationWeeks;
  final String libraryId;
  final Map<String, Map<String, List<String>>> schedule;
  final Map<String, Workout> workoutsById;

  const WeekSchedule({
    super.key,
    required this.durationWeeks,
    required this.libraryId,
    required this.schedule,
    required this.workoutsById,
  });

  @override
  State<WeekSchedule> createState() => _WeekScheduleState();
}

class _WeekScheduleState extends State<WeekSchedule> {
  final TrainService _trainService = TrainService();
  late Map<String, Map<String, List<String>>> _schedule;

  @override
  void initState() {
    super.initState();
    _schedule = Map.from(widget.schedule);
  }

  void _showAddWorkoutModal(BuildContext context, int weekIndex, int dayIndex) {
    showSlideInModal(
      context,
      AddWorkoutModal(
        libraryId: widget.libraryId,
        weekIndex: weekIndex,
        dayIndex: dayIndex,
      ),
    );
  }

  void _showEditWorkoutModal({
    required BuildContext context,
    required int weekIndex,
    required int dayIndex,
    required String workoutId,
  }) {
    showSlideInModal(
      context,
      AddWorkoutModal(
        libraryId: widget.libraryId,
        weekIndex: weekIndex,
        dayIndex: dayIndex,
        existingWorkoutId: workoutId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.durationWeeks, (weekIndex) {
        final weekKey = 'week$weekIndex';
        final weekSchedule = _schedule[weekKey] ?? {};

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
                    .map((id) => widget.workoutsById[id])
                    .whereType<Workout>()
                    .toList();

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      children: [
                        Text('Day ${dayIndex + 1}'),
                        const SizedBox(height: 4),

                        // DragTarget wraps the entire container
                        DragTarget<Map<String, dynamic>>(
                          onWillAccept: (data) => data != null,
                          onAccept: (data) async {
                            final workoutId = data['workoutId'] as String;
                            final fromWeek = data['fromWeek'] as int;
                            final fromDay = data['fromDay'] as int;

                            if (fromWeek != weekIndex || fromDay != dayIndex) {
                              await _trainService.updateScheduleOnDrop(
                                libraryId: widget.libraryId,
                                currentSchedule: _schedule,
                                workoutId: workoutId,
                                fromWeek: fromWeek,
                                fromDay: fromDay,
                                toWeek: weekIndex,
                                toDay: dayIndex,
                                onLocalUpdate: (updatedSchedule) {
                                  setState(() {
                                    _schedule = updatedSchedule;
                                  });
                                },
                              );
                            }
                          },
                          builder: (context, candidateData, rejectedData) {
                            return Container(
                              constraints: const BoxConstraints(minHeight: 500),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: candidateData.isNotEmpty
                                      ? Colors.blueAccent
                                      : Colors.grey.shade400,
                                  width: candidateData.isNotEmpty ? 3 : 1,
                                ),
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
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: workoutsForDay.length,
                                      itemBuilder: (context, index) {
                                        final workout = workoutsForDay[index];
                                        final workoutId = workoutIdsForDay[index];
                                        return LongPressDraggable<Map<String, dynamic>>(
                                          data: {
                                            'workoutId': workoutId,
                                            'fromWeek': weekIndex,
                                            'fromDay': dayIndex,
                                          },
                                          feedback: Material(
                                            elevation: 4,
                                            child: Container(
                                              width: 200,
                                              child: WorkoutCard(
                                                workout: workout,
                                                onWorkoutTap: (_) => _showEditWorkoutModal(
                                                  context: context,
                                                  weekIndex: weekIndex,
                                                  dayIndex: dayIndex,
                                                  workoutId: workout.id,
                                                ),
                                              ),
                                            ),
                                          ),
                                          childWhenDragging: Opacity(
                                            opacity: 0.5,
                                            child: WorkoutCard(
                                              workout: workout,
                                              onWorkoutTap: (_) => _showEditWorkoutModal(
                                                context: context,
                                                weekIndex: weekIndex,
                                                dayIndex: dayIndex,
                                                workoutId: workout.id,
                                              ),
                                            ),
                                          ),
                                          child: WorkoutCard(
                                            workout: workout,
                                            onWorkoutTap: (_) => _showEditWorkoutModal(
                                              context: context,
                                              weekIndex: weekIndex,
                                              dayIndex: dayIndex,
                                              workoutId: workout.id,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            );
                          },
                        ),

                        const SizedBox(height: 8),

                        ElevatedButton(
                          onPressed: () => _showAddWorkoutModal(context, weekIndex, dayIndex),
                          child: const Text('+ Workout'),
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
