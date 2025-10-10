import 'package:flutter/material.dart';
import 'package:heartlandstrengthapp/screens/announcements_screen.dart';
import 'package:heartlandstrengthapp/screens/coach_corner_screen.dart';
import 'package:heartlandstrengthapp/screens/profile_screen.dart';
import 'package:heartlandstrengthapp/screens/web_specific/analyze_screen.dart';
import 'package:heartlandstrengthapp/screens/web_specific/manage_screen.dart';
import 'package:heartlandstrengthapp/screens/web_specific/program_screen.dart';

class WebAppScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;
  final VoidCallback onSignOut;

  const WebAppScreen({
    super.key,
    required this.userId,
    required this.userData,
    required this.onSignOut,
  });

  @override
  State<WebAppScreen> createState() => _WebAppScreenState();
}

class _WebAppScreenState extends State<WebAppScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Titles for each screen (used in AppBar and TopNav)
  final List<String> _titles = [
    "Coach's Corner",
    "Analyze",
    "Announcements",
    "Program",
    "Manage",
    "Profile",
  ];

  // Screens list like mobile
  List<Widget> get _screens => [
        CoachCornerScreen(),
        AnalyzeScreen(),
        AnnouncementsScreen(userData: widget.userData),
        ProgramScreen(),
        ManageScreen(),
        ProfileScreen(userData: widget.userData),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          for (int i = 0; i < _titles.length; i++)
            TextButton(
              onPressed: () => _onItemTapped(i),
              child: Text(
                _titles[i],
                style: TextStyle(
                  color: _selectedIndex == i ? Colors.white : Colors.white70,
                  fontWeight: _selectedIndex == i ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: widget.onSignOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
    );
  }
}
