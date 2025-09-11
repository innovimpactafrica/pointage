import 'package:flutter_bloc/flutter_bloc.dart';
import 'worker_check_event.dart';
import 'worker_check_state.dart';
import '../../repository/worker_repository.dart';

class WorkerCheckBloc extends Bloc<WorkerCheckEvent, WorkerCheckState> {
  final WorkerRepository repository;
  bool isEntry = true;
  String? lastEntry;
  String? lastExit;
  WorkerCheckBloc({required this.repository}) : super(WorkerCheckInitial()) {
    on<DoWorkerCheckEvent>(_onCheck);
  }

  Future<void> _onCheck(
    DoWorkerCheckEvent event,
    Emitter<WorkerCheckState> emit,
  ) async {
    emit(WorkerCheckLoading());
    try {
      final time = await repository.checkInOut(
        event.workerId,
        qrCodeText: event.qrCodeText,
        latitude: event.latitude,
        longitude: event.longitude,
      );
      if (isEntry) {
        lastEntry = time;
      } else {
        lastExit = time;
      }
      emit(WorkerCheckSuccess(time: time, isEntry: isEntry));
      isEntry = !isEntry;
    } catch (e) {
      emit(WorkerCheckError('Erreur lors du pointage: ${e.toString()}'));
    }
  }
}
