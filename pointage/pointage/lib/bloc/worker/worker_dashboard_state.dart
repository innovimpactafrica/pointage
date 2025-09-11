import 'package:equatable/equatable.dart';
import '../../models/worker_dashboard_model.dart';

abstract class WorkerDashboardState extends Equatable {
  const WorkerDashboardState();
  @override
  List<Object?> get props => [];
}

class WorkerDashboardLoading extends WorkerDashboardState {}

class WorkerDashboardLoaded extends WorkerDashboardState {
  final WorkerDashboardModel dashboard;
  const WorkerDashboardLoaded(this.dashboard);
  @override
  List<Object?> get props => [dashboard];
}

class WorkerDashboardError extends WorkerDashboardState {
  final String message;
  const WorkerDashboardError(this.message);
  @override
  List<Object?> get props => [message];
}
