// Entry point for program screen
import 'package:flutter/material.dart';
import '../../widgets/programs/add_program_sidebar.dart';
import '../../widgets/programs/programs_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/custom_button.dart';

class ProgramScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const ProgramScreen({super.key, this.userData});

  @override
  State<ProgramScreen> createState() => _ProgramScreenState();
}

class _ProgramScreenState extends State<ProgramScreen> {
  bool showSidebar = false;

  void toggleSidebar() {
    setState(() {
      showSidebar = !showSidebar;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Stack(
      children: [
        // Main content
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All Programs',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  CustomButton(
                    text: '+ Program',
                    onPressed: toggleSidebar,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Expanded(child: ProgramsList()),
            ],
          ),
        ),

        // Right sidebar
        if (showSidebar)
          Align(
            alignment: Alignment.centerRight,
            child: AddProgramSidebar(
              onCancel: toggleSidebar,
              createdByUserId: userId,
            ),
          ),
      ],
    );
  }
}
