import 'package:geolocator/geolocator.dart';
import '../models/PointageModel.dart';
import 'api_service.dart';

/// Service de gestion du pointage pour les ouvriers
class PointageService {
  static final PointageService _instance = PointageService._internal();
  final ApiService _apiService = ApiService();

  factory PointageService() {
    return _instance;
  }

  PointageService._internal();

  /// Enregistrer un pointage (arrivée ou départ)
  Future<Map<String, dynamic>> enregistrerPointage({
    required int userId,
    required String typePointage, // 'ARRIVEE' ou 'DEPART'
    String? commentaire,
    double? latitude,
    double? longitude,
    String? adresse,
    String? qrCodeText, // Nouveau paramètre pour le QR code
  }) async {
    try {
      print(
        '⏰ [PointageService] Enregistrement pointage: $typePointage pour user $userId',
      );

      // Construire les paramètres de requête
      final queryParams = <String, dynamic>{};

      // Ajouter le QR code si fourni
      if (qrCodeText != null && qrCodeText.isNotEmpty) {
        queryParams['qrCodeText'] = qrCodeText;
      }

      // Ajouter les coordonnées GPS si fournies
      if (latitude != null) {
        queryParams['latitude'] = latitude.toString();
      }
      if (longitude != null) {
        queryParams['longitude'] = longitude.toString();
      }

      // Utiliser le nouvel endpoint /check
      final endpoint = '/workers/$userId/check';

      print('🔍 [PointageService] Endpoint: $endpoint');
      print('🔍 [PointageService] Query params: $queryParams');

      final response = await _apiService.dio.post(
        endpoint,
        queryParameters: queryParams,
        data: '', // Body vide comme dans l'exemple curl
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [PointageService] Pointage enregistré avec succès');
        return {
          'success': true,
          'message': 'Check-in enregistré avec succès',
          'data': response.data,
        };
      } else {
        print(
          '❌ [PointageService] Erreur lors de l\'enregistrement: ${response.statusCode}',
        );
        return {'success': false, 'message': 'Erreur lors du pointage'};
      }
    } catch (e) {
      print('❌ [PointageService] Exception lors de l\'enregistrement: $e');
      return {'success': false, 'message': 'Erreur lors du pointage'};
    }
  }

  /// Récupérer l'historique de pointage d'un utilisateur
  Future<List<PointageModel>> getHistoriquePointage({
    required int userId,
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    try {
      print('📊 [PointageService] Récupération historique pour user $userId');

      final response = await _apiService.dio.get(
        '/workers/$userId/presence-history',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final List<dynamic> logs = data['logs'] ?? [];

        final List<PointageModel> pointages =
            logs.map((log) {
              return PointageModel.fromPresenceHistory(
                Map<String, dynamic>.from(log),
                userId,
              );
            }).toList();

        print('✅ [PointageService] ${pointages.length} pointages récupérés');
        print(
          '⏱️ [PointageService] Temps total travaillé: ${data['totalWorkedTime']}',
        );
        return pointages;
      } else {
        print(
          '❌ [PointageService] Erreur lors de la récupération: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      print('❌ [PointageService] Exception lors de la récupération: $e');
      return [];
    }
  }

  /// Récupérer le pointage du jour pour un utilisateur
  Future<PointageModel?> getPointageDuJour(int userId) async {
    try {
      print(
        '📅 [PointageService] Récupération pointage du jour pour user $userId',
      );

      final response = await _apiService.dio.get(
        '/workers/$userId/presence-history',
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data;
        final List<dynamic> logs = data['logs'] ?? [];

        // Filtrer les logs d'aujourd'hui
        final today = DateTime.now();
        final todayLogs =
            logs.where((log) {
              if (log['checkInTime'] != null &&
                  (log['checkInTime'] as List).isNotEmpty) {
                final checkInList = List<int>.from(log['checkInTime']);
                if (checkInList.length >= 3) {
                  final checkInDate = DateTime(
                    today.year,
                    today.month,
                    today.day,
                    checkInList[0],
                    checkInList[1],
                    checkInList[2],
                  );
                  return checkInDate.year == today.year &&
                      checkInDate.month == today.month &&
                      checkInDate.day == today.day;
                }
              }
              return false;
            }).toList();

        if (todayLogs.isNotEmpty) {
          return PointageModel.fromPresenceHistory(
            Map<String, dynamic>.from(todayLogs.first),
            userId,
          );
        }
      }

      print('ℹ️ [PointageService] Aucun pointage trouvé pour aujourd\'hui');
      return null;
    } catch (e) {
      print(
        '❌ [PointageService] Exception lors de la récupération du pointage du jour: $e',
      );
      return null;
    }
  }

  /// Obtenir la position GPS actuelle
  Future<Position?> getCurrentLocation() async {
    try {
      print('📍 [PointageService] Récupération de la position GPS');

      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ [PointageService] Permission de localisation refusée');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print(
          '❌ [PointageService] Permission de localisation définitivement refusée',
        );
        return null;
      }

      // Obtenir la position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      print(
        '✅ [PointageService] Position récupérée: ${position.latitude}, ${position.longitude}',
      );
      return position;
    } catch (e) {
      print(
        '❌ [PointageService] Erreur lors de la récupération de la position: $e',
      );
      return null;
    }
  }

