import 'package:equatable/equatable.dart';
import '../../models/PresenceHistoryModel.dart';

abstract class WorkerPresenceHistoryState extends Equatable {
  const WorkerPresenceHistoryState();
  @override
  List<Object?> get props => [];
}

class WorkerPresenceHistoryLoading extends WorkerPresenceHistoryState {}

class WorkerPresenceHistoryLoaded extends WorkerPresenceHistoryState {
  final PresenceHistoryModel history;
  const WorkerPresenceHistoryLoaded(this.history);
  @override
  List<Object?> get props => [history];
}

class WorkerPresenceHistoryError extends WorkerPresenceHistoryState {
  final String message;
  const WorkerPresenceHistoryError(this.message);
  @override
  List<Object?> get props => [message];
}
