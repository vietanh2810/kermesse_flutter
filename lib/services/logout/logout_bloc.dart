import 'package:bloc/bloc.dart';

import '../authentication_service.dart';
import 'logout_event.dart';
import 'logout_state.dart';


class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final AuthenticationService _authenticationService;

  LogoutBloc(this._authenticationService) : super(LogoutInitial()) {
    on<LogoutRequested>((event, emit) async {
      emit(LogoutInProgress());
      try {
        await _authenticationService.logout();
        emit(LogoutSuccess());
      } catch (error) {
        emit(LogoutFailure(error: error.toString()));
      }
    });
  }
}
