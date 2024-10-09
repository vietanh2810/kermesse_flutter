class TokenTransaction {
  final int id;
  final int kermesseID;
  final int fromID;
  final String fromType;
  final int toID;
  final String toType;
  final int amount;
  final String type;
  final int? standID;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  TokenTransaction({
    required this.id,
    required this.kermesseID,
    required this.fromID,
    required this.fromType,
    required this.toID,
    required this.toType,
    required this.amount,
    required this.type,
    this.standID,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TokenTransaction.fromJson(Map<String, dynamic> json) {
    return TokenTransaction(
      id: json['ID'],
      kermesseID: json['KermesseID'],
      fromID: json['FromID'],
      fromType: json['FromType'],
      toID: json['ToID'],
      toType: json['ToType'],
      amount: json['Amount'],
      type: json['Type'],
      standID: json['StandID'],
      status: json['Status'],
      createdAt: DateTime.parse(json['CreatedAt']),
      updatedAt: DateTime.parse(json['UpdatedAt']),
    );
  }
}