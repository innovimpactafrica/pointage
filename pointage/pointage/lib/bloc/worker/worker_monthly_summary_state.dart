import 'package:equatable/equatable.dart';
import '../../models/MonthlySummaryModel.dart';

abstract class WorkerMonthlySummaryState extends Equatable {
  const WorkerMonthlySummaryState();
  @override
  List<Object?> get props => [];
}

class WorkerMonthlySummaryLoading extends WorkerMonthlySummaryState {}

class WorkerMonthlySummaryLoaded extends WorkerMonthlySummaryState {
  final MonthlySummaryModel summary;
  const WorkerMonthlySummaryLoaded(this.summary);
  @override
  List<Object?> get props => [summary];
}

class WorkerMonthlySummaryError extends WorkerMonthlySummaryState {
  final String message;
  const WorkerMonthlySummaryError(this.message);
  @override
  List<Object?> get props => [message];
}
