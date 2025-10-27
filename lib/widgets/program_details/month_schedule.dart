import 'package:flutter/material.dart';

class MonthSchedule extends StatelessWidget {
  final String programId;
  final Map<String, List<String>> schedule;
  final Map<String, dynamic> workoutsById;

  const MonthSchedule({
    super.key,
    required this.programId,
    required this.schedule,
    required this.workoutsById,
  });

  @override
  Widget build(BuildContext context) {
    // Sort schedule by date
    final sortedDates = schedule.keys.toList()
      ..sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: sortedDates.map((dateKey) {
        final workouts = schedule[dateKey] ?? [];
        return Container(
          constraints: const BoxConstraints(
            minWidth: 250,
            minHeight: 500,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateKey,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Divider(),
              Expanded(
                child: workouts.isEmpty
                    ? const Center(child: Text('No workouts'))
                    : ListView.builder(
                        itemCount: workouts.length,
                        itemBuilder: (context, i) {
                          final workoutId = workouts[i];
                          final workout = workoutsById[workoutId];
                          final name = workout?['title'] ?? 'Workout $workoutId';
                          return Card(
                            color: Colors.white,
                            child: ListTile(
                              dense: true,
                              title: Text(name),
                              subtitle: Text('ID: $workoutId'),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
