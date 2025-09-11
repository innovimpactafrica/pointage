import 'package:equatable/equatable.dart';

abstract class WorkerCheckState extends Equatable {
  const WorkerCheckState();
  @override
  List<Object?> get props => [];
}

class WorkerCheckInitial extends WorkerCheckState {}

class WorkerCheckLoading extends WorkerCheckState {}

class WorkerCheckSuccess extends WorkerCheckState {
  final String time;
  final bool isEntry;
  const WorkerCheckSuccess({required this.time, required this.isEntry});
  @override
  List<Object?> get props => [time, isEntry];
}

class WorkerCheckError extends WorkerCheckState {
  final String message;
  const WorkerCheckError(this.message);
  @override
  List<Object?> get props => [message];
}
