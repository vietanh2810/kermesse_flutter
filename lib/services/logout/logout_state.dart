import 'package:equatable/equatable.dart';

abstract class LogoutState extends Equatable {
  @override
  List<Object> get props => [];
}

class LogoutInitial extends LogoutState {}

class LogoutInProgress extends LogoutState {}

class LogoutSuccess extends LogoutState {}

class LogoutFailure extends LogoutState {
  final String error;

  LogoutFailure({required this.error});

  @override
  List<Object> get props => [error];
}