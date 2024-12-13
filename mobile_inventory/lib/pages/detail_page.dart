import 'package:flutter/material.dart';
import 'package:mobile_inventory/config/db_helper.dart';
import 'package:mobile_inventory/models/product_model.dart';
import 'package:mobile_inventory/models/transaction_history_model.dart';
import 'package:mobile_inventory/pages/update_product_page.dart';

class DetailPage extends StatefulWidget {
  final ProductModel product;

  const DetailPage({super.key, required this.product});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<List<TransactionHistoryModel>> _transactionHistory;

Future<void> fetchTransactionHistory(int productId) async {
  try {
    final dbHelper = DbHelper();
    final transactions = await dbHelper.getTransactionHistory(productId);
    if (transactions.isEmpty) {
      print("No transactions found for productId: $productId");
    } else {
      print("Fetched ${transactions.length} transactions.");
    }
  } catch (e) {
    print("Error fetching transaction history: $e");
  }
}

  // Method untuk menghapus produk
  Future<void> _deleteProduct() async {
    final response = await DbHelper().delete(widget.product.id!);
    if (response > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete product')),
      );
    }
  }
  @override
void initState() {
  super.initState();
  if (widget.product.id != null) {
    _transactionHistory = DbHelper().getTransactionHistory(widget.product.id!);
  } else {
    // Tangani jika id produk kosong
    _transactionHistory = Future.value([]);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateProductPage(product: widget.product),
                ),
              ).then((_) => setState(() {})); // Refresh data setelah update
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteProduct,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: widget.product.image != null
                  ? Image.memory(
                      widget.product.image!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  : const Icon(
                      Icons.image,
                      size: 100,
                      color: Colors.grey,
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.product.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Description: \$${widget.product.description}'),
            Text('Category: \$${widget.product.category}'),
            Text('Price: \$${widget.product.price}'),
            Text('Stock: ${widget.product.stock}'),
            const SizedBox(height: 20),
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
          Navigator.pushNamed(
            context,
            '/transaction-history',
            arguments: {'productId': widget.product.id},
          );
        },
        child: const Text('Riwayat Transaksi'),
      ),

          ],
        ),
      ),
    );
  }
}
