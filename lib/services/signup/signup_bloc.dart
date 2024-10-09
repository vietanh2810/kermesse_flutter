import 'package:bloc/bloc.dart';

import '../authentication_service.dart';

import 'signup_event.dart';
import 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final AuthenticationService _authenticationService;

  SignupBloc(this._authenticationService) : super(SignupInitial()) {
    on<SignUpButtonPressed>(_onSignUpButtonPressed);
  }

  void _onSignUpButtonPressed(SignUpButtonPressed event, Emitter<SignupState> emit) async {
    emit(SignupLoading());
    try {
      await _authenticationService.register(
          email: event.email,
          password: event.password,
          confirmPassword: event.confirmPassword,
          name: event.name,
          role: event.role,
          studentEmails: event.studentEmails
      );
      emit(SignupSuccess());
    } catch (e) {
      emit(SignupFailure(error: e.toString()));
    }
  }
}
