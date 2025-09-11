import '../services/worker_service.dart';
import '../models/worker_dashboard_model.dart';

class WorkerDashboardRepository {
  final WorkerService workerService;
  WorkerDashboardRepository({required this.workerService});

  Future<WorkerDashboardModel> getDashboard(int workerId) {
    return workerService.fetchWorkerDashboard(workerId);
  }
}
