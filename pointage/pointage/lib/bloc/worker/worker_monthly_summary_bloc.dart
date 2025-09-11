import 'package:flutter_bloc/flutter_bloc.dart';
import 'worker_monthly_summary_event.dart';
import 'worker_monthly_summary_state.dart';
import '../../repository/worker_repository.dart';

class WorkerMonthlySummaryBloc
    extends Bloc<WorkerMonthlySummaryEvent, WorkerMonthlySummaryState> {
  final WorkerRepository repository;
  WorkerMonthlySummaryBloc({required this.repository})
    : super(WorkerMonthlySummaryLoading()) {
    on<LoadWorkerMonthlySummaryEvent>(_onLoadSummary);
  }

  Future<void> _onLoadSummary(
    LoadWorkerMonthlySummaryEvent event,
    Emitter<WorkerMonthlySummaryState> emit,
  ) async {
    emit(WorkerMonthlySummaryLoading());
    try {
      final summary = await repository.getMonthlySummary(event.workerId);
      emit(WorkerMonthlySummaryLoaded(summary));
    } catch (e) {
      emit(
        WorkerMonthlySummaryError('Erreur lors du chargement de l\'historique'),
      );
    }
  }
}
