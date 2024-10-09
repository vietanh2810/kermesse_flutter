import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kermesse_flutter/services/stands/stands_event.dart';
import 'package:kermesse_flutter/services/stands/stands_state.dart';

import '../../models/stand.dart';
import 'package:http/http.dart' as http;
import '../../utils/config_io.dart';

class StandBloc extends Bloc<StandEvent, StandState> {
  StandBloc() : super(StandInitial()) {
    on<CreateStand>(_onCreateStand);
  }

  Future<void> _onCreateStand(CreateStand event, Emitter<StandState> emit) async {
    emit(StandCreating());
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/kermesses/${event.kermesseId}/stand'),
        headers: {
          'Authorization': 'Bearer ${event.token}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': event.name,
          'type': event.type,
          'description': event.description,
          'stock': [], // Empty stock as per your requirement
        }),
      );

      if (kDebugMode) {
        print("Create stand body");
        print(response.body);
      }

      if (response.statusCode == 201) {
        final standData = jsonDecode(response.body);
        final stand = Stand.fromJson(standData);
        emit(StandCreated(stand));
      } else {
        throw Exception('Failed to create stand: ${response.body}');
      }
    } catch (e) {
      emit(StandError(e.toString()));
    }
  }
}