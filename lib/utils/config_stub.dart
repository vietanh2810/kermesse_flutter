// import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/authentication/authentication_bloc.dart';
import '../services/authentication_service.dart';
import '../services/kermesses/kermesses_bloc.dart';
import '../services/login/login_bloc.dart';
import '../services/logout/logout_bloc.dart';
import '../services/signup/signup_bloc.dart';
import '../services/stands/stands_bloc.dart';
import '../services/stocks/stocks_bloc.dart';
import '../services/token_transfer/token_transfer_bloc.dart';
import '../services/transactions/transactions_bloc.dart';
import '../services/user/user_bloc.dart';
// import '../services/register/register_bloc.dart';
// import '../services/hackathons/hackathon_bloc.dart';

class Config {
  static String baseUrl = "https://kermesse-back-f202c182e090.herokuapp.com/api/v1";

  // static List<LocalizationsDelegate> get localizationsDelegates => [
  //   AppLocalizations.delegate,
  //   GlobalMaterialLocalizations.delegate,
  //   GlobalWidgetsLocalizations.delegate,
  //   GlobalCupertinoLocalizations.delegate,
  // ];

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