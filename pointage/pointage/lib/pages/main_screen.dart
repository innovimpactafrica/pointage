import 'package:flutter/material.dart';
import 'pointage/modern_pointage_page.dart';
import 'account/modern_account_page.dart';
import '../widgets/modern_navigation.dart';
import '../services/AuthService.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Index 0 = Pointage, Index 1 = Mon compte
  int selectedIndex = 0;
  final _authService = AuthService();

  final List<Widget> pages = [
    const ModernPointagePage(), // Index 0 - Page de pointage
    const ModernAccountPage(), // Index 1 - Page compte
  ];

  @override
  void initState() {
    super.initState();
    // Mettre à jour la date de dernière activité à chaque ouverture de l'app
    _authService.updateLastActivity();
  }

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
