import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kermesse_flutter/services/kermesses/kermesses_bloc.dart';
import 'package:kermesse_flutter/services/logout/logout_bloc.dart';
import 'package:kermesse_flutter/services/signup/signup_bloc.dart';
import 'package:kermesse_flutter/services/stands/stands_bloc.dart';
import 'package:kermesse_flutter/services/token_transfer/token_transfer_bloc.dart';
import 'package:kermesse_flutter/services/transactions/transactions_bloc.dart';
import '../services/authentication_service.dart';
import '../services/login/login_bloc.dart';
import '../services/stocks/stocks_bloc.dart';
import '../services/user/user_bloc.dart';

class Config {
  static String baseUrl =
  Platform.isAndroid ? "http://10.0.2.2:3333/api/v1" : "http://localhost:3333/api/v1";

  // static List<LocalizationsDelegate> get localizationsDelegates => [
  //   AppLocalizations.delegate,
  //   GlobalMaterialLocalizations.delegate,
  //   GlobalWidgetsLocalizations.delegate,
  //   GlobalCupertinoLocalizations.delegate,
  // ];
  //
  // void configureFirebaseEmulators() {
  //   final host = Platform.isAndroid ? "https://hackaton-419810.ew.r.appspot.com" : "localhost:8080";
  //   FirebaseAuth.instance.useAuthEmulator(host, 9099);
  //   FirebaseFirestore.instance.useFirestoreEmulator(host, 8082);
  //   FirebaseStorage.instance.useStorageEmulator(host, 9199);
  //   FirebaseFunctions.instance.useFunctionsEmulator(host, 5002);
  // }

  static List<BlocProvider> get blocProviders => [
    BlocProvider<LoginBloc>(
      create: (context) => LoginBloc(context.read<AuthenticationService>()),
    ),
    BlocProvider<LogoutBloc>(
      create: (context) => LogoutBloc(context.read<AuthenticationService>()),
    ),
    BlocProvider<SignupBloc>(
      create: (context) => SignupBloc(context.read<AuthenticationService>()),
    ),
    BlocProvider<KermessesBloc>(
      create: (context) => KermessesBloc(),
    ),
    BlocProvider<UserBloc>(
      create: (context) => UserBloc(),
    ),
    BlocProvider<TransactionBloc>(
      create: (context) => TransactionBloc(),
    ),
    BlocProvider<TokenTransferBloc>(
        create: (context) => TokenTransferBloc(),
    ),
    BlocProvider<StandBloc>(
      create: (context) => StandBloc(),
    ),
    BlocProvider<StockBloc>(
      create: (context) => StockBloc(),
    ),
  ];
}