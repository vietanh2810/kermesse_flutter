import 'package:equatable/equatable.dart';

abstract class SignupEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignUpButtonPressed extends SignupEvent {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final String role;
  final List<String> studentEmails;

  SignUpButtonPressed({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.role,
    this.studentEmails = const [],
  }) {
    if (role.toLowerCase() == 'parent' && (studentEmails.isEmpty)) {
      throw ArgumentError('Student email is required for parent role');
    }
  }

  @override
  List<Object?> get props => [name, email, password, confirmPassword, role, studentEmails];
}