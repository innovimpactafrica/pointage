import 'package:dio/dio.dart';

import 'SharedPreferencesService.dart';
import '../utils/constants.dart';

/// Service API unifié pour tous les profils (MANAGER, MOA, BET, OUVRIER)
/// Centralise la gestion des requêtes HTTP et de l'authentification
class ApiService {
  static final ApiService _instance = ApiService._internal();
  final SharedPreferencesService _sharedPreferencesService =
      SharedPreferencesService();

  late Dio dio;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: PointageConstants.BASE_URL,
        connectTimeout: Duration(seconds: 30),
        receiveTimeout: Duration(seconds: 60),
        headers: {
          "User-Agent": "curl/7.64.1",
          "Content-Type": "application/json",
          "Accept": "*/*",
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {

          if (_isProtectedApi(options)) {
            String? token = await _getToken();
            if (token != null) {
              // Try different authorization header formats
              options.headers['Authorization'] = 'Bearer $token';
              // Alternative formats that some servers might expect
              options.headers['X-Auth-Token'] = token;
              options.headers['X-API-Key'] = token;
            } else {
              print('⚠️ [ApiService] Aucun token trouvé pour ${options.uri}');
            }
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            '✅ Réponse reçue pour ${response.requestOptions.uri}: ${response.statusCode}',
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print(
            '❌ Erreur pour ${e.requestOptions.uri}: ${e.response?.statusCode} - ${e.message}',
          );
          return handler.next(e);
        },
      ),
    );
  }

  /// Détermine si une API nécessite une authentification
  bool _isProtectedApi(RequestOptions options) {
    // Liste des routes publiques (ne nécessitent pas d'authentification)
    const publicApis = [
      "/v1/auth/signin",
      "/v1/auth/signup",
      "/v1/auth/login",
      "/v1/auth/register",
      "/v1/auth/password/change",
    ];

    // Liste des routes protégées (nécessitent une authentification)
    const protectedApis = [
      // Authentification et utilisateurs
      "/v1/user/me",
      "/v1/user/by-profil",
      "/api/v1/user/by-profil",

      // APIs MANAGER/MOA
      "/budgets",
      "/expenses",
      "/materials",
      "/realestate",
      "/rapports",
      "/tasks",
      "/workers",
      "/orders",
      "/progress-album",
      "/indicators",
      "/documents",
      "/units",
      "/incidents",

      // APIs BET (Demandes d'études)
      "/study-requests",
      "/study-requests/property",
      "/study-requests/bet",
      "/study-requests/reports",
      "/study-requests/comments",
      "/study-requests/comment",
      "/bets",

      // APIs communes
      "/images",
      "/repertoire_chantier",
      "/comments",
    ];

    final uri = options.uri.toString();

    // Vérifier d'abord si c'est une route publique
    for (var api in publicApis) {
      if (uri.contains(api)) {
        return false; // Route publique, pas besoin de token
      }
    }

    // Vérifier les patterns spécifiques protégés
    for (var api in protectedApis) {
      if (uri.contains(api)) {
        return true;
      }
    }

    // Vérifier spécifiquement les endpoints workers avec ID
    if (RegExp(r'/workers/\d+').hasMatch(uri)) {
      return true;
    }

    // Vérifier les endpoints study-requests avec ID (ex: /study-requests/123)
    if (RegExp(r'/study-requests/\d+').hasMatch(uri) ||
        RegExp(r'study-requests/\d+').hasMatch(uri) ||
        RegExp(r'https://wakana\.online/api/study-requests/\d+').hasMatch(uri)) {
      return true;
    }

    // Par défaut, considérer comme non protégée (route publique)
    return false;
  }

  /// Récupère le token d'authentification depuis le stockage local
  Future<String?> _getToken() async {
    return await _sharedPreferencesService.getValue(
      PointageConstants.AUTH_TOKEN,
    );
  }

  /// Méthode publique pour récupérer le token (utile pour les services)
  Future<String?> getToken() async {
    return await _getToken();
  }

  /// Méthode publique pour vérifier si une URL est protégée (utile pour les services)
  bool isProtectedApi(String url) {
    final options = RequestOptions(path: url);
    return _isProtectedApi(options);
  }
}

