import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

import '../../models/kermesse.dart';
import 'kermesses_event.dart';
import 'kermesses_state.dart';
import 'package:http/http.dart' as http;
import '../../utils/config.dart';



class KermessesBloc extends Bloc<KermessesEvent, KermessesState> {
  KermessesBloc() : super(KermessesInitial()) {
    on<FetchKermesses>(_onFetchKermesses);
    on<ParticipateInKermesse>(_onParticipateInKermesse);
    on<CreateKermesse>(_onCreateKermesse);
    on<PurchaseTokens>(_onPurchaseTokens);
  }

  void _onFetchKermesses(FetchKermesses event, Emitter<KermessesState> emit) async {
    emit(KermessesLoading());
    try {
      final kermesses = await _fetchKermesses(event.token);
      emit(KermessesLoaded(kermesses: kermesses));
    } catch (error) {
      emit(KermesseError(error.toString()));
    }
  }

  void _onParticipateInKermesse(ParticipateInKermesse event, Emitter<KermessesState> emit) async {
    emit(KermessesLoading());
    try {
      final response = await _participateInKermesse(event.token, event.kermesseId);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(KermesseParticipationSuccess(message: data['message']));
        // Refetch kermesses to update the list
        add(FetchKermesses(event.token));
      } else {
        throw Exception('Failed to participate in kermesse: ${response.body}');
      }
    } catch (error) {
      emit(KermesseError(error.toString()));
    }
  }

  void _onCreateKermesse(CreateKermesse event, Emitter<KermessesState> emit) async {
    emit(KermessesLoading());
    try {
      final response = await _createKermesse(event.token, event.kermesseData);

      if (response.statusCode == 201) {

        if (kDebugMode) {
          print(response.request);
          print(response.body);
        }

        final data = jsonDecode(response.body);
        final newKermesse = Kermesse.fromJson(data);
        emit(KermesseCreated(newKermesse));
        // Refetch kermesses to update the list
        add(FetchKermesses(event.token));
      } else {
        throw Exception('Failed to create kermesse: ${response.body}');
      }
    } catch (error) {
      emit(KermesseError(error.toString()));
    }
  }

  Future<http.Response> _participateInKermesse(String token, String kermesseId) async {
    return await http.get(
      Uri.parse('${Config.baseUrl}/kermesses/$kermesseId/participate'),
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<List<Kermesse>> _fetchKermesses(String token) async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/kermesses'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Kermesse.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load kermesses: ${response.statusCode}');
    }
  }

  Future<http.Response> _createKermesse(String token, Map<String, dynamic> kermesseData) async {
    return await http.post(
      Uri.parse('${Config.baseUrl}/kermesses'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(kermesseData),
    );
  }
  void _onPurchaseTokens(PurchaseTokens event, Emitter<KermessesState> emit) async {
    emit(KermessesLoading());
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/kermesses/${event.kermesseId}/token/purchase'),
        headers: {
          'Authorization': 'Bearer ${event.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': event.amount,
          'payment_method_id': event.paymentMethodId,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        emit(TokenPurchaseSuccess(amount: event.amount));
      } else {
        throw Exception('Failed to purchase tokens: ${response.body}');
      }
    } catch (error) {
      emit(KermesseError(error.toString()));
    }
  }

}
