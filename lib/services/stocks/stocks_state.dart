import 'package:equatable/equatable.dart';

import '../../models/stock.dart';

abstract class StockState extends Equatable {
  const StockState();

  @override
  List<Object> get props => [];
}

class StockInitial extends StockState {}

class StockCreating extends StockState {}

class StockUpdating extends StockState {}

class StockCreated extends StockState {
  final Stock stock;

  const StockCreated(this.stock);

  @override
  List<Object> get props => [stock];
}

class StockError extends StockState {
  final String message;

  const StockError(this.message);

  @override
  List<Object> get props => [message];
}
class StockUpdated extends StockState {
  final Stock stock;

  const StockUpdated(this.stock);

  @override
  List<Object> get props => [stock];
}

class StockPurchasing extends StockState {}

class StockPurchased extends StockState {
  final String message;
  final int remainingTokens;

  const StockPurchased({required this.message, required this.remainingTokens});

  @override
  List<Object> get props => [message, remainingTokens];
}