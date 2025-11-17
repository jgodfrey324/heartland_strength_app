import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class MonthSchedule extends StatefulWidget {
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
  State<MonthSchedule> createState() => _MonthScheduleState();
}

class _MonthScheduleState extends State<MonthSchedule> {
  late final Map<DateTime, List<String>> events;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  @override
  void initState() {
    super.initState();
    events = widget.schedule.map((key, workouts) {
      final date = DateTime.parse(key);
      return MapEntry(DateTime(date.year, date.month, date.day), workouts);
    });
  }

  List<String> _getEventsForDay(DateTime day) {
    final clean = DateTime(day.year, day.month, day.day);
    return events[clean] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime(2020),
          lastDay: DateTime(2100),
          focusedDay: focusedDay,
          selectedDayPredicate: (day) =>
              selectedDay != null &&
              day.year == selectedDay!.year &&
              day.month == selectedDay!.month &&
              day.day == selectedDay!.day,

          eventLoader: _getEventsForDay,

          calendarFormat: CalendarFormat.month,

          onDaySelected: (selected, focused) {
            setState(() {
              selectedDay = selected;
              focusedDay = focused;
            });
          },

          onPageChanged: (focused) {
            focusedDay = focused;
          },

          calendarStyle: const CalendarStyle(
            todayDecoration:
                BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
          ),
        ),

        const SizedBox(height: 16),

        /// Workout list for selected day
        Expanded(
          child: selectedDay == null
              ? const Center(child: Text("Select a day"))
              : ListView(
                  children: _getEventsForDay(selectedDay!).map((workoutId) {
                    final workout = widget.workoutsById[workoutId];
                    final name =
                        workout?['title'] ?? 'Workout $workoutId';
                    return Card(
                      child: ListTile(
                        title: Text(name),
                        subtitle: Text('ID: $workoutId'),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}
