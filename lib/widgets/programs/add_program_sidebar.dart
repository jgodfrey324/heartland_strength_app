// Right sidebar form for program_screen
import 'package:flutter/material.dart';
import '../custom_button.dart';
import '../../services/program_services.dart';

class AddProgramSidebar extends StatefulWidget {
  final VoidCallback onCancel;
  final String createdByUserId;

  const AddProgramSidebar({
    super.key,
    required this.onCancel,
    required this.createdByUserId,
  });

  @override
  State<AddProgramSidebar> createState() => _AddProgramSidebarState();
}

class _AddProgramSidebarState extends State<AddProgramSidebar> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // For building the dynamic date → workout list structure
  Map<String, List<String>> schedule = {};
  DateTime? selectedDate;
  final TextEditingController workoutIdController = TextEditingController();

  bool isLoading = false;

  /// Adds a workout ID to the selected day
  void addWorkoutToSelectedDate() {
    if (selectedDate == null || workoutIdController.text.trim().isEmpty) return;

    final dateKey =
        "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

    setState(() {
      schedule.putIfAbsent(dateKey, () => []);
      schedule[dateKey]!.add(workoutIdController.text.trim());
      workoutIdController.clear();
    });
  }

  /// Handles saving by calling the service function
  Future<void> handleAddProgram() async {
    if (titleController.text.trim().isEmpty) return;

    setState(() {
      isLoading = true;
    });

    await addProgramToFirestore(
      title: titleController.text,
      description: descriptionController.text,
      createdByUserId: widget.createdByUserId,
      schedule: schedule,
    );

    setState(() {
      isLoading = false;
    });

    widget.onCancel();
  }

  /// Opens the date picker to choose a calendar date
  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 16,
      color: Colors.white,
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Add Program',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onCancel,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Fields
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Schedule builder (basic version)
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? 'Selected: ${selectedDate!.toLocal().toString().split(' ')[0]}'
                        : 'No date selected',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => pickDate(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (selectedDate != null) ...[
              TextField(
                controller: workoutIdController,
                decoration: const InputDecoration(
                  labelText: 'Add Workout ID for this date',
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: addWorkoutToSelectedDate,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Workout'),
                ),
              ),
            ],

            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: schedule.entries.map((entry) {
                  return Card(
                    child: ListTile(
                      title: Text(entry.key),
                      subtitle: Text(entry.value.join(', ')),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                isLoading
                    ? const SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(),
                      )
                    : CustomButton(
                        text: 'Add',
                        onPressed: handleAddProgram,
                      ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
