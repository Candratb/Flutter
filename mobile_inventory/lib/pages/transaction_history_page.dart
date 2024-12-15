import 'package:flutter/material.dart';
import 'package:mobile_inventory/config/db_helper.dart';
import 'package:mobile_inventory/models/transaction_history_model.dart';
import 'package:intl/intl.dart';

class TransactionHistoryPage extends StatefulWidget {
  final int productId;

  const TransactionHistoryPage({super.key, required this.productId});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  late Future<List<TransactionHistoryModel>> _transactionHistory;
  final DbHelper _dbHelper = DbHelper();

  @override
  void initState() {
    super.initState();
    _refreshTransactionHistory();
  }

  void _refreshTransactionHistory() {
    setState(() {
      _transactionHistory = _dbHelper.getTransactionHistory(widget.productId);
    });
  }

  Future<void> _addTransaction() async {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    String? type;
    int? quantity;
    DateTime? date;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Transaksi'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: type,
                  items: const [
                    DropdownMenuItem(value: 'Masuk', child: Text('Masuk')),
                    DropdownMenuItem(value: 'Keluar', child: Text('Keluar')),
                  ],
                  onChanged: (value) {
                    type = value;
                  },
                  decoration: const InputDecoration(labelText: 'Jenis Transaksi'),
                  validator: (value) => value == null ? 'Pilih jenis transaksi' : null,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Jumlah'),
                  onChanged: (value) {
                    quantity = int.tryParse(value);
                  },
                  validator: (value) =>
                      (value == null || int.tryParse(value) == null || int.parse(value) <= 0)
                          ? 'Masukkan jumlah yang valid'
                          : null,
                ),
                TextButton(
                  onPressed: () async {
                    final selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (selectedDate != null) {
                      setState(() {
                        date = selectedDate;
                      });
                    }
                  },
                  child: const Text('Pilih Tanggal'),
                ),
                if (date != null) Text(DateFormat('dd MMM yyyy').format(date!)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
            if (_formKey.currentState!.validate() && date != null) {
              Navigator.pop(context);
                  // Simpan transaksi baru ke database
                  final transaction = TransactionHistoryModel(
                    productId: widget.productId,
                    type: type!,
                    quantity: quantity!,
                    date: DateFormat('yyyy-MM-dd').format(date!), 
                  );

                  await _dbHelper.addTransactionHistory(transaction);

                  if (type == 'Masuk') {
                    await _dbHelper.updateStock(widget.productId, quantity!);
                  } else if (type == 'Keluar') {
                    await _dbHelper.updateStock(widget.productId, -quantity!);
                  }

                  _refreshTransactionHistory();
                }
              },

              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
      ),
      body: FutureBuilder<List<TransactionHistoryModel>>(
        future: _transactionHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(transaction.date));

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
      floatingActionButton: FloatingActionButton(
        onPressed: _addTransaction,
        child: const Icon(Icons.add),
      ),
    );
  }
}
