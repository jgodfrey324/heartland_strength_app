// Right sidebar for add program screen
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

  // schedule is ALWAYS empty
  final Map<String, List<String>> schedule = {};

  bool isLoading = false;

  /// Handles saving by calling the service function
  Future<void> handleAddProgram() async {
    if (titleController.text.trim().isEmpty) return;

    setState(() => isLoading = true);

    await addProgramToFirestore(
      title: titleController.text,
      description: descriptionController.text,
      createdByUserId: widget.createdByUserId,
      schedule: schedule, // always empty {}
    );

    setState(() => isLoading = false);

    widget.onCancel();
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
