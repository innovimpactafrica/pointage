import 'package:equatable/equatable.dart';

abstract class WorkerPresenceHistoryEvent extends Equatable {
  const WorkerPresenceHistoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadWorkerPresenceHistoryEvent extends WorkerPresenceHistoryEvent {
  final int workerId;
  const LoadWorkerPresenceHistoryEvent(this.workerId);
  @override
  List<Object?> get props => [workerId];
}
