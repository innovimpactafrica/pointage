import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/task_repository.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;

  TaskBloc({required TaskRepository taskRepository})
    : _taskRepository = taskRepository,
      super(TaskInitial()) {
    on<LoadTasksEvent>(_onLoadTasks);
    on<UpdateTaskStatusEvent>(_onUpdateTaskStatus);
    on<FilterTasksEvent>(_onFilterTasks);
  }

  Future<void> _onLoadTasks(
    LoadTasksEvent event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      final tasks = await _taskRepository.getTasksByExecutor(event.executorId);
      emit(TaskLoaded(tasks: tasks));
    } catch (e) {
      emit(TaskError('Erreur lors du chargement des tâches: $e'));
    }
  }

  Future<void> _onUpdateTaskStatus(
    UpdateTaskStatusEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await _taskRepository.taskService.updateTaskStatus(
        event.taskId,
        event.status,
      );

      // Recharger les tâches après mise à jour
      if (state is TaskLoaded) {
        final currentState = state as TaskLoaded;
        add(LoadTasksEvent(currentState.tasks.first.executors.first.id));
      }
    } catch (e) {
      emit(TaskError('Erreur lors de la mise à jour: $e'));
    }
  }

  void _onFilterTasks(FilterTasksEvent event, Emitter<TaskState> emit) {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      emit(TaskLoaded(tasks: currentState.tasks, currentFilter: event.filter));
    }
  }
}
