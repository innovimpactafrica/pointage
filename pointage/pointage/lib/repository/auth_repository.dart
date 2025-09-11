// ignore_for_file: unused_element

import 'package:shared_preferences/shared_preferences.dart';

import 'package:pointage/models/UserModel.dart';
import 'package:pointage/services/AuthService.dart';

class AuthRepository {
  final AuthService _authService = AuthService();

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _authService.signIn(email, password);
      print('Response from API: $response'); // Debug log
      return _handleLoginResponse(response);
    } catch (e) {
      print('Login error: $e'); // Debug log
      // Correction de la faute de frappe et amélioration du message d'erreur
      if (e.toString().contains('Données invalides')) {
        throw Exception("Email ou mot de passe incorrect");
      } else if (e.toString().contains('connexion internet')) {
        throw Exception("Vérifiez votre connexion internet");
      } else if (e.toString().contains('Non autorisé')) {
        throw Exception("Email ou mot de passe incorrect");
      } else {
        throw Exception("Erreur de connexion : ${e.toString()}");
      }
    }
  }

  Future<UserModel> signup({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    required String telephone,
    String? date,
    String? lieunaissance,
    String? adress,
    String profil = "WORKER",
  }) async {
    try {
      final response = await _authService.signUp(
        nom: nom,
        prenom: prenom,
        email: email,
        password: password,
        telephone: telephone,
        date: date,
        lieunaissance: lieunaissance,
        adress: adress,
        profil: profil,
      );
      return _handleResponse(response);
    } catch (e) {
      print('Signup error: $e'); // Debug log
      throw Exception("Erreur d'inscription : ${e.toString()}");
    }
  }

  Future<UserModel> _handleLoginResponse(Map<String, dynamic> response) async {
    try {
      print('Handling login response: $response'); // Debug log

      if (response.containsKey("token")) {
        // Sauvegarder le token via AuthService
        await _authService.saveToken(response["token"]);

        // Attendre un peu pour que le token soit propagé
        await Future.delayed(Duration(milliseconds: 100));

        // Récupérer les informations utilisateur
        final userMap = await _authService.connectedUser();
        print('User data: $userMap'); // Debug log

        return UserModel.fromJson(userMap);
      } else if (response.containsKey("accessToken")) {
        // Au cas où l'API utilise "accessToken" au lieu de "token"
        await _authService.saveToken(response["accessToken"]);

        // Attendre un peu pour que le token soit propagé
        await Future.delayed(Duration(milliseconds: 100));

        final userMap = await _authService.connectedUser();
        return UserModel.fromJson(userMap);
      } else {
        print('Invalid response structure: $response'); // Debug log
        throw Exception("Réponse invalide du serveur");
      }
    } catch (e) {
      print('Error handling login response: $e'); // Debug log
      throw Exception(
        "Erreur lors du traitement de la réponse : ${e.toString()}",
      );
    }
  }

  Future<UserModel> currentUser() async {
    try {
      final userMap = await _authService.connectedUser();
      return UserModel.fromJson(userMap);
    } catch (e) {
      throw Exception("Impossible de récupérer les informations utilisateur");
    }
  }

  UserModel _handleResponse(Map<String, dynamic> response) {
    try {
      if (response['success'] == true && response.containsKey('data')) {
        return UserModel.fromJson(response['data']);
      } else if (response.containsKey('user')) {
        // Au cas où la structure serait différente
        return UserModel.fromJson(response['user']);
      } else {
        throw Exception(response['message'] ?? "Une erreur est survenue");
      }
    } catch (e) {
      print('Error handling response: $e'); // Debug log
      throw Exception("Erreur lors du traitement des données");
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }
}
