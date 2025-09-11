// ignore_for_file: file_names

import 'package:dio/dio.dart';
import 'package:pointage/services/api_service.dart';
import 'package:pointage/services/SharedPreferencesService.dart';
import 'package:pointage/utils/constants.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();
  Dio get _dio => _apiService.dio;

  // Méthode existante de connexion
  Future<dynamic> signIn(String email, String password) async {
    try {
      Response response = await _dio.post(
        "/v1/auth/signin", // Ajout du "/" au début
        data: {"email": email, "password": password},
      );

      return response.data;
    } on DioException catch (e) {
      _handleError(e, "Échec de la connexion");
    } catch (e) {
      throw Exception("Erreur inattendue lors de la connexion");
    }
  }

  // Méthode pour l'inscription complète
  Future<dynamic> signUp({
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
      Response response = await _dio.post(
        "/v1/auth/signup",
        data: {
          "nom": nom,
          "prenom": prenom,
          "email": email,
          "password": password,
          "telephone": telephone,
          "date": date,
          "lieunaissance": lieunaissance,
          "adress": adress,
          "profil": profil,
        },
      );

      return response.data;
    } on DioException catch (e) {
      _handleError(e, "Échec de la création de compte");
    }
  }

  // Méthode pour sauvegarder le token
  Future<void> saveToken(String token) async {
    await _sharedPreferencesService.saveValue(
      PointageConstants.AUTH_TOKEN,
      token,
    );
    print('🔑 Token sauvegardé: ${token.substring(0, 20)}...');
  }

  // Méthode existante pour récupérer l'utilisateur connecté
  Future<dynamic> connectedUser() async {
    try {
      // Vérifier si le token existe
      String? token = await _sharedPreferencesService.getValue(
        PointageConstants.AUTH_TOKEN,
      );
      if (token == null) {
        throw Exception("Aucun token d'authentification trouvé");
      }

      print('🔑 Token utilisé pour /v1/user/me: ${token.substring(0, 20)}...');

      Response response = await _dio.get("/v1/user/me");

      return response.data;
    } on DioException catch (e) {
      _handleError(e, "Impossible de récupérer les informations utilisateur");
    }
  }

  // Méthode de déconnexion
  Future<void> logout() async {
    try {
      // Appel API de déconnexion (optionnel)
      await _dio.post("/v1/auth/logout");
    } catch (e) {
      // Même en cas d'erreur, on considère la déconnexion comme réussie
      print('Erreur lors de la déconnexion API: $e');
    } finally {
      // Toujours supprimer le token du stockage local
      await _sharedPreferencesService.removeValue(PointageConstants.AUTH_TOKEN);
      print('🔑 Token supprimé du stockage local');
    }
  }

  // Méthode login avec paramètres nommés (pour compatibilité avec les pages)
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await signIn(email, password);

      // Sauvegarder le token si présent dans la réponse
      if (response is Map<String, dynamic>) {
        if (response.containsKey("token")) {
          await saveToken(response["token"]);
        } else if (response.containsKey("accessToken")) {
          await saveToken(response["accessToken"]);
        }
      }

      // Retourner un format compatible avec les pages
      return {
        'success': true,
        'message': 'Connexion réussie',
        'data': response,
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Méthode register avec paramètres nommés (pour compatibilité avec les pages)
  Future<Map<String, dynamic>> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    String? telephone,
    String? matricule,
    String? poste,
    String? departement,
    String? date,
    String? lieunaissance,
    String? adress,
  }) async {
    try {
      final response = await signUp(
        nom: nom,
        prenom: prenom,
        email: email,
        password: password,
        telephone: telephone ?? '',
        date: date,
        lieunaissance: lieunaissance,
        adress: adress,
        profil: "WORKER",
      );

      // Retourner un format compatible avec les pages
      return {
        'success': true,
        'message': 'Inscription réussie',
        'data': response,
      };
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Méthode privée de gestion des erreurs améliorée
  dynamic _handleError(DioException e, String defaultMessage) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final responseData = e.response!.data;

      // Vérifier si le serveur a renvoyé un message d'erreur spécifique
      String errorMessage = defaultMessage;
      if (responseData is Map<String, dynamic>) {
        errorMessage =
            responseData['message'] ??
            responseData['error'] ??
            responseData['detail'] ??
            defaultMessage;
      }

      switch (statusCode) {
        case 400:
          throw Exception("Données invalides: $errorMessage");
        case 401:
          throw Exception("Email ou mot de passe incorrect");
        case 403:
          throw Exception("Accès refusé");
        case 404:
          throw Exception("Service non trouvé");
        case 409:
          throw Exception("Un compte avec cet email existe déjà");
        case 422:
          throw Exception("Données invalides: $errorMessage");
        case 500:
          throw Exception("Erreur serveur temporaire");
        case 502:
        case 503:
        case 504:
          throw Exception("Service temporairement indisponible");
        default:
          throw Exception("$defaultMessage (Code: $statusCode)");
      }
    } else {
      // Erreurs de connexion (pas de réponse du serveur)
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          throw Exception(
            "Délai de connexion dépassé. Vérifiez votre connexion internet.",
          );
        case DioExceptionType.sendTimeout:
          throw Exception(
            "Délai d'envoi dépassé. Vérifiez votre connexion internet.",
          );
        case DioExceptionType.receiveTimeout:
          throw Exception(
            "Délai de réception dépassé. Vérifiez votre connexion internet.",
          );
        case DioExceptionType.connectionError:
          throw Exception(
            "Impossible de se connecter au serveur. Vérifiez votre connexion internet.",
          );
        case DioExceptionType.unknown:
          throw Exception(
            "Erreur de connexion inconnue. Vérifiez votre connexion internet.",
          );
        default:
          throw Exception(
            "$defaultMessage. Vérifiez votre connexion internet.",
          );
      }
    }
  }
}
