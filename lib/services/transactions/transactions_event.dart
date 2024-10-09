import 'package:equatable/equatable.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class FetchChildrenTransactions extends TransactionEvent {
  final String token;

  const FetchChildrenTransactions(this.token);

  @override
  List<Object?> get props => [token];
}