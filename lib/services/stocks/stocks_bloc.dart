import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kermesse_flutter/services/stocks/stocks_event.dart';
import 'package:kermesse_flutter/services/stocks/stocks_state.dart';

import '../../models/stock.dart';
import '../../utils/config_io.dart';
import 'package:http/http.dart' as http;

class StockBloc extends Bloc<StockEvent, StockState> {
  StockBloc() : super(StockInitial()) {
    on<CreateStock>(_onCreateStock);
    on<UpdateStock>(_onUpdateStock);
    on<PurchaseStock>(_onPurchaseStock);
  }

  Future<void> _onUpdateStock(UpdateStock event, Emitter<StockState> emit) async {
    emit(StockUpdating());
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/kermesses/${event.standId}/stand/${event.standId}/stock/update'),
        headers: {
          'Authorization': 'Bearer ${event.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'stock_id': event.stockId,
          'item_name': event.itemName,
          'quantity': event.quantity,
          'token_cost': event.tokenCost,
        }),
      );

      if (response.statusCode == 200) {
        final updatedStock = Stock(
          id: event.stockId,
          standId: event.standId,
          itemName: event.itemName,
          quantity: event.quantity,
          tokenCost: event.tokenCost,
        );
        emit(StockUpdated(updatedStock));
      } else {
        throw Exception('Failed to update stock: ${response.body}');
      }
    } catch (e) {
      emit(StockError(e.toString()));
    }
  }

  Future<void> _onCreateStock(CreateStock event, Emitter<StockState> emit) async {
    emit(StockCreating());
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/kermesses/${event.standId}/stand/${event.standId}/stock'),
        headers: {
          'Authorization': 'Bearer ${event.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'itemName': event.itemName,
          'quantity': event.quantity,
          'tokenCost': event.tokenCost,
        }),
      );

      if (kDebugMode) {
        print("Create stock body");
        print(response.body);
      }

      if (response.statusCode == 201) {
        final stockData = jsonDecode(response.body);
        final stock = Stock.fromJson(stockData);
        emit(StockCreated(stock));
      } else {
        throw Exception('Failed to create stock: ${response.body}');
      }
    } catch (e) {
      emit(StockError(e.toString()));
    }
  }

  Future<void> _onPurchaseStock(PurchaseStock event, Emitter<StockState> emit) async {
    emit(StockPurchasing());
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/kermesses/${event.kermesseId}/stand/${event.standId}/purchase'),
        headers: {
          'Authorization': 'Bearer ${event.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'stock_id': event.stockId,
          'quantity': event.quantity,
        }),
      );

      if (kDebugMode) {
        print("Purchase stock body");
        print(response.body);
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(StockPurchased(
          message: data['message'],
          remainingTokens: data['remainingTokens'],
        ));
      } else {
        throw Exception('Failed to purchase stock: ${response.body}');
      }
    } catch (e) {
      emit(StockError(e.toString()));
    }
  }

}