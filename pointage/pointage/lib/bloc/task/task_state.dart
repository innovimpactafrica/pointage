import 'package:equatable/equatable.dart';
import '../../models/TaskModel.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskModel> tasks;
  final String currentFilter;

  const TaskLoaded({required this.tasks, this.currentFilter = 'Toutes'});

  @override
  List<Object> get props => [tasks, currentFilter];
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object> get props => [message];
}

class TaskStatusUpdated extends TaskState {
  final TaskModel task;

  const TaskStatusUpdated(this.task);

  @override
  List<Object> get props => [task];
}
