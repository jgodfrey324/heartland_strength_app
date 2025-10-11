// Workout form fields for creating / editing a workout within the modal
import 'package:flutter/material.dart';

class WorkoutFormFields extends StatelessWidget {
  final String initialTitle;
  final String initialDetails;
  final void Function(String) onSaveTitle;
  final void Function(String) onSaveDetails;

  const WorkoutFormFields({
    super.key,
    required this.initialTitle,
    required this.initialDetails,
    required this.onSaveTitle,
    required this.onSaveDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          initialValue: initialTitle,
          decoration: const InputDecoration(labelText: 'Title'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          onSaved: (v) => onSaveTitle(v!.trim()),
        ),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: initialDetails,
          decoration: const InputDecoration(labelText: 'Details'),
          maxLines: 2,
          onSaved: (v) => onSaveDetails(v?.trim() ?? ''),
        ),
        const SizedBox(height: 75),
      ],
    );
  }
}
