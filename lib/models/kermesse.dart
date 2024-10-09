import 'package:kermesse_flutter/models/stand.dart';
import 'package:kermesse_flutter/models/user.dart';

import 'package:kermesse_flutter/models/stand.dart';
import 'package:kermesse_flutter/models/user.dart';

class Kermesse {
  final int id;
  final String name;
  final DateTime date;
  final String location;
  final String description;
  final List<Organizer>? organizers;
  final List<User>? participants;
  final List<Stand>? stands;
  final int tokensSold;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isParticipant;

  Kermesse({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    this.organizers,
    this.participants,
    this.stands,
    required this.tokensSold,
    this.createdAt,
    this.updatedAt,
    this.isParticipant,
  });
  factory Kermesse.fromJson(Map<String, dynamic> json) {
    return Kermesse(
      id: json['ID'],
      name: json['Name'],
      date: DateTime.parse(json['Date']),
      location: json['Location'],
      description: json['Description'],
      organizers: (json['Organizers'] as List<dynamic>)
          .map((i) => Organizer.fromJson(i as Map<String, dynamic>))
          .toList(),
      participants: (json['Participants'] as List<dynamic>)
          .map((i) => User.fromJson(i as Map<String, dynamic>))
          .toList(),
      stands: (json['Stands'] as List<dynamic>)
          .map((i) => Stand.fromJson(i as Map<String, dynamic>))
          .toList(),
      tokensSold: json['TokensSold'],
      createdAt: DateTime.parse(json['CreatedAt']),
      updatedAt: DateTime.parse(json['UpdatedAt']),
      isParticipant: json['is_participant'] ?? false,
    );
  }


  // String get formattedDate {
  //   return DateFormat('yyyy-MM-dd').format(date);
  // }

  Kermesse copyWith({
    int? id,
    String? name,
    DateTime? date,
    String? location,
    String? description,
    List<Organizer>? organizers,
    List<User>? participants,
    List<Stand>? stands,
    int? tokensSold,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isParticipant,
  }) {
    return Kermesse(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      location: location ?? this.location,
      description: description ?? this.description,
      organizers: organizers ?? this.organizers,
      participants: participants ?? this.participants,
      stands: stands ?? this.stands,
      tokensSold: tokensSold ?? this.tokensSold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isParticipant: isParticipant ?? this.isParticipant,
    );
  }

  // String get formattedDate {
  //   return DateFormat('yyyy-MM-dd').format(date);
  // }
}