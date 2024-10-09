import 'package:kermesse_flutter/models/stock.dart';

class Stand {
  final int id;
  final String name;
  final String type;
  final String description;
  final int kermesseId;
  final String? kermesse;  // Made nullable
  final int tokensSpent;
  final int pointsGiven;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Stock>? stock;  // Already nullable

  Stand({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.kermesseId,
    this.kermesse,  // Made optional
    required this.tokensSpent,
    required this.pointsGiven,
    required this.createdAt,
    required this.updatedAt,
    this.stock,
  });

  factory Stand.fromJson(Map<String, dynamic> json) {
    return Stand(
      id: json['ID'] as int,
      name: json['Name'] as String,
      type: json['Type'] as String,
      description: json['Description'] as String,
      kermesseId: json['KermesseID'] as int,
      // kermesse: json['Kermesse'] as String?, // Made nullable
      tokensSpent: json['TokensSpent'] as int,
      pointsGiven: json['PointsGiven'] as int,
      createdAt: DateTime.parse(json['CreatedAt']),
      updatedAt: DateTime.parse(json['UpdatedAt']),
      stock: json['Stock'] != null
          ? (json['Stock'] as List<dynamic>)
          .map((item) => Stock.fromJson(item as Map<String, dynamic>))
          .toList()
          : null,
    );
  }
}