import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kermesse_flutter/widgets/buttons/button_base.dart';

import '../../../services/login/login_bloc.dart';
import '../../../services/login/login_event.dart';
import '../../../services/login/login_state.dart';
import '../app.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginBloc = BlocProvider.of<LoginBloc>(context);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(13,138,182, 1.0),
      body: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MainScreen(token: state.token),
              ),
            );
          } else if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            return Stack(
              children: [
                Column(
                  children: <Widget>[
                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: Center(
                        child: Image.asset(
                          'assets/logo-removebg.png',
                          height: 200.0,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30.0),
                          topRight: Radius.circular(30.0),
                        ),
                        child: Container(
                          color: Colors.white,
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Connexion',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  TextField(
                                    controller: emailController,
                                    decoration: const InputDecoration(labelText: 'Email'),
                                  ),
                                  TextField(
                                    controller: passwordController,
                                    decoration: const InputDecoration(labelText: 'Mot de passe'),
                                    obscureText: true,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('Vous n\'avez pas encore de compte?'),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pushNamed('/register');
                                        },
                                        child: const Text(
                                          'S\'inscrire',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: ButtonBase(
                                      text: 'Se connecter',
                                      onPressed: () {
                                        loginBloc.add(LoginButtonPressed(
                                          email: emailController.text,
                                          password: passwordController.text,
                                        ));
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (state is LoginLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}