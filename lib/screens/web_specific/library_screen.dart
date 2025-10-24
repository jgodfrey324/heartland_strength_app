// Entry point for library screen
import 'package:flutter/material.dart';
import '../../widgets/libraries/add_library_sidebar.dart';
import '../../widgets/libraries/libraries_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/custom_button.dart';

class LibraryScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const LibraryScreen({super.key, this.userData});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
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
                    'All Libraries',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  CustomButton(
                    text: '+ Library',
                    onPressed: toggleSidebar,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Expanded(child: LibrariesList()),
            ],
          ),
        ),

        // Right sidebar
        if (showSidebar)
          Align(
            alignment: Alignment.centerRight,
            child: AddLibrarySidebar(
              onCancel: toggleSidebar,
              createdByUserId: userId,
            ),
          ),
      ],
    );
  }
}
