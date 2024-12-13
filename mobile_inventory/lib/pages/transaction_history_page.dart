import 'package:flutter/material.dart';
import 'package:mobile_inventory/config/db_helper.dart';
import 'package:mobile_inventory/models/transaction_history_model.dart';
import 'package:intl/intl.dart'; 

class TransactionHistoryPage extends StatelessWidget {
  final int productId;

  const TransactionHistoryPage({Key? key, required this.productId}) : super(key: key);

  Future<List<TransactionHistoryModel>> fetchTransactionHistory(int productId) async {
    final dbHelper = DbHelper();
    try {
      return await dbHelper.getTransactionHistory(productId);
    } catch (e) {
      throw Exception("Gagal memuat riwayat transaksi: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
      ),
      body: FutureBuilder<List<TransactionHistoryModel>>(
        future: fetchTransactionHistory(productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Tidak ada riwayat transaksi.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
          } else {
            final transactions = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(transaction.date as DateTime);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      '${transaction.type} - ${transaction.quantity}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Tanggal: $formattedDate'),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
