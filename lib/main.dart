import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:json_theme/json_theme.dart';
import 'package:kermesse_flutter/screens/app.dart';
import 'package:kermesse_flutter/services/authentication/authentication_bloc.dart';
import 'package:kermesse_flutter/services/authentication/authentication_state.dart';
import 'package:kermesse_flutter/services/authentication_service.dart';
import 'package:kermesse_flutter/utils/config_io.dart';
import 'package:kermesse_flutter/utils/routes.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:kermesse_flutter/screens/login/login_screen.dart';

import 'firebase_options.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: ".env");
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsFlutterBinding.ensureInitialized());

  await Future.delayed(const Duration(seconds: 2));
  FlutterNativeSplash.remove();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final themeStr = await rootBundle.loadString('assets/theme.json');
  final theme = ThemeDecoder.decodeThemeData(jsonDecode(themeStr))!;

  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = 'pk_test_51Q7FL608soAiLUIz8xoqTh6kK0ZbltJzR5XWXg7NNRQhAcS1IZjjYUFyevDrqD2301XTJJDgRYiHAaSM6NOGwa3G00iGGbbSTP';
  await Stripe.instance.applySettings();
  runApp(MyApp(theme: theme));
}

class MyApp extends StatelessWidget {
  final ThemeData theme;

  const MyApp({super.key, required this.theme});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(),
        ),
        BlocProvider(
          create: (context) => AuthenticationBloc(context.read<AuthenticationService>()),
        ),
        ...Config.blocProviders,
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Kermesse Corporation",
        // localizationsDelegates: Config.localizationsDelegates,
        initialRoute: '/',
        routes: getApplicationRoutes(),
        onGenerateRoute: (settings) {
          // if (settings.name == '/profile') {
          //   final String token = settings.arguments as String;
          //   return MaterialPageRoute(
          //     builder: (context) => ProfileScreen(token: token),
          //   );
          // }
          return unknownRoute(settings);
        },
        onUnknownRoute: unknownRoute,
        supportedLocales: const [
          Locale('en', ''),
          Locale('fr', ''),
        ],
        theme: theme,
        builder: (context, child) {
          return BlocListener<AuthenticationBloc, AuthenticationState>(
            listener: (context, state) {
              if (state is Unauthenticated) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            child: child,
          );
        },
        home: _buildHomeScreen(),
      ),
    );
  }

  Widget _buildHomeScreen() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return MainScreen(token: snapshot.data!.uid);
          } else {
            // Redirect to AdminLoginPage if on web, else to LoginPage
            // return kIsWeb ?  const AdminLoginPage() : const LoginPage();
            return const LoginPage();
          }
        }
        return const CircularProgressIndicator();
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
