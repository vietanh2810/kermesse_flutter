import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kermesse_flutter/models/kermesse.dart';

import '../../models/user.dart';
import '../../services/kermesses/kermesses_bloc.dart';
import '../../services/kermesses/kermesses_event.dart';
import '../../services/kermesses/kermesses_state.dart';
import '../../services/stands/stands_bloc.dart';
import '../../services/stands/stands_event.dart';
import '../../services/stands/stands_state.dart';
import '../../services/user/user_bloc.dart';
import '../../services/user/user_event.dart';
import '../../services/user/user_state.dart';
import '../../widgets/buttons/stripe_widget.dart';
import '../stands/stand_detail.dart';

class KermesseDetailPage extends StatefulWidget {
  final String token;
  final Kermesse currentKermesse;
  final User currentUser;

  const KermesseDetailPage({
    super.key,
    required this.token,
    required this.currentKermesse,
    required this.currentUser,
  });

  @override
  _KermesseDetailPageState createState() => _KermesseDetailPageState();
}

class _KermesseDetailPageState extends State<KermesseDetailPage> {
  late Kermesse _currentKermesse;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentKermesse = widget.currentKermesse;
    _currentUser = widget.currentUser;
  }

  void _updateParticipationStatus(bool isParticipant) {
    setState(() {
      _currentKermesse =
          _currentKermesse.copyWith(isParticipant: isParticipant);
    });
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _showTokenPurchaseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TokenPurchaseDialog(
          token: widget.token,
          kermesseId: _currentKermesse.id.toString(),
        );
      },
    );
  }

  Icon _getStandIcon(String standType) {
    switch (standType) {
      case 'food':
        return const Icon(Icons.fastfood);
      case 'activity':
        return const Icon(Icons.sports_kabaddi);
      default:
        return const Icon(Icons.emoji_food_beverage);
    }
  }

  void _showCreateStand(BuildContext context) {
    String name = '';
    String type = 'food'; // Default type
    String description = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create a Stand'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Stand Name'),
                  onChanged: (value) => name = value,
                ),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: InputDecoration(labelText: 'Stand Type'),
                  items: ['food', 'activity', 'drink'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) => type = value!,
                ),
                TextField(
                  decoration: InputDecoration(labelText: 'Description'),
                  onChanged: (value) => description = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Create'),
              onPressed: () {
                if (name.isNotEmpty && description.isNotEmpty) {
                  BlocProvider.of<StandBloc>(context).add(
                    CreateStand(
                      token: widget.token,
                      kermesseId: _currentKermesse.id,
                      name: name,
                      type: type,
                      description: description,
                    ),
                  );
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showParticipationConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Participation'),
          content: const Text('Do you want to participate in this kermesse?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                BlocProvider.of<KermessesBloc>(context).add(
                  ParticipateInKermesse(
                    token: widget.token, // Use widget.token here
                    kermesseId: _currentKermesse.id.toString(),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kermesse detail'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(13, 138, 182, 1.0),
        actions: [
          if (_currentKermesse.isParticipant == false)
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () => _showParticipationConfirmationDialog(context),
              tooltip: 'Participate in Kermesse',
            ),
          if (_currentKermesse.isParticipant == true &&
              (_currentUser.role == 'parent' || _currentUser.role == 'student'))
            Row(
              children: [
                Text('Tokens: ${_currentUser.tokens ?? 0}'),
                if (_currentUser.role == 'parent')
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showTokenPurchaseDialog(context),
                    tooltip: 'Purchase Tokens',
                  ),
              ],
            ),
          if (_currentKermesse.isParticipant == true &&
              _currentUser.role == 'stand_holder')
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreateStand(context),
              tooltip: 'Create a stand in Kermesse',
            ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<KermessesBloc, KermessesState>(
            listener: (context, state) {
              if (state is KermesseParticipationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
                _updateParticipationStatus(true);
              } else if (state is KermessesLoaded) {
                setState(() {
                  _currentKermesse = state.kermesses.firstWhere(
                      (kermesse) => kermesse.id == _currentKermesse.id);
                });
              } else if (state is TokenPurchaseSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Successfully purchased ${state.amount} tokens')),
                );
                context.read<UserBloc>().add(FetchUser(widget.token));
              } else if (state is KermesseError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${state.message}')),
                );
              }
            },
          ),
          BlocListener<UserBloc, UserState>(
            listener: (context, state) {
              if (state is UserLoaded) {
                setState(() {
                  _currentUser = state.user;
                });
              }
            },
          ),
          BlocListener<StandBloc, StandState>(
            listener: (context, state) {
              if (state is StandCreated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Stand "${state.stand.name}" created successfully')),
                );
                // Fetch updated kermesse details
                context.read<KermessesBloc>().add(
                      FetchKermesses(
                        widget.token,
                      ),
                    );
              } else if (state is StandError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Error creating stand: ${state.message}')),
                );
              }
            },
          ),
        ],
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: const Color.fromRGBO(13, 138, 182, 0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5,
                      margin: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _currentKermesse.name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  formatDate(_currentKermesse.date),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_pin,
                                    color: Colors.white),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    _currentKermesse.location,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _currentKermesse.description,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Stands:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_currentKermesse.stands != null && _currentKermesse.stands!.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _currentKermesse.stands!.length,
                            itemBuilder: (context, index) {
                              final stand = _currentKermesse.stands![index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  title: Text(
                                    stand.name,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(stand.description),
                                  trailing: _getStandIcon(stand.type),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StandDetailPage(
                                            stand: stand,
                                            token: widget.token,
                                            currentUser: _currentUser
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          )
                        else
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            elevation: 3,
                            margin: const EdgeInsets.all(10),
                            child: const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('No stands available.'),
                            ),
                          ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
