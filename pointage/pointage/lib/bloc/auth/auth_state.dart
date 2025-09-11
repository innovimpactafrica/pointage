import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthSignupEvent extends AuthEvent {
  final String nom;
  final String prenom;
  final String email;
  final String password;
  final String telephone;
  final String? date;
  final String? lieunaissance;
  final String? adress;
  final String profil;

  const AuthSignupEvent({
    required this.nom,
    required this.prenom,
    required this.email,
    required this.password,
    required this.telephone,
    this.date,
    this.lieunaissance,
    this.adress,
    this.profil = "WORKER",
  });

  @override
  List<Object> get props => [
    nom,
    prenom,
    email,
    password,
    telephone,
    date ?? '',
    lieunaissance ?? '',
    adress ?? '',
    profil,
  ];
}
