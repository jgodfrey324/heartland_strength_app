// Basic mobile app entry screen
import 'package:flutter/material.dart';
import '../train_screen.dart';
import '../analyze_screen.dart';
import '../announcements_screen.dart';
import '../profile_screen.dart';

class MobileAppScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;
  final VoidCallback onSignOut;

  const MobileAppScreen({
    super.key,
    required this.userId,
    required this.userData,
    required this.onSignOut
  });

  @override
  State<MobileAppScreen> createState() => _MobileAppScreenState();
}

class _MobileAppScreenState extends State<MobileAppScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> get _screens => [
        TrainScreen(userId: widget.userId),
        AnalyzeScreen(userData: widget.userData),
        AnnouncementsScreen(userData: widget.userData),
        ProfileScreen(userData: widget.userData),
      ];

  String get _appBarTitle {
    switch (_selectedIndex) {
      case 0:
        return 'Train';
      case 1:
        return 'Analyze';
      case 2:
        return 'Announcements';
      case 3:
        return 'Profile';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onSignOut,
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Train',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analyze',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: 'Announcements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
