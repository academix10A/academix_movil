import 'package:flutter/material.dart';
import 'package:academix/core/widgets/app_button_navigation.dart';
import 'package:academix/features/library/presentation/view/library_screen.dart';
import 'package:academix/features/note/presentation/view/notes_screen.dart';
import 'package:academix/features/exam/presentation/view/exams_screen.dart';
import 'package:academix/features/profile/presentation/view/profile_screen.dart';
import 'package:academix/features/home/presentation/view/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    LibraryScreen(),
    NotesScreen(),
    ExamsScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

