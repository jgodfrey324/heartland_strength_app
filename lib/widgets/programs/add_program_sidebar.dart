// Right sidebar form for programs_screen
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../custom_button.dart';

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
  final TextEditingController durationWeeksController = TextEditingController();

  bool isLoading = false;

  Future<void> addProgram() async {
    setState(() {
      isLoading = true;
    });

    final int durationWeeks = int.tryParse(durationWeeksController.text.trim()) ?? 0;

    // Create empty schedule structure
    final Map<String, Map<String, List>> schedule = {};
    for (int week = 0; week < durationWeeks; week++) {
      final Map<String, List> days = {};
      for (int day = 0; day < 7; day++) {
        days['day$day'] = []; // empty list of workout IDs
      }
      schedule['week$week'] = days;
    }

    await FirebaseFirestore.instance.collection('programs').add({
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'durationWeeks': durationWeeks,
      'createdBy': widget.createdByUserId,
      'assignedTo': {
        'users': [],
        'teams': [],
      },
      'schedule': schedule,
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      isLoading = false;
    });

    widget.onCancel();
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 16,
      color: Colors.white,
      child: Container(
        width: 320,
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
            const SizedBox(height: 12),
            TextField(
              controller: durationWeeksController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Duration (weeks)'),
            ),

            const Spacer(),

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
                        onPressed: addProgram,
                      ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
