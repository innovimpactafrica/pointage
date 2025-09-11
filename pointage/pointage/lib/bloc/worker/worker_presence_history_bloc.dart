import 'package:flutter_bloc/flutter_bloc.dart';
import 'worker_presence_history_event.dart';
import 'worker_presence_history_state.dart';
import '../../repository/worker_repository.dart';

class WorkerPresenceHistoryBloc
    extends Bloc<WorkerPresenceHistoryEvent, WorkerPresenceHistoryState> {
  final WorkerRepository repository;
  WorkerPresenceHistoryBloc({required this.repository})
    : super(WorkerPresenceHistoryLoading()) {
    on<LoadWorkerPresenceHistoryEvent>(_onLoadHistory);
  }

  Future<void> _onLoadHistory(
    LoadWorkerPresenceHistoryEvent event,
    Emitter<WorkerPresenceHistoryState> emit,
  ) async {
    emit(WorkerPresenceHistoryLoading());
    try {
      final history = await repository.getPresenceHistory(event.workerId);
      emit(WorkerPresenceHistoryLoaded(history));
    } catch (e) {
      emit(
        WorkerPresenceHistoryError(
          'Erreur lors du chargement de l\'historique de présence',
        ),
      );
    }
  }
}
