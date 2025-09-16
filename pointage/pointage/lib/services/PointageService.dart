import 'package:geolocator/geolocator.dart';
import '../models/PointageModel.dart';
import '../utils/constants.dart';
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
      print('🚀 [PointageService] ===== DÉBUT ENREGISTREMENT POINTAGE =====');
      print('⏰ [PointageService] Type de pointage: $typePointage');
      print('👤 [PointageService] User ID: $userId');
      print('📱 [PointageService] QR Code: $qrCodeText');
      print('📍 [PointageService] Latitude: $latitude');
      print('📍 [PointageService] Longitude: $longitude');
      print('💬 [PointageService] Commentaire: $commentaire');

      // Construire les paramètres de requête
      final queryParams = <String, dynamic>{};

      // Ajouter le QR code si fourni
      if (qrCodeText != null && qrCodeText.isNotEmpty) {
        queryParams['qrCodeText'] = qrCodeText;
        print('✅ [PointageService] QR Code ajouté aux paramètres');
      } else {
        print('⚠️ [PointageService] Aucun QR Code fourni');
      }

      // Ajouter les coordonnées GPS si fournies
      if (latitude != null) {
        queryParams['latitude'] = latitude.toString();
        print('✅ [PointageService] Latitude ajoutée: $latitude');
      } else {
        print('⚠️ [PointageService] Aucune latitude fournie');
      }

      if (longitude != null) {
        queryParams['longitude'] = longitude.toString();
        print('✅ [PointageService] Longitude ajoutée: $longitude');
      } else {
        print('⚠️ [PointageService] Aucune longitude fournie');
      }

      // Utiliser le nouvel endpoint /check
      final endpoint = '/workers/$userId/check';
      final fullUrl = '${PointageConstants.BASE_URL}$endpoint';

      print('🌐 [PointageService] URL complète: $fullUrl');
      print('🔍 [PointageService] Endpoint: $endpoint');
      print('📋 [PointageService] Paramètres de requête: $queryParams');
      print('📤 [PointageService] Envoi de la requête POST...');

      final response = await _apiService.dio.post(
        endpoint,
        queryParameters: queryParams,
        data: '', // Body vide comme dans l'exemple curl
      );

      print('📥 [PointageService] Réponse reçue:');
      print('   📊 Status Code: ${response.statusCode}');
      print('   📝 Headers: ${response.headers}');
      print('   📄 Data: ${response.data}');
      print('   🔗 Real URL: ${response.realUri}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [PointageService] Pointage enregistré avec succès');
        print(
          '🏁 [PointageService] ===== FIN ENREGISTREMENT POINTAGE (SUCCÈS) =====',
        );
        return {
          'success': true,
          'message': 'Check-in enregistré avec succès',
          'data': response.data,
        };
      } else {
        print(
          '❌ [PointageService] Erreur lors de l\'enregistrement: ${response.statusCode}',
        );
        print(
          '🏁 [PointageService] ===== FIN ENREGISTREMENT POINTAGE (ÉCHEC) =====',
        );
        return {'success': false, 'message': 'Erreur lors du pointage'};
      }
    } catch (e) {
      print('💥 [PointageService] EXCEPTION lors de l\'enregistrement: $e');
      print('💥 [PointageService] Type d\'erreur: ${e.runtimeType}');
      if (e.toString().contains('SocketException')) {
        print('🌐 [PointageService] Problème de connexion réseau');
      } else if (e.toString().contains('TimeoutException')) {
        print('⏰ [PointageService] Timeout de la requête');
      } else if (e.toString().contains('FormatException')) {
        print('📝 [PointageService] Erreur de format de données');
      }
      print(
        '🏁 [PointageService] ===== FIN ENREGISTREMENT POINTAGE (EXCEPTION) =====',
      );
      return {
        'success': false,
        'message': 'Erreur lors du pointage: ${e.toString()}',
      };
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

  /// Récupérer le pointage du jour pour un utilisateur (premier seulement - pour compatibilité)
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

  /// Récupérer TOUS les pointages du jour pour un utilisateur
  Future<List<PointageModel>> getTousPointagesDuJour(int userId) async {
    try {
      print(
        '📅 [PointageService] Récupération TOUS les pointages du jour pour user $userId',
      );

      final response = await _apiService.dio.get(
        '/workers/$userId/presence-history',
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data;
        final List<dynamic> logs = data['logs'] ?? [];

        print('📊 [PointageService] Total logs reçus: ${logs.length}');

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

        print(
          '📅 [PointageService] Logs d\'aujourd\'hui trouvés: ${todayLogs.length}',
        );

        if (todayLogs.isNotEmpty) {
          final List<PointageModel> pointages =
              todayLogs.map((log) {
                return PointageModel.fromPresenceHistory(
                  Map<String, dynamic>.from(log),
                  userId,
                );
              }).toList();

          print(
            '✅ [PointageService] ${pointages.length} pointages d\'aujourd\'hui récupérés',
          );
          return pointages;
        }
      }

      print('ℹ️ [PointageService] Aucun pointage trouvé pour aujourd\'hui');
      return [];
    } catch (e) {
      print(
        '❌ [PointageService] Exception lors de la récupération des pointages du jour: $e',
      );
      return [];
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

  /// Récupérer les adresses de pointage pour un projet
  Future<List<Map<String, dynamic>>> getAdressesPointage(int projectId) async {
    try {
      print(
        '🏢 [PointageService] Récupération des adresses pour le projet $projectId',
      );

      final response = await _apiService.dio.get(
        '/pointing-addresses/property/$projectId',
      );

      if (response.statusCode == 200) {
        final List<dynamic> adresses = response.data;
        final List<Map<String, dynamic>> adressesList =
            adresses.map((adresse) {
              return Map<String, dynamic>.from(adresse);
            }).toList();

        print('✅ [PointageService] ${adressesList.length} adresses récupérées');
        return adressesList;
      } else {
        print(
          '❌ [PointageService] Erreur lors de la récupération des adresses: ${response.statusCode}',
        );
        return [];
      }
    } catch (e) {
      print(
        '❌ [PointageService] Exception lors de la récupération des adresses: $e',
      );
      return [];
    }
  }

  /// Créer une nouvelle adresse de pointage
  Future<Map<String, dynamic>> creerAdressePointage({
    required double latitude,
    required double longitude,
    required String name,
    required String qrcode,
  }) async {
    try {
      print('🏗️ [PointageService] Création d\'une nouvelle adresse...');
      print('   📍 Latitude: $latitude');
      print('   📍 Longitude: $longitude');
      print('   📝 Nom: $name');
      print('   📱 QR Code: $qrcode');

      final response = await _apiService.dio.post(
        '/pointing-addresses',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'name': name,
          'qrcode': qrcode,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> nouvelleAdresse = Map<String, dynamic>.from(
          response.data,
        );
        print(
          '✅ [PointageService] Adresse créée avec succès: ID ${nouvelleAdresse['id']}',
        );
        return {
          'success': true,
          'message': 'Adresse créée avec succès',
          'data': nouvelleAdresse,
        };
      } else {
        print(
          '❌ [PointageService] Erreur lors de la création: ${response.statusCode}',
        );
        return {
          'success': false,
          'message': 'Erreur lors de la création de l\'adresse',
        };
      }
    } catch (e) {
      print('❌ [PointageService] Exception lors de la création: $e');
      return {
        'success': false,
        'message': 'Erreur lors de la création de l\'adresse: ${e.toString()}',
      };
    }
  }
}
