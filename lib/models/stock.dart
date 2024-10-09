class Stock {
  final int id;
  final int standId;
  final String itemName;
  final int quantity;
  final int tokenCost;

  Stock({
    required this.id,
    required this.standId,
    required this.itemName,
    required this.quantity,
    required this.tokenCost,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['ID'] as int,
      standId: json['StandID'] as int,
      itemName: json['ItemName'] as String,
      quantity: json['Quantity'] as int,
      tokenCost: json['TokenCost'] as int,
    );
  }
}