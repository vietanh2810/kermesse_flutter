import 'package:equatable/equatable.dart';

abstract class StockEvent extends Equatable {
  const StockEvent();

  @override
  List<Object> get props => [];
}

class CreateStock extends StockEvent {
  final String token;
  final int standId;
  final String itemName;
  final int quantity;
  final int tokenCost;

  const CreateStock({
    required this.token,
    required this.standId,
    required this.itemName,
    required this.quantity,
    required this.tokenCost,
  });

  @override
  List<Object> get props => [token, standId, itemName, quantity, tokenCost];
}

class UpdateStock extends StockEvent {
  final String token;
  final int standId;
  final int stockId;
  final String itemName;
  final int quantity;
  final int tokenCost;

  const UpdateStock({
    required this.token,
    required this.standId,
    required this.stockId,
    required this.itemName,
    required this.quantity,
    required this.tokenCost,
  });

  @override
  List<Object> get props => [token, standId, stockId, itemName, quantity, tokenCost];
}

class PurchaseStock extends StockEvent {
  final String token;
  final int kermesseId;
  final int standId;
  final int stockId;
  final int quantity;

  const PurchaseStock({
    required this.token,
    required this.kermesseId,
    required this.standId,
    required this.stockId,
    required this.quantity,
  });

  @override
  List<Object> get props => [token, kermesseId, standId, stockId, quantity];
}
