import 'package:equatable/equatable.dart';
import '../../models/UserModel.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthAuthenticatedState extends AuthState {
  final UserModel user;
  final String message;

  const AuthAuthenticatedState({required this.user, required this.message});

  @override
  List<Object?> get props => [user, message];
}

class AuthUnauthenticatedState extends AuthState {}

class AuthErrorState extends AuthState {
  final String message;

  const AuthErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthForgotPasswordSentState extends AuthState {
  final String email;

  const AuthForgotPasswordSentState({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthPasswordChangedState extends AuthState {
  final String message;

  const AuthPasswordChangedState({required this.message});

  @override
  List<Object?> get props => [message];
}
