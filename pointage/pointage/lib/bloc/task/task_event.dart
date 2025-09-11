import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class LoadTasksEvent extends TaskEvent {
  final int executorId;

  const LoadTasksEvent(this.executorId);

  @override
  List<Object> get props => [executorId];
}

class UpdateTaskStatusEvent extends TaskEvent {
  final int taskId;
  final String status;

  const UpdateTaskStatusEvent(this.taskId, this.status);

  @override
  List<Object> get props => [taskId, status];
}

class FilterTasksEvent extends TaskEvent {
  final String filter;

  const FilterTasksEvent(this.filter);

  @override
  List<Object> get props => [filter];
}
