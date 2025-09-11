import 'package:flutter_bloc/flutter_bloc.dart';
import 'worker_tasks_event.dart';
import 'worker_tasks_state.dart';
import '../../repository/task_repository.dart';

class WorkerTasksBloc extends Bloc<WorkerTasksEvent, WorkerTasksState> {
  final TaskRepository repository;
  WorkerTasksBloc({required this.repository}) : super(WorkerTasksLoading()) {
    on<LoadWorkerTasksEvent>(_onLoadTasks);
  }

  Future<void> _onLoadTasks(
    LoadWorkerTasksEvent event,
    Emitter<WorkerTasksState> emit,
  ) async {
    emit(WorkerTasksLoading());
    try {
      final tasks = await repository.getTasksByExecutor(event.executorId);
      emit(WorkerTasksLoaded(tasks));
    } catch (e) {
      emit(WorkerTasksError('Erreur lors du chargement des tâches'));
    }
  }
}
