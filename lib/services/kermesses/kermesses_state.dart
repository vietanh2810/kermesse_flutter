
import 'package:equatable/equatable.dart';

import '../../models/kermesse.dart';

abstract class KermessesState extends Equatable {
  const KermessesState();

  @override
  List<Object> get props => [];
}

class KermessesInitial extends KermessesState {}

class KermessesLoading extends KermessesState {}

class KermessesLoaded extends KermessesState {
  final List<Kermesse> kermesses;

  const KermessesLoaded({required this.kermesses});

  @override
  List<Object> get props => [kermesses];
}

class KermesseCreated extends KermessesState {
  final Kermesse kermesse;

  const KermesseCreated(this.kermesse);

  @override
  List<Object> get props => [kermesse];
}

class TokenPurchaseSuccess extends KermessesState {
  final int amount;

  const TokenPurchaseSuccess({required this.amount});

  @override
  List<Object> get props => [amount];
}

class KermesseParticipationSuccess extends KermessesState {
  final String message;

  const KermesseParticipationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class KermesseError extends KermessesState {
  final String message;

  const KermesseError(this.message);

  @override
  List<Object> get props => [message];

}