  /// Obtenir l'adresse à partir des coordonnées GPS
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      print(
        '🏠 [PointageService] Récupération de l\'adresse pour $latitude, $longitude',
      );

      // Utiliser un service de géocodage inverse
      // Pour l'instant, retourner une adresse générique
      return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
    } catch (e) {
      print(
        '❌ [PointageService] Erreur lors de la récupération de l\'adresse: $e',
      );
      return null;
    }
  }

  /// Vérifier si l'utilisateur peut pointer (arrivée)
  Future<bool> peutPointerArrivee(int userId) async {
    try {
      final pointageDuJour = await getPointageDuJour(userId);
      if (pointageDuJour == null) {
        return true; // Aucun pointage aujourd'hui, peut pointer l'arrivée
      }

      // Si déjà pointé l'arrivée mais pas le départ, ne peut pas pointer l'arrivée
      return pointageDuJour.heureArrivee == null;
    } catch (e) {
      print('❌ [PointageService] Erreur lors de la vérification: $e');
      return false;
    }
  }

  /// Vérifier si l'utilisateur peut pointer (départ)
  Future<bool> peutPointerDepart(int userId) async {
    try {
      final pointageDuJour = await getPointageDuJour(userId);
      if (pointageDuJour == null) {
        return false; // Aucun pointage aujourd'hui, ne peut pas pointer le départ
      }

      // Si déjà pointé l'arrivée mais pas le départ, peut pointer le départ
      return pointageDuJour.heureArrivee != null &&
          pointageDuJour.heureDepart == null;
    } catch (e) {
      print('❌ [PointageService] Erreur lors de la vérification: $e');
      return false;
    }
  }

  /// Récupérer le statut de pointage du jour
  Future<Map<String, dynamic>> getStatutPointageDuJour(int userId) async {
    try {
      final pointageDuJour = await getPointageDuJour(userId);

      if (pointageDuJour == null) {
        return {
          'peutArrivee': true,
          'peutDepart': false,
          'statut': 'Aucun pointage',
          'heureArrivee': null,
          'heureDepart': null,
        };
      }

      final peutArrivee = pointageDuJour.heureArrivee == null;
      final peutDepart =
          pointageDuJour.heureArrivee != null &&
          pointageDuJour.heureDepart == null;

      String statut = 'Aucun pointage';
      if (pointageDuJour.heureArrivee != null &&
          pointageDuJour.heureDepart != null) {
        statut = 'Journée complète';
      } else if (pointageDuJour.heureArrivee != null) {
        statut = 'Arrivée enregistrée';
      }

      return {
        'peutArrivee': peutArrivee,
        'peutDepart': peutDepart,
        'statut': statut,
        'heureArrivee': pointageDuJour.heureArrivee,
        'heureDepart': pointageDuJour.heureDepart,
      };
    } catch (e) {
      print('❌ [PointageService] Erreur lors de la récupération du statut: $e');
      return {
        'peutArrivee': false,
        'peutDepart': false,
        'statut': 'Erreur',
        'heureArrivee': null,
        'heureDepart': null,
      };
    }
  }

  /// Alias pour getHistoriquePointage
  Future<List<PointageModel>> getHistoriquePointages({
    required int userId,
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    return await getHistoriquePointage(
      userId: userId,
      dateDebut: dateDebut,
      dateFin: dateFin,
    );
  }

  /// Récupérer le pointage du jour pour un utilisateur
  Future<List<Map<String, dynamic>>?> getTodayPointage(int userId) async {
    try {
      print(
        '📅 [PointageService] Récupération pointage du jour pour user $userId',
      );

      final response = await _apiService.dio.get(
        '/workers/$userId/presence-history',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data;
        final List<dynamic> logs = data['logs'] ?? [];

        // Filtrer les logs d'aujourd'hui
        final today = DateTime.now();
        final todayLogs =
            logs.where((log) {
              if (log['checkInTime'] != null &&
                  (log['checkInTime'] as List).isNotEmpty) {
                final checkInList = List<int>.from(log['checkInTime']);
                if (checkInList.length >= 3) {
                  final checkInDate = DateTime(
                    today.year,
                    today.month,
                    today.day,
                    checkInList[0],
                    checkInList[1],
                    checkInList[2],
                  );
                  return checkInDate.year == today.year &&
                      checkInDate.month == today.month &&
                      checkInDate.day == today.day;
                }
              }
              return false;
            }).toList();

        if (todayLogs.isNotEmpty) {
          return List<Map<String, dynamic>>.from(todayLogs);
        }
      }

      return null;
    } catch (e) {
      print(
        '❌ [PointageService] Exception lors de la récupération du pointage du jour: $e',
      );
      return null;
    }
  }

  /// Effectuer un pointage (alias pour enregistrerPointage)
  Future<Map<String, dynamic>> pointer(
    int userId,
    String typePointage, {
    String? qrCodeText,
    double? latitude,
    double? longitude,
  }) async {
    return await enregistrerPointage(
      userId: userId,
      typePointage: typePointage,
      qrCodeText: qrCodeText,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
