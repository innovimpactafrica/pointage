import 'package:equatable/equatable.dart';

abstract class WorkerMonthlySummaryEvent extends Equatable {
  const WorkerMonthlySummaryEvent();
  @override
  List<Object?> get props => [];
}

class LoadWorkerMonthlySummaryEvent extends WorkerMonthlySummaryEvent {
  final int workerId;
  const LoadWorkerMonthlySummaryEvent(this.workerId);
  @override
  List<Object?> get props => [workerId];
}
