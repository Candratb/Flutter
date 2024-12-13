import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/transaction_history_model.dart';
import '../config/db_helper.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductModel product;

  const ProductDetailPage({super.key, required this.product});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late Future<List<TransactionHistoryModel>> _transactionHistory;

  @override
  void initState() {
    super.initState();
    _transactionHistory = DbHelper().getTransactionHistory(widget.product.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView( // Membuat konten dapat di-scroll
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Menampilkan gambar produk
              widget.product.image != null
                  ? Image.memory(
                      widget.product.image!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.image, size: 100),
              const SizedBox(height: 16),
              Text(
                'Name: ${widget.product.name}',
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                'Description: ${widget.product.description}',
                style: const TextStyle(fontSize: 16),
              ),
               Text(
                'Category: ${widget.product.category}',
                style: const TextStyle(fontSize: 16),
               ),
              Text(
                'Price: ${widget.product.price}',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'Stock: ${widget.product.stock}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              // Menampilkan riwayat transaksi
              const Text(
                'Transaction History:',
                style: TextStyle(fontSize: 18),
              ),
              FutureBuilder<List<TransactionHistoryModel>>(
                future: _transactionHistory,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No transaction history available.');
                  } else {
                    final transactions = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(), // Non-scrollable karena dibungkus scroll utama
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return ListTile(
                          title: Text('${transaction.type} - ${transaction.quantity}'),
                          subtitle: Text('Date: ${transaction.date}'),
                        );
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              // Tombol untuk menambah riwayat transaksi
              ElevatedButton(
                onPressed: () {
                  // Tindakan untuk menambah riwayat transaksi
                },
                child: const Text('Add Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}