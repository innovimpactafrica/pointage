import 'package:flutter/material.dart';
import 'dart:async';
import '../auth/login_page.dart';
import '../../services/AuthService.dart';
import '../main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _showText = false;
  late AnimationController _iconController;
  late AnimationController _textController;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    
    // Animation pour l'icône (scale + fade)
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _iconScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.elasticOut,
    ));
    
    _iconFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeIn,
    ));
    
    // Animation pour le texte (fade + slide)
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));
    
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    // Démarrer l'animation de l'icône immédiatement
    _iconController.forward();

    // Vérifier l'authentification et naviguer
    _checkAuthenticationAndNavigate();
  }

  Future<void> _checkAuthenticationAndNavigate() async {
    // Afficher le texte après 2 secondes
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showText = true;
        });
        _textController.forward();
      }
    });

    // Vérifier le token après 2 secondes (pendant l'animation)
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      try {
        // Vérifier si le token est valide (moins de 20 jours)
        final isValid = await _authService.isTokenValid();
        
        // Naviguer après 3 secondes supplémentaires (5 secondes au total)
        await Future.delayed(const Duration(seconds: 3));
        
        if (mounted) {
          if (isValid) {
            // Token valide, mettre à jour la date de dernière activité
            await _authService.updateLastActivity();
            // Rediriger vers l'écran principal
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const MainScreen(),
              ),
            );
          } else {
            // Token invalide ou expiré, rediriger vers la page de login
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const PointageLoginPage(),
              ),
            );
          }
        }
      } catch (e) {
        // En cas d'erreur, rediriger vers la page de login
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const PointageLoginPage(),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _iconController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A365D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône avec animation de scale et fade
           /* FadeTransition(
              opacity: _iconFadeAnimation,
              child: ScaleTransition(
                scale: _iconScaleAnimation,
                child: Image.asset(
                  'assets/images/image.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
            ),*/
            
            // Espacement
            const SizedBox(height: 40),
            
            // Texte qui apparaît après 2 secondes avec animation fade + slide
            if (_showText)
              FadeTransition(
                opacity: _textFadeAnimation,
                child: SlideTransition(
                  position: _textSlideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Bienvenue à Innov & Impact Africa, le carrefour stratégique de l\'innovation et de la performance',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

