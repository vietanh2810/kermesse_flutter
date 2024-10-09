import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../models/user.dart';
import '../../utils/config.dart';
import 'user_event.dart';
import 'user_state.dart';
class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<FetchUser>(_onFetchUser);
  }

  Future<void> _onFetchUser(FetchUser event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/me'),
        headers: {
          'Authorization': 'Bearer ${event.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        if (kDebugMode) {
          print('User data: $userData');
        }
        final user = User.fromJson(userData);

        if (kDebugMode) {
          print('User data: ${user.name}, ${user.tokens}');
          if (user.role == 'parent' && user.students != null) {
            print('Number of students: ${user.students!.length}');
          }
        }
        emit(UserLoaded(user));
      } else {
        emit(UserError('Failed to fetch user data'));
      }
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}