import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pointage/bloc/auth/auth_bloc.dart';
import 'package:pointage/bloc/auth/auth_event.dart';
import 'package:pointage/bloc/auth/auth_state.dart';
import '../../utils/constants.dart';
import 'login_page.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({Key? key}) : super(key: key);

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    // Dispatcher l'événement de changement de mot de passe
    if (mounted) {
      context.read<AuthBloc>().add(
        AuthChangePasswordEvent(
          email: _emailController.text.trim(),
          password: _oldPasswordController.text,
          newPassword: _newPasswordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthPasswordChangedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );

          // Retourner à la page de login après 1 seconde
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const PointageLoginPage(),
                ),
              );
            }
          });
        } else if (state is AuthErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF212121)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoadingState;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/image.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Titre
                      const Text(
                        'Modifier le mot de passe',
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
                        'Saisissez votre nouveau mot de passe',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF757575),
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Champ Email
                      Center(
                        child: _buildInputField(
                          controller: _emailController,
                          hintText: 'Email',
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

                      // Champ Ancien mot de passe
                      Center(
                        child: _buildPasswordField(
                          controller: _oldPasswordController,
                          hintText: 'Ancien mot de passe',
                          obscureText: _obscureOldPassword,
                          onToggleVisibility: () {
                            setState(() {
                              _obscureOldPassword = !_obscureOldPassword;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir votre ancien mot de passe';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Champ Nouveau mot de passe
                      Center(
                        child: _buildPasswordField(
                          controller: _newPasswordController,
                          hintText: 'Nouveau mot de passe',
                          obscureText: _obscureNewPassword,
                          onToggleVisibility: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir un nouveau mot de passe';
                            }
                            if (value.length <
                                PointageConstants.MIN_PASSWORD_LENGTH) {
                              return 'Le mot de passe doit contenir au moins ${PointageConstants.MIN_PASSWORD_LENGTH} caractères';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Bouton Modifier
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
                          onPressed: isLoading ? null : _changePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007BFF),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            elevation: 0,
                          ),
                          child:
                              isLoading
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
                                    'Modifier',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
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
                blurRadius: 10,
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
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
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 50, right: 20),
            child: Center(
              child: TextFormField(
                controller: controller,
                obscureText: obscureText,
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
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF707070),
                      size: 18,
                    ),
                    onPressed: onToggleVisibility,
                  ),
                ),
                validator: validator,
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
