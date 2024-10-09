import 'package:equatable/equatable.dart';

import '../../models/stand.dart';

abstract class StandState extends Equatable {
  const StandState();

  @override
  List<Object> get props => [];
}

class StandInitial extends StandState {}

class StandCreating extends StandState {}

class StandCreated extends StandState {
  final Stand stand;

  const StandCreated(this.stand);

  @override
  List<Object> get props => [stand];
}

class StandError extends StandState {
  final String message;

  const StandError(this.message);

  @override
  List<Object> get props => [message];
}