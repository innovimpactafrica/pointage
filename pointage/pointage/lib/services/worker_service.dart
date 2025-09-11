import 'package:pointage/services/api_service.dart';

import '../models/worker_dashboard_model.dart';
import '../models/MonthlySummaryModel.dart';
import '../models/PresenceHistoryModel.dart';
// import 'location_service.dart'; // Non utilisé pour l'instant

class WorkerService {
  final ApiService _apiService = ApiService();
  // final LocationService _locationService = LocationService(); // Non utilisé pour l'instant

  Future<WorkerDashboardModel> fetchWorkerDashboard(int workerId) async {
    try {
      // Appel au premier endpoint pour daysPresent et totalWorkedHours
      final responsePresence = await _apiService.dio.get(
        '/workers/$workerId/mobile/dashboard',
      );
      print('[DEBUG] Réponse présence worker:');
      print(responsePresence.data);

      // Appel au second endpoint pour les tâches
      final responseTasks = await _apiService.dio.get(
        '/tasks/dashboard/mobile/$workerId',
      );
      print('[DEBUG] Réponse tâches worker:');
      print(responseTasks.data);

      // Fusion des deux réponses dans le modèle
      return WorkerDashboardModel(
        daysPresent: responsePresence.data['daysPresent'] ?? 0,
        totalWorkedHours: responsePresence.data['totalWorkedHours'] ?? 0,
        totalTasks: responseTasks.data['totalTasks'] ?? 0,
        completedTasks: responseTasks.data['completedTasks'] ?? 0,
        performancePercentage:
            (responseTasks.data['performancePercentage'] is int)
                ? responseTasks.data['performancePercentage']
                : (responseTasks.data['performancePercentage'] ?? 0)
                    .toDouble()
                    .toInt(),
      );
    } catch (e, stack) {
      print('[ERROR] Erreur lors du chargement du dashboard worker: $e');
      print(stack);
      rethrow;
    }
  }

  Future<MonthlySummaryModel> fetchMonthlySummary(int workerId) async {
    final response = await _apiService.dio.get(
      '/workers/$workerId/monthly-summary',
    );
    return MonthlySummaryModel.fromJson(response.data);
  }

  Future<PresenceHistoryModel> fetchPresenceHistory(int workerId) async {
    final response = await _apiService.dio.get(
      '/workers/$workerId/presence-history',
    );
    return PresenceHistoryModel.fromJson(response.data);
  }

  Future<String> checkInOut(
    int workerId, {
    String? qrCodeText,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Construire l'URL avec les paramètres
      String url = '/workers/$workerId/check';
      Map<String, dynamic> queryParameters = {};

      if (latitude != null && longitude != null) {
        queryParameters['latitude'] = latitude.toString();
        queryParameters['longitude'] = longitude.toString();
      }

      // Ajouter le QR code si fourni
      if (qrCodeText != null && qrCodeText.isNotEmpty) {
        queryParameters['qrCodeText'] = qrCodeText;
      }

      final response = await _apiService.dio.post(
        url,
        queryParameters: queryParameters,
      );

      // Supposons que la réponse contient un message avec l'heure
      final message = response.data.toString();
      final regex = RegExp(r'(\d{2}:\d{2}:\d{2})');
      final match = regex.firstMatch(message);
      return match != null ? match.group(0)! : '';
    } catch (e) {
      print('[ERROR] Erreur lors du pointage: $e');
      rethrow;
    }
  }
}
