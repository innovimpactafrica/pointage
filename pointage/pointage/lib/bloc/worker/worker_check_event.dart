import 'package:equatable/equatable.dart';

abstract class WorkerCheckEvent extends Equatable {
  const WorkerCheckEvent();
  @override
  List<Object?> get props => [];
}

class DoWorkerCheckEvent extends WorkerCheckEvent {
  final int workerId;
  final String? qrCodeText;
  final double? latitude;
  final double? longitude;
  const DoWorkerCheckEvent(this.workerId, {this.qrCodeText, this.latitude, this.longitude});
  @override
  List<Object?> get props => [workerId, qrCodeText, latitude, longitude];
}
