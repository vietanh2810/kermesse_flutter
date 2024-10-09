import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:kermesse_flutter/services/transactions/transactions_event.dart';
import 'package:kermesse_flutter/services/transactions/transactions_state.dart';
import 'dart:convert';

import '../../models/transactions.dart';
import '../../utils/config_io.dart';


class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {

  TransactionBloc() : super(TransactionInitial()) {
    on<FetchChildrenTransactions>(_onFetchChildrenTransactions);
  }


  Future<void> _onFetchChildrenTransactions(
      FetchChildrenTransactions event,
      Emitter<TransactionState> emit,
      ) async {
    emit(TransactionLoading());
    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/children_transactions'),
        headers: {
          'Authorization': 'Bearer ${event.token}',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print('Response token child transac: ${response.body}');
        print('request: ${response.request}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> transactionsJson = json.decode(response.body);
        final List<TokenTransaction> transactions = transactionsJson
            .map((json) => TokenTransaction.fromJson(json))
            .toList();

        if (transactions.isEmpty) {
          emit(TransactionEmpty());
        } else {
          emit(TransactionLoaded(transactions));
        }
      } else {
        emit(TransactionError('Failed to fetch transactions: ${response.statusCode}'));
      }
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}

