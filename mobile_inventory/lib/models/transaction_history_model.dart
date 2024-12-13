class TransactionHistoryModel {
  final int productId;
  final String type; // "Masuk" atau "Keluar"
  final int quantity;
  final String date; // Tanggal transaksi

  TransactionHistoryModel({
    required this.productId,
    required this.type,
    required this.quantity,
    required this.date,
  });

  // Konversi dari Map ke model
  factory TransactionHistoryModel.fromMap(Map<String, dynamic> map) {
    return TransactionHistoryModel(
      productId: map['productId'],
      type: map['type'],
      quantity: map['quantity'],
      date: map['date'],
    );
  }

  // Konversi dari model ke Map
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'type': type,
      'quantity': quantity,
      'date': date,
    };
  }
}
