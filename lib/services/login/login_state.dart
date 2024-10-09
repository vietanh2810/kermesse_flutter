import 'package:equatable/equatable.dart';

import '../../models/user.dart';

abstract class LoginState extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}
class LoginLoading extends LoginState {}
class LoginFailure extends LoginState {
  final String error;

  LoginFailure({required this.error});

  @override
  List<Object> get props => [error];
}

class LoginSuccess extends LoginState {
  final String token;
  final User user;

  LoginSuccess({required this.token, required this.user});

  @override
  List<Object> get props => [token, user];
}