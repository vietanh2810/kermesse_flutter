import 'package:equatable/equatable.dart';

abstract class TokenTransferEvent extends Equatable {
  const TokenTransferEvent();

  @override
  List<Object> get props => [];
}

class SendTokensToChild extends TokenTransferEvent {
  final int studentId;
  final int amount;
  final String token;

  const SendTokensToChild({
    required this.studentId,
    required this.amount,
    required this.token,
  });

  @override
  List<Object> get props => [studentId, amount, token];
}
