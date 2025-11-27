import 'package:flutter/material.dart';
import 'package:pointage/services/AuthService.dart';
import '../main_screen.dart';
import '../../utils/constants.dart';
import 'change_password_page.dart';

/// Helper class pour les transitions de navigation
class NavigationTransitions {
  /// Transition slide depuis la droite
  static PageRouteBuilder<T> slideFromRight<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Transition fade
  static PageRouteBuilder<T> fade<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}

class PointageLoginPage extends StatefulWidget {
  const PointageLoginPage({Key? key}) : super(key: key);

  @override
  State<PointageLoginPage> createState() => _PointageLoginPageState();
}

class _PointageLoginPageState extends State<PointageLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Fermer le clavier avant la validation
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        rememberMe: false,
      );

      if (result['success']) {
        // Navigation vers la page de pointage avec suppression de l'historique
        if (mounted) {
          // Délai court pour permettre à l'UI de se mettre à jour
          await Future.delayed(const Duration(milliseconds: 100));

          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              NavigationTransitions.slideFromRight(const MainScreen()),
              (route) => false, // Empêche le retour à la page de connexion
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Erreur de connexion'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),

                    // Logo avec effet de glow
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(),
                        child: Image.asset(
                          'assets/images/image.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Titre "Welcome back!"
                    const Text(
                      'Bienvenue !',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF212121),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Sous-titre
                    const Text(
                      'Connectez-vous à votre compte',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF757575),
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Champ Username avec icône
                    Center(
                      child: _buildInputField(
                        controller: _emailController,
                        hintText: 'Username',
                        icon: Icons.person_outline,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez saisir votre email';
                          }
                          if (!RegExp(
                            PointageConstants.EMAIL_REGEX,
                          ).hasMatch(value)) {
                            return 'Veuillez saisir un email valide';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Champ Password avec icône
                    Center(child: _buildPasswordField()),

                    const SizedBox(height: 52),

                    // Bouton Sign in
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF007BFF).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007BFF),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          elevation: 0,
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  'Sign in',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Lien "Don't have an account? Sign up here"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Mot de passe oublié? ",
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF757575),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => const ChangePasswordPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Forgot password',
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFF007BFF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fieldWidth = screenWidth > 350 ? 291.0 : screenWidth - 60;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: fieldWidth,
          height: 43,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.59),
            borderRadius: BorderRadius.circular(21.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF007BFF).withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 50, right: 20),
            child: Center(
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'Roboto',
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    color: Color(0xFF707070),
                    fontSize: 12,
                    fontFamily: 'Roboto',
                  ),
                  border: InputBorder.none,
                ),
                validator: validator,
              ),
            ),
          ),
        ),
        // Cercle blanc avec icône
        Positioned(
          left: -18,
          top: -1,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF007BFF).withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Icon(icon, color: const Color(0xFF1A365D), size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    final screenWidth = MediaQuery.of(context).size.width;
    final fieldWidth = screenWidth > 350 ? 291.0 : screenWidth - 60;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: fieldWidth,
          height: 43,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.59),
            borderRadius: BorderRadius.circular(21.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF007BFF).withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 50, right: 20),
            child: Center(
              child: TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'Roboto',
                ),
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: const TextStyle(
                    color: Color(0xFF707070),
                    fontSize: 12,
                    fontFamily: 'Roboto',
                  ),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF707070),
                      size: 18,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir votre mot de passe';
                  }
                  if (value.length < PointageConstants.MIN_PASSWORD_LENGTH) {
                    return 'Le mot de passe doit contenir au moins ${PointageConstants.MIN_PASSWORD_LENGTH} caractères';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
        // Cercle blanc avec icône de cadenas
        Positioned(
          left: -18,
          top: -2,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF007BFF).withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Icon(Icons.lock, color: const Color(0xFF1A365D), size: 20),
            ),
          ),
        ),
      ],
    );
  }
}
