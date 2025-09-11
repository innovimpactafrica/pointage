import 'package:flutter/material.dart';

class ModernBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const ModernBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navItems = [
      _buildNavItem(context, 0, Icons.home, 'Accueil'),
      _buildNavItem(context, 1, Icons.assignment, 'Mes Tâches'),
      _buildNavItem(context, 2, Icons.qr_code_2, 'Pointage'),
      _buildNavItem(context, 3, Icons.person, 'Mon compte'),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
          ),
        ],
      ),
      height: 90,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navItems,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final isSelected = index == selectedIndex;

    return InkWell(
      onTap: () {
        if (!isSelected) {
          onItemTapped(index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 7, left: 7, right: 7),
            child: Icon(
              icon,
              size: 24.0,
              color:
                  isSelected
                      ? const Color(0xFFFF5C02)
                      : const Color(0xFF717171),
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.0,
              color:
                  isSelected
                      ? const Color(0xFFFF5C02)
                      : const Color(0xFF717171),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
