import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_state.dart';
import 'auth_event.dart';
import '../../repository/auth_repository.dart';
import '../../services/SharedPreferencesService.dart';
import '../../utils/constants.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository = AuthRepository();
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  AuthBloc() : super(AuthInitialState()) {
    on<AuthLoginEvent>(_onAuthLoginEvent);
    on<AuthSignupEvent>(_onAuthSignupEvent);
    on<AuthLogoutEvent>(_onAuthLogoutEvent);
    on<AuthForgotPasswordEvent>(_onAuthForgotPasswordEvent);
  }

  Future<void> _onAuthLoginEvent(
    AuthLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());

    try {
      final user = await _authRepository.login(event.email, event.password);
      emit(AuthAuthenticatedState(user: user, message: 'Connexion réussie'));
    } catch (e) {
      emit(AuthErrorState(message: 'Erreur de connexion : ${e.toString()}'));
    }
  }

  Future<void> _onAuthSignupEvent(
    AuthSignupEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());

    try {
      final user = await _authRepository.signup(
        nom: event.nom,
        prenom: event.prenom,
        email: event.email,
        password: event.password,
        telephone: event.telephone,
        date: event.date,
        lieunaissance: event.lieunaissance,
        adress: event.adress,
        profil: event.profil,
      );
      emit(AuthAuthenticatedState(user: user, message: 'Inscription réussie'));
    } catch (e) {
      emit(AuthErrorState(message: 'Erreur d\'inscription : ${e.toString()}'));
    }
  }

  Future<void> _onAuthLogoutEvent(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    _sharedPreferencesService.removeValue(PointageConstants.AUTH_TOKEN);

    emit(AuthLoadingState());

    try {
      emit(AuthUnauthenticatedState());
    } catch (e) {
      emit(AuthErrorState(message: 'Erreur de déconnexion : ${e.toString()}'));
    }
  }

  Future<void> _onAuthForgotPasswordEvent(
    AuthForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoadingState());

    try {
      // 🔹 Implémentation future de la récupération de mot de passe
      emit(AuthForgotPasswordSentState(email: event.email));
    } catch (e) {
      emit(
        AuthErrorState(
          message:
              'Erreur lors de la récupération du mot de passe : ${e.toString()}',
        ),
      );
    }
  }
}
