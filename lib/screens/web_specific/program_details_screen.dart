import 'package:flutter/material.dart';

class ProgramDetailsScreen extends StatelessWidget {
  final String title;
  final String description;
  final int durationWeeks;

  const ProgramDetailsScreen({
    super.key,
    required this.title,
    required this.description,
    required this.durationWeeks,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Program description
              Text(
                description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),

              // Weeks list
              for (int week = 1; week <= durationWeeks; week++) ...[
                Text(
                  'Week $week',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Row of 7 day blocks with labels above
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
                                      data: 'Workout Item',
                                      feedback: Material(
                                        color: Colors.transparent,
                                        child: Container(
                                          width: 100,
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.deepPurpleAccent,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'Workout',
                                            style: TextStyle(color: Colors.white),
                                          ),
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
                                // Handle dropped data here later
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
            ],
          ),
        ),
      ),
    );
  }
}
