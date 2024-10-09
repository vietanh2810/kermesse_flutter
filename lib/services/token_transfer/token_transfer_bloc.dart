import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kermesse_flutter/services/token_transfer/token_transfer_event.dart';
import 'package:kermesse_flutter/services/token_transfer/token_transfer_state.dart';
import 'package:http/http.dart' as http;
import '../../utils/config_io.dart';

class TokenTransferBloc extends Bloc<TokenTransferEvent, TokenTransferState> {
  TokenTransferBloc() : super(TokenTransferInitial()) {
    on<SendTokensToChild>(_onSendTokensToChild);
  }

  Future<void> _onSendTokensToChild(
      SendTokensToChild event,
      Emitter<TokenTransferState> emit,
      ) async {
    emit(TokenTransferLoading());
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/token/transferToChild'),
        headers: {
          'Authorization': 'Bearer ${event.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'student_id': event.studentId,
          'amount': event.amount,
        }),
      );

      if (response.statusCode == 201) {
        emit(TokenTransferSuccess());
      } else {
        emit(TokenTransferFailure('Failed to send tokens: ${response.statusCode}'));
      }
    } catch (e) {
      emit(TokenTransferFailure(e.toString()));
    }
  }
}