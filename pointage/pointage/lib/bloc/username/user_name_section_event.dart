import 'package:equatable/equatable.dart';

abstract class UserNameSectionEvent extends Equatable {
  const UserNameSectionEvent();

  @override
  List<Object?> get props => [];
}

class LoadCurrentUserEvent extends UserNameSectionEvent {}
