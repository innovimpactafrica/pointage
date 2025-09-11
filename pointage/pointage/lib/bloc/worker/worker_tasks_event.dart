import 'package:equatable/equatable.dart';

abstract class WorkerTasksEvent extends Equatable {
  const WorkerTasksEvent();
  @override
  List<Object?> get props => [];
}

class LoadWorkerTasksEvent extends WorkerTasksEvent {
  final int executorId;
  const LoadWorkerTasksEvent(this.executorId);
  @override
  List<Object?> get props => [executorId];
}
