import 'package:flutter_bloc/flutter_bloc.dart';
import 'user_name_section_event.dart';
import 'user_name_section_state.dart';
import '../../repository/auth_repository.dart';

class UserNameSectionBloc
    extends Bloc<UserNameSectionEvent, UserNameSectionState> {
  final AuthRepository authRepository;
  UserNameSectionBloc({required this.authRepository})
    : super(UserNameInitial()) {
    on<LoadCurrentUserEvent>(_onLoadCurrentUser);
  }

  Future<void> _onLoadCurrentUser(
    LoadCurrentUserEvent event,
    Emitter<UserNameSectionState> emit,
  ) async {
    emit(UserNameLoading());
    try {
      final user = await authRepository.currentUser();
      emit(UserNameLoaded(user));
    } catch (e) {
      emit(UserNameError('Erreur lors du chargement du user'));
    }
  }
}
