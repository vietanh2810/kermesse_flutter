import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kermesse_flutter/models/kermesse.dart';
import 'package:kermesse_flutter/services/kermesses/kermesses_bloc.dart';
import 'package:kermesse_flutter/services/kermesses/kermesses_event.dart';
import 'package:kermesse_flutter/services/kermesses/kermesses_state.dart';
import 'package:kermesse_flutter/services/logout/logout_state.dart';

import '../models/user.dart';
import '../services/logout/logout_bloc.dart';
import '../services/logout/logout_event.dart';
import 'kermesses/kermesse_detail_screen1.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  final User user;

  const HomeScreen({super.key, required this.token, required this.user});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool _showParticipatedKermesses = false;

  @override
  void initState() {
    super.initState();
    context.read<KermessesBloc>().add(FetchKermesses(widget.token));
  }

  List<Kermesse> _getFilteredKermesses(List<Kermesse> kermesses) {
    if (_showParticipatedKermesses) {
      return kermesses
          .where((kermesse) => kermesse.isParticipant ?? false)
          .toList();
    }
    return kermesses;
  }

  String formatDate(String dateString) {
    final date = DateFormat('yyyy-MM-dd').parse(dateString);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _showCreateKermesseModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return CreateKermesseForm(token: widget.token);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LogoutBloc, LogoutState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          Navigator.of(context).pushReplacementNamed('/login');
        } else if (state is LogoutFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Logout failed: ${state.error}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Dispatch LogoutRequested event
              BlocProvider.of<LogoutBloc>(context).add(LogoutRequested());
            },
            tooltip: 'Logout',
          ),
          title: const Text("Accueil"),
          backgroundColor: const Color.fromRGBO(13, 138, 182, 1.0),
          actions: [
            if (widget.user.role == "organizer")
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _showCreateKermesseModal,
              )
            else
              Row(
                children: [
                  const Text("Tous"),
                  Switch(
                    value: _showParticipatedKermesses,
                    onChanged: (bool value) {
                      setState(() {
                        _showParticipatedKermesses = value;
                      });
                    },
                  ),
                  const Text("Participés"),
                ],
              ),
          ],
        ),
        body: BlocListener<KermessesBloc, KermessesState>(
          listener: (context, state) {
            if (state is KermesseCreated) {
              context.read<KermessesBloc>().add(FetchKermesses(widget.token));
            }
          },
          child: BlocBuilder<KermessesBloc, KermessesState>(
            builder: (context, state) {
              if (state is KermessesLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is KermessesLoaded) {
                final filteredKermesses =
                    _getFilteredKermesses(state.kermesses);

                return RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<KermessesBloc>()
                        .add(FetchKermesses(widget.token));
                  },
                  child: ListView.builder(
                    itemCount: filteredKermesses.length,
                    itemBuilder: (context, index) {
                      final kermesse = filteredKermesses[index];

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          color: Colors.white,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => KermesseDetailPage(
                                    token: widget.token,
                                    currentKermesse: kermesse,
                                    currentUser: widget.user,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        kermesse.name,
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    kermesse.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else if (state is KermesseError) {
                return Center(
                    child:
                        Text('Error: kermesse home_screen ${state.message}'));
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }
}

class CreateKermesseForm extends StatefulWidget {
  final String token;

  const CreateKermesseForm({Key? key, required this.token}) : super(key: key);

  @override
  CreateKermesseFormState createState() => CreateKermesseFormState();
}

class CreateKermesseFormState extends State<CreateKermesseForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a location';
                }
                return null;
              },
            ),
            ListTile(
              title: const Text('Date'),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (pickedDate != null && pickedDate != _selectedDate) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newKermesse = {
                    "date": DateFormat('dd/MM/yyyy').format(_selectedDate),
                    "description": _descriptionController.text,
                    "location": _locationController.text,
                    "name": _nameController.text,
                  };
                  context.read<KermessesBloc>().add(CreateKermesse(
                        token: widget.token,
                        kermesseData: newKermesse,
                      ));
                  Navigator.pop(context);
                }
              },
              child: const Text('Create Kermesse'),
            ),
          ],
        ),
      ),
    );
  }
}
