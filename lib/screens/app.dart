import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kermesse_flutter/screens/profiles/parent_profile.dart';
import 'package:kermesse_flutter/services/kermesses/kermesses_bloc.dart';
// import 'package:front/screens/profile/profile_screen.dart';
import '../models/user.dart';
import '../services/kermesses/kermesses_event.dart';
// import 'kermesses/kermesses_screen.dart';
import '../services/user/user_bloc.dart';
import '../services/user/user_event.dart';
import '../services/user/user_state.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  final String token;

  const MainScreen({super.key, required this.token});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late KermessesBloc _kermessesBloc;
  late UserBloc _userBloc;

  @override
  void initState() {
    super.initState();
    _kermessesBloc = KermessesBloc();
    _userBloc = UserBloc();

    _userBloc.add(FetchUser(widget.token));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _kermessesBloc.add(FetchKermesses(widget.token));
    _userBloc.add(FetchUser(widget.token));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _kermessesBloc),
        BlocProvider.value(value: _userBloc),
      ],
      child: BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          if (userState is UserLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (userState is UserError) {
            return Scaffold(body: Center(child: Text('Error User app.dart: ${userState.message}')));
          } else if (userState is UserLoaded) {
            final bool isParent = userState.user.role == 'parent';

            final List<Widget> widgetOptions = [
              HomeScreen(token: widget.token, user: userState.user),
              if (isParent)
                ParentProfilePage(parent: userState.user, token: widget.token),
            ];

            return Scaffold(
              body: IndexedStack(
                index: isParent ? _selectedIndex : 0,
                children: widgetOptions.map((widget) =>
                    MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: _kermessesBloc),
                        BlocProvider.value(value: _userBloc),
                      ],
                      child: widget,
                    )
                ).toList(),
              ),
              bottomNavigationBar: isParent ? BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Accueil',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profil',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: const Color.fromRGBO(13,138,182, 1.0),
                onTap: _onItemTapped,
              ) : null,
            );
          } else {
            return const Scaffold(body: Center(child: Text('Something went wrong')));
          }
        },
      ),
    );
  }
}