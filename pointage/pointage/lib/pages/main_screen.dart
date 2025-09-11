import 'package:flutter/material.dart';
import 'home/modern_home_page.dart';
import 'tasks/modern_tasks_page.dart';
import 'pointage/modern_pointage_page.dart';
import 'account/modern_account_page.dart';
import '../widgets/modern_navigation.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    const ModernHomePage(),
    const ModernTasksPage(),
    const ModernPointagePage(),
    const ModernAccountPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      backgroundColor: const Color(0xFFF5F7FA),
      bottomNavigationBar: ModernBottomNavigationBar(
        selectedIndex: selectedIndex,
        onItemTapped: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}
