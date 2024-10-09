import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kermesse_flutter/models/stand.dart';

// Events
abstract class StandEvent extends Equatable {
  const StandEvent();

  @override
  List<Object> get props => [];
}

class CreateStand extends StandEvent {
  final String token;
  final int kermesseId;
  final String name;
  final String type;
  final String description;

  const CreateStand({
    required this.token,
    required this.kermesseId,
    required this.name,
    required this.type,
    required this.description,
  });

  @override
  List<Object> get props => [token, kermesseId, name, type, description];
}
