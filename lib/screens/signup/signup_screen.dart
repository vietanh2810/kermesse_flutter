import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kermesse_flutter/services/signup/signup_bloc.dart';
import 'package:kermesse_flutter/services/signup/signup_state.dart';
import 'package:kermesse_flutter/services/signup/signup_event.dart';

import '../../widgets/buttons/button_base.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  SignupScreenState createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String? _selectedRole;

  final List<String> _studentEmails = [];
  final TextEditingController _studentEmailController = TextEditingController();

  void _addStudentEmail() {
    if (_studentEmailController.text.isNotEmpty) {
      setState(() {
        _studentEmails.add(_studentEmailController.text);
        _studentEmailController.clear();
      });
    }
  }

  String getRoleValue(String role) {
    switch (role) {
      case 'Student':
        return 'student';
      case 'Parent':
        return 'parent';
      case 'Stand Holder':
        return 'stand_holder';
      case 'Organizer':
        return 'organizer';
      default:
        return '';
    }
  }


  void _onRegisterButtonPressed() {
    if (_formKey.currentState!.validate()) {
      BlocProvider.of<SignupBloc>(context).add(
        SignUpButtonPressed(
          name: _nameController.text,
          confirmPassword: _confirmPasswordController.text,
          role: _selectedRole ?? '',
          studentEmails: _selectedRole?.toLowerCase() == 'parent' ? _studentEmails : [],
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(90.0),
          child: Image.asset(
            'assets/logo.jpeg',
            height: 35.0,
          ),
        ),
        backgroundColor: const Color.fromRGBO(203,203,203, 1.0)
      ),
      body: BlocListener<SignupBloc, SignupState>(
        listener: (context, state) {
          if (state is SignupSuccess) {
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(const SnackBar(content: Text('Inscription réussie! Vous pouvez vous connecter maintenant.')));

            Navigator.of(context).pushReplacementNamed('/login');
          }
          if (state is SignupFailure) {
            ScaffoldMessenger.of(context)
              ..removeCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text('Erreur d\'inscription: ${state.error}')));
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Text(
                  'Bienvenue sur Kermesse',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Créer un compte pour commencer à participer à un kermesse',
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nom d\'utilisateur'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Veuillez entrer un nom d\'utilisateur';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Veuillez entrer un email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Veuillez entrer un mot de passe';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Veuillez entrer un mot de passe';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Choisissez votre role',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'student', child: Text('Student')),
                    DropdownMenuItem(value: 'parent', child: Text('Parent')),
                    DropdownMenuItem(value: 'stand_holder', child: Text('Stand Holder')),
                    DropdownMenuItem(value: 'organizer', child: Text('Organizer')),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner un role';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                if (_selectedRole?.toLowerCase() == 'parent') ...[
                  TextFormField(
                    controller: _studentEmailController,
                    decoration: const InputDecoration(labelText: 'Student Email'),
                    validator: (value) {
                      if (_studentEmails.isEmpty) {
                        return 'At least one student email is required';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: _addStudentEmail,
                    child: const Text('Add Student Email'),
                  ),
                  // Display added student emails
                  ..._studentEmails.map((email) => ListTile(
                    title: Text(email),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _studentEmails.remove(email);
                        });
                      },
                    ),
                  )),
                ],
                const SizedBox(height: 30),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ButtonBase(
                    text: 'S\'inscrire',
                    onPressed: _onRegisterButtonPressed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}