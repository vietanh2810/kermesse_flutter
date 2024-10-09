import 'package:equatable/equatable.dart';

abstract class KermessesEvent extends Equatable {
  const KermessesEvent();

  @override
  List<Object> get props => [];
}

class FetchKermesses extends KermessesEvent {
  final String token;

  const FetchKermesses(this.token);

  @override
  List<Object> get props => [token];
}

class ParticipateInKermesse extends KermessesEvent {
  final String token;
  final String kermesseId;

  const ParticipateInKermesse({required this.token, required this.kermesseId});

  @override
  List<Object> get props => [token, kermesseId];
}

class CreateKermesse extends KermessesEvent {
  final String token;
  final Map<String, dynamic> kermesseData;

  const CreateKermesse({required this.token, required this.kermesseData});

  @override
  List<Object> get props => [token, kermesseData];
}

class PurchaseTokens extends KermessesEvent {
  final String token;
  final String kermesseId;
  final int amount;
  final String paymentMethodId;  // Changed from stripeToken to paymentMethodId

  const PurchaseTokens({
    required this.token,
    required this.kermesseId,
    required this.amount,
    required this.paymentMethodId,  // Updated this line
  });

  @override
  List<Object> get props => [token, kermesseId, amount, paymentMethodId];
}