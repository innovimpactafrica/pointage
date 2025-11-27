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

  // Méthode pour sauvegarder le token et la date de dernière utilisation
  Future<void> saveToken(String token) async {
    await _sharedPreferencesService.saveValue(
      PointageConstants.AUTH_TOKEN,
      token,
    );
    // Sauvegarder la date de dernière utilisation (timestamp en millisecondes)
    final now = DateTime.now().millisecondsSinceEpoch;
    await _sharedPreferencesService.saveIntValue(
      PointageConstants.LAST_ACTIVITY_DATE,
      now,
    );
    print('🔑 Token sauvegardé: ${token.substring(0, 20)}...');
  }

  // Méthode pour mettre à jour la date de dernière utilisation
  Future<void> updateLastActivity() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _sharedPreferencesService.saveIntValue(
      PointageConstants.LAST_ACTIVITY_DATE,
      now,
    );
  }

  // Méthode pour vérifier si le token est toujours valide (moins de 20 jours)
  Future<bool> isTokenValid() async {
    try {
      // Vérifier si le token existe
      final token = await _sharedPreferencesService.getValue(
        PointageConstants.AUTH_TOKEN,
      );
      if (token == null) {
        return false;
      }

      // Vérifier la date de dernière utilisation
      final lastActivityTimestamp = await _sharedPreferencesService.getIntValue(
        PointageConstants.LAST_ACTIVITY_DATE,
      );
      if (lastActivityTimestamp == null) {
        return false;
      }

      final lastActivity = DateTime.fromMillisecondsSinceEpoch(
        lastActivityTimestamp,
      );
      final now = DateTime.now();
      final difference = now.difference(lastActivity);

      // Vérifier si moins de 20 jours se sont écoulés
      if (difference.inDays >= 20) {
        // Token expiré, supprimer le token et la date
        await _sharedPreferencesService.removeValue(
          PointageConstants.AUTH_TOKEN,
        );
        await _sharedPreferencesService.removeValue(
          PointageConstants.LAST_ACTIVITY_DATE,
        );
        return false;
      }

      // Vérifier si le token est valide en appelant l'API
      try {
        await connectedUser();
        return true;
      } catch (e) {
        // Token invalide, supprimer
        await _sharedPreferencesService.removeValue(
          PointageConstants.AUTH_TOKEN,
        );
        await _sharedPreferencesService.removeValue(
          PointageConstants.LAST_ACTIVITY_DATE,
        );
        return false;
      }
    } catch (e) {
      return false;
    }
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
      // Toujours supprimer le token et la date de dernière utilisation
      await _sharedPreferencesService.removeValue(PointageConstants.AUTH_TOKEN);
      // La date est stockée comme int, on peut utiliser removeValue aussi
      await _sharedPreferencesService.removeValue(
        PointageConstants.LAST_ACTIVITY_DATE,
      );
      print('🔑 Token et date de dernière utilisation supprimés');
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

  // Méthode pour obtenir l'ID utilisateur à partir de l'email et du mot de passe
  Future<int> getUserIdByEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Faire un login temporaire pour obtenir l'ID utilisateur
      final loginResponse = await signIn(email, password);

      if (loginResponse is Map<String, dynamic>) {
        // Sauvegarder temporairement le token
        if (loginResponse.containsKey("token")) {
          await saveToken(loginResponse["token"]);
        } else if (loginResponse.containsKey("accessToken")) {
          await saveToken(loginResponse["accessToken"]);
        }

        // Récupérer les informations utilisateur pour obtenir l'ID
        final userData = await connectedUser();
        if (userData is Map<String, dynamic> && userData.containsKey('id')) {
          return userData['id'] as int;
        }
      }

      throw Exception("Impossible de récupérer l'ID utilisateur");
    } catch (e) {
      throw Exception("Email ou mot de passe incorrect");
    }
  }

  // Méthode pour changer le mot de passe (sans token initial)
  Future<dynamic> changePassword({
    required String email,
    required String password,
    required String newPassword,
  }) async {
    try {
      // Obtenir l'ID utilisateur via un login temporaire
      final userId = await getUserIdByEmailAndPassword(
        email: email,
        password: password,
      );

      // Maintenant changer le mot de passe avec l'ID obtenu
      Response response = await _dio.put(
        "/v1/auth/password/change/$userId",
        data: {
          "email": email,
          "password": password,
          "newPassword": newPassword,
        },
      );

      return response.data;
    } on DioException catch (e) {
      _handleError(e, "Échec de la modification du mot de passe");
    } catch (e) {
      throw Exception(
        "Erreur inattendue lors de la modification du mot de passe",
      );
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
