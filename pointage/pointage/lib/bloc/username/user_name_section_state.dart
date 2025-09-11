import 'package:equatable/equatable.dart';
import '../../models/UserModel.dart';

abstract class UserNameSectionState extends Equatable {
  const UserNameSectionState();

  @override
  List<Object?> get props => [];
}

class UserNameInitial extends UserNameSectionState {}

class UserNameLoading extends UserNameSectionState {}

class UserNameLoaded extends UserNameSectionState {
  final UserModel user;
  const UserNameLoaded(this.user);
  @override
  List<Object?> get props => [user];
}

class UserNameError extends UserNameSectionState {
  final String message;
  const UserNameError(this.message);
  @override
  List<Object?> get props => [message];
}
