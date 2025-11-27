import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

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
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Adapter la hauteur selon la taille de l'écran
    // Petits écrans (< 700px) : 60px, Moyens (700-850px) : 65px, Grands (> 850px) : 70px
    double navBarHeight;
    if (screenHeight < 700) {
      navBarHeight = 60.0;
    } else if (screenHeight <= 850) {
      navBarHeight = 65.0;
    } else {
      navBarHeight = 70.0;
    }
    
    // Adapter la taille des icônes selon la taille de l'écran
    double iconSize;
    if (screenHeight < 700) {
      iconSize = 22.0;
    } else if (screenHeight <= 850) {
      iconSize = 25.0;
    } else {
      iconSize = 28.0;
    }
    
    // Adapter selon la densité d'écran (pixels par pouce)
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    if (devicePixelRatio > 3.0) {
      // Écrans haute densité (ex: iPhone avec Retina)
      iconSize *= 1.1;
    }
    
    return CurvedNavigationBar(
      index: selectedIndex,
      height: navBarHeight,
      items: <Widget>[
        Icon(
          Icons.qr_code_2,
          size: iconSize,
          color: selectedIndex == 0 ? Colors.white : const Color(0xFFFF5C02),
        ),
        Icon(
          Icons.person,
          size: iconSize,
          color: selectedIndex == 1 ? Colors.white : const Color(0xFFFF5C02),
        ),
      ],
      color: Colors.white,
      buttonBackgroundColor: const Color(0xFFFF5C02),
      backgroundColor: Colors.transparent,
      animationCurve: Curves.easeInOutCubic,
      animationDuration: const Duration(milliseconds: 400),
      onTap: onItemTapped,
      letIndexChange: (index) => true,
    );
  }
}
