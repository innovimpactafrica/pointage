import 'package:flutter_bloc/flutter_bloc.dart';
import 'worker_dashboard_event.dart';
import 'worker_dashboard_state.dart';
import '../../repository/worker_dashboard_repository.dart';

class WorkerDashboardBloc
    extends Bloc<WorkerDashboardEvent, WorkerDashboardState> {
  final WorkerDashboardRepository repository;
  WorkerDashboardBloc({required this.repository})
    : super(WorkerDashboardLoading()) {
    on<LoadWorkerDashboardEvent>(_onLoadDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadWorkerDashboardEvent event,
    Emitter<WorkerDashboardState> emit,
  ) async {
    emit(WorkerDashboardLoading());
    try {
      final dashboard = await repository.getDashboard(event.workerId);
      emit(WorkerDashboardLoaded(dashboard));
    } catch (e) {
      emit(WorkerDashboardError('Erreur lors du chargement du dashboard'));
    }
  }
}
