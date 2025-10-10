// Widget for week schedule structure in the program details page
import 'package:flutter/material.dart';
import '../custom_button.dart';
import '../add_workout_modal.dart';

class WeekSchedule extends StatelessWidget {
  final int durationWeeks;

  const WeekSchedule({super.key, required this.durationWeeks});

  void _showAddWorkoutModal(BuildContext context, int weekIndex, int dayIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.9,
        widthFactor: 1.75,
        child: AddWorkoutModal(weekIndex: weekIndex, dayIndex: dayIndex),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(durationWeeks, (weekIndex) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Week ${weekIndex + 1}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(7, (dayIndex) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      children: [
                        Text('Day ${dayIndex + 1}'),
                        const SizedBox(height: 4),
                        DragTarget<String>(
                          builder: (context, candidateData, rejectedData) {
                            return Container(
                              height: 500,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: CustomButton(
                                  text: '+ Workout',
                                  onPressed: () => _showAddWorkoutModal(context, weekIndex, dayIndex),
                                ),
                              ),
                            );
                          },
                          onAccept: (data) {
                            // TODO: Handle drop logic later
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
