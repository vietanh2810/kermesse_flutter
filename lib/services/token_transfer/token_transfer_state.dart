import 'package:equatable/equatable.dart';

abstract class TokenTransferState extends Equatable {
  const TokenTransferState();

  @override
  List<Object> get props => [];
}

class TokenTransferInitial extends TokenTransferState {}

class TokenTransferLoading extends TokenTransferState {}

class TokenTransferSuccess extends TokenTransferState {}

class TokenTransferFailure extends TokenTransferState {
  final String error;

  const TokenTransferFailure(this.error);

  @override
  List<Object> get props => [error];
}