import 'package:equatable/equatable.dart';
import '../../models/TaskModel.dart';

abstract class WorkerTasksState extends Equatable {
  const WorkerTasksState();
  @override
  List<Object?> get props => [];
}

class WorkerTasksLoading extends WorkerTasksState {}

class WorkerTasksLoaded extends WorkerTasksState {
  final List<TaskModel> tasks;
  const WorkerTasksLoaded(this.tasks);
  @override
  List<Object?> get props => [tasks];
}

class WorkerTasksError extends WorkerTasksState {
  final String message;
  const WorkerTasksError(this.message);
  @override
  List<Object?> get props => [message];
}
