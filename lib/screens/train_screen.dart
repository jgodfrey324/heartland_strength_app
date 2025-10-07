// Entry point for training screen
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/train_service.dart';
import '../utils/workout_utils.dart';

class TrainScreen extends StatefulWidget {
  final String userId;

  const TrainScreen({super.key, required this.userId});

  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  final TrainService _trainService = TrainService();

  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  List<Workout> allWorkouts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    selectedDay = focusedDay;
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    try {
      final workouts = await _trainService.getUserWorkouts(widget.userId);
      setState(() {
        allWorkouts = workouts;
        isLoading = false;
      });
    } catch (e) {
      // Handle error properly in real app
      debugPrint('Error loading workouts: $e');
      setState(() => isLoading = false);
    }
  }

  List<Workout> _getWorkoutsForDay(DateTime day) {
    return allWorkouts.where((w) => isSameDay(w.date, day)).toList();
  }


  @override
  Widget build(BuildContext context) {
    final workoutsForSelectedDay = selectedDay != null
        ? _getWorkoutsForDay(selectedDay!)
        : <Workout>[];

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: focusedDay,
                    selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                    onDaySelected: (selected, focused) {
                      setState(() {
                        selectedDay = selected;
                        focusedDay = focused;
                      });
                    },
                    calendarFormat: CalendarFormat.week,
                    availableCalendarFormats: const {
                      CalendarFormat.week: 'Week',
                    },
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                    eventLoader: _getWorkoutsForDay,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: workoutsForSelectedDay.isEmpty
                          ? const Center(child: Text('No workouts scheduled for this day.'))
                          : ListView.builder(
                              itemCount: workoutsForSelectedDay.length,
                              itemBuilder: (context, index) {
                                final workout = workoutsForSelectedDay[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    title: Text(workout.title),
                                    subtitle: Text("Coach: ${workout.coachId}"),
                                    onTap: () => handleWorkoutTapped(
                                      context: context,
                                      workout: workout,
                                      trainService: _trainService,
                                      mounted: mounted,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
