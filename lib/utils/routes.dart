import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../screens/login/login_screen.dart';
import '../screens/signup/signup_screen.dart';
import '../services/authentication_service.dart';
import '../services/signup/signup_bloc.dart';

Map<String, WidgetBuilder> getApplicationRoutes() {
  return {
    '/login': (BuildContext context) => const LoginPage(),
    '/register': (context) => BlocProvider(
      create: (context) => SignupBloc(AuthenticationService()),
      child: const SignupPage(),
    ),
  };
}

Route<dynamic> unknownRoute(RouteSettings settings) {
  return MaterialPageRoute(
    builder: (BuildContext context) => const Scaffold(
      body: Center(
        child: Text('Page not found :('),
      ),
    ),
  );
}