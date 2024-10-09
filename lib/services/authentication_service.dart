import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/user.dart';
import '../utils/config.dart';

class AuthenticationService {
  late String _token;
  String get token => _token;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/auth/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        _token = responseBody['token'];
        User user = User.fromJson(responseBody['user']);

        if (kDebugMode) {
          print('Login successful, token: $_token');
          print('User: ${user.name}, Role: ${user.role}');
        }

        return {'token': _token, 'user': user};
      } else {
        if (kDebugMode) {
          print('Login failed: ${response.body}');
        }
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      rethrow;
    }
  }


  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String confirmPassword,
    required List<String> studentEmails,
  }) async {
    var uri = Uri.parse('${Config.baseUrl}/auth/signup');

    Map<String, dynamic> body = {
      'name': name,
      'email': email,
      'password': password,
      'confirm_password': confirmPassword,
      'role': role,
    };

    if (role.toLowerCase() == 'parent' && studentEmails.isNotEmpty) {
      body['student_emails'] = studentEmails;
    }

    var jsonBody = json.encode(body);

    if (kDebugMode) {
      print('Request URL: $uri');
      print('Request body: $jsonBody');
    }

    try {
      var response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonBody,
      );

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      if (response.statusCode == 201) {
        print('Registration successful');
      } else {
        throw Exception('Failed to register: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during registration: $e');
      }
      rethrow;
    }
  }
  // Destroy the token
  Future<bool> logout() async {
    _token = '';
    return true;
  }
}