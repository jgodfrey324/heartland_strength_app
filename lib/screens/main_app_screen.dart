import 'package:flutter/material.dart';
import '../services/auth_services.dart';
import 'home_screen.dart';
import 'announcements_screen.dart';
import 'analyze_screen.dart';
import 'profile_screen.dart';
import 'train_page.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  final AuthService _authService = AuthService();

  // State vars
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  int _selectedIndex = 0;

  // Functions from services
  void _signOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }
  Future<void> _fetchUserData() async {
    final data = await _authService.fetchUserData();
    if (data == null) {
      _signOut();
      return;
    }
    setState(() {
      _userData = data;
      _isLoading = false;
    });
  }

  // Get initial user data
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // For bottom nav bar tabs
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Screens for the tabs:
  List<Widget> get _screens => [
        AnnouncementsScreen(userData: _userData),
        TrainScreen(userData: _userData),
        AnalyzeScreen(userData: _userData),
        ProfileScreen(userData: _userData),
      ];

  // Titles for AppBar based on selected tab:
  String get _appBarTitle {
    switch (_selectedIndex) {
      case 0:
        return 'Announcements';
      case 1:
        return 'Train';
      case 2:
        return 'Analyze';
      case 3:
        return 'Profile';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
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
            icon: Icon(Icons.announcement),
            label: 'Announcements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Train',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analyze',
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
