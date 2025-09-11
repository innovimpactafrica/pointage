import 'package:equatable/equatable.dart';

abstract class WorkerDashboardEvent extends Equatable {
  const WorkerDashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadWorkerDashboardEvent extends WorkerDashboardEvent {
  final int workerId;
  const LoadWorkerDashboardEvent(this.workerId);
  @override
  List<Object?> get props => [workerId];
}
