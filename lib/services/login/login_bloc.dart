import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';

import '../../models/user.dart';
import '../authentication_service.dart';
import 'login_event.dart';
import 'login_state.dart';



class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthenticationService _authService;
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;

  LoginBloc(this._authService) : super(LoginInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
  }


  void _onLoginButtonPressed(LoginButtonPressed event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    try {
      if (event.email.isEmpty || event.password.isEmpty) {
        emit(LoginFailure(error: "Email and password cannot be empty"));
        return;
      }

      if (kDebugMode) {
        print('Attempting login with email: ${event.email}');
      }

      Map<String, dynamic> loginResult = await _authService.login(event.email, event.password);
      String token = loginResult['token'];
      User user = loginResult['user'];

      if (kDebugMode) {
        print('Login successful, token: $token');
        print('User: ${user.name}, Role: ${user.role}');
      }

      emit(LoginSuccess(token: token, user: user));
    } catch (error) {
      if (kDebugMode) {
        print('Login error: $error');
      }
      emit(LoginFailure(error: "An error occurred: $error"));
    }
  }

}

