class TransactionHistoryModel {
  final int? id;
  final int productId;
  final String type;
  final int quantity;
  final String date; 

  TransactionHistoryModel({
    this.id,
    required this.productId,
    required this.type,
    required this.quantity,
    required this.date,
  });

  factory TransactionHistoryModel.fromMap(Map<String, dynamic> map) {
    return TransactionHistoryModel(
      id: map['id'] as int?,
      productId: map['productId'] as int,
      type: map['type'] as String,
      quantity: map['quantity'] as int,
      date: map['date'] as String, 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'type': type,
      'quantity': quantity,
      'date': date,
    };
  }
}
