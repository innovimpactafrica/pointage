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
          // DEBUG: Afficher tous les headers envoyés
          print('[DEBUG] Headers envoyés: \n${options.headers}');
          print('🔍 [ApiService] URL de la requête: ${options.uri}');
          print('🔍 [ApiService] Méthode: ${options.method}');

          if (_isProtectedApi(options)) {
            String? token = await _getToken();
            if (token != null) {
              // Try different authorization header formats
              options.headers['Authorization'] = 'Bearer $token';
              // Alternative formats that some servers might expect
              options.headers['X-Auth-Token'] = token;
              options.headers['X-API-Key'] = token;

              print(
                '🔐 Token ajouté pour ${options.uri}: ${token.substring(0, 20)}...',
              );
            } else {
              print('⚠️ Aucun token trouvé pour ${options.uri}');
            }
          } else {
            print('🔓 API non protégée: ${options.uri}');
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
      "/study-requests/6",
      "/study-requests/7",
      "/study-requests/8",
      "/study-requests/9",
      "/study-requests/10",
      "/bets",

      // APIs communes
      "/images",
      "/repertoire_chantier",
      "/comments",
    ];

    final uri = options.uri.toString();

    // Vérifier les patterns spécifiques
    for (var api in protectedApis) {
      if (uri.contains(api)) {
        print('✅ [ApiService] API protégée détectée: $api dans $uri');
        return true;
      }
    }

    // Vérifier spécifiquement les endpoints workers
    if (RegExp(r'/workers/\d+').hasMatch(uri)) {
      print('✅ [ApiService] API protégée détectée: /workers/{id} dans $uri');
      return true;
    }

    // Debug spécifique pour study-requests
    if (uri.contains('study-requests')) {
      print('🔍 [ApiService] URL contient "study-requests": $uri');
      print('🔍 [ApiService] Vérification des patterns study-requests:');
      for (var api in protectedApis) {
        if (api.contains('study-requests')) {
          print('  - $api: ${uri.contains(api)}');
        }
      }
    }

    // Vérifier les endpoints avec des IDs (ex: /study-requests/123)
    // Utiliser une regex plus flexible pour capturer les URLs complètes
    if (RegExp(r'/study-requests/\d+').hasMatch(uri)) {
      print(
        '✅ [ApiService] API protégée détectée: /study-requests/{id} dans $uri',
      );
      return true;
    }

    // Vérifier aussi les URLs complètes avec le domaine
    if (RegExp(r'study-requests/\d+').hasMatch(uri)) {
      print(
        '✅ [ApiService] API protégée détectée: study-requests/{id} dans $uri',
      );
      return true;
    }

    // Vérifier les URLs complètes avec le domaine complet
    if (RegExp(
      r'https://wakana\.online/api/study-requests/\d+',
    ).hasMatch(uri)) {
      print(
        '✅ [ApiService] API protégée détectée: URL complète study-requests/{id} dans $uri',
      );
      return true;
    }

    // Debug: Afficher tous les patterns testés
    print('🔍 [ApiService] Patterns testés pour $uri:');
    for (var api in protectedApis) {
      print('  - $api: ${uri.contains(api)}');
    }
    print(
      '  - /study-requests/\\d+: ${RegExp(r'/study-requests/\d+').hasMatch(uri)}',
    );
    print(
      '  - study-requests/\\d+: ${RegExp(r'study-requests/\d+').hasMatch(uri)}',
    );
    print(
      '  - https://wakana.online/api/study-requests/\\d+: ${RegExp(r'https://wakana\.online/api/study-requests/\d+').hasMatch(uri)}',
    );

    print('❌ [ApiService] API non protégée: $uri');
    return false;
  }

  /// Récupère le token d'authentification depuis le stockage local
  Future<String?> _getToken() async {
    String? token = await _sharedPreferencesService.getValue(
      PointageConstants.AUTH_TOKEN,
    );
    if (token != null) {
      print('🔑 Token récupéré: ${token.substring(0, 20)}...');
      print('🔑 Token complet: $token');
    } else {
      print('🔑 Aucun token trouvé dans le stockage');
      print('🔑 Clé utilisée: ${PointageConstants.AUTH_TOKEN}');
    }
    return token;
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
