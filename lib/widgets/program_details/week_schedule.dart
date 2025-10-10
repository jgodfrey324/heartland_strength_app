// Widget for week schedule structure in the program details page
import 'package:flutter/material.dart';

class WeekSchedule extends StatelessWidget {
  final int durationWeeks;

  const WeekSchedule({super.key, required this.durationWeeks});

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
                                child: Draggable<String>(
                                  data: 'Workout $weekIndex-$dayIndex',
                                  feedback: Material(
                                    color: Colors.transparent,
                                    child: Container(
                                      width: 100,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurpleAccent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text('Workout', style: TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  childWhenDragging: const Opacity(
                                    opacity: 0.3,
                                    child: Text('Dragging...'),
                                  ),
                                  child: const Text('Workout'),
                                ),
                              ),
                            );
                          },
                          onAccept: (data) {
                            // TODO: Handle drop logic
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
