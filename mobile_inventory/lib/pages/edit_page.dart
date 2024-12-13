import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile_inventory/models/product_model.dart';
import 'package:image_picker/image_picker.dart';

import '../config/db_helper.dart';
import 'home_page.dart';

class EditPage extends StatefulWidget {
  final ProductModel product;
  const EditPage({super.key, required this.product});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController(); // TextField untuk kategori
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  Uint8List? _imageBase64;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.product.name;
    _descriptionController.text = widget.product.description;
    _categoryController.text = widget.product.category; // Inisialisasi kategori dari produk
    _priceController.text = widget.product.price.toString();
    _stockController.text = widget.product.stock.toString();

    if (widget.product.image != null) {
      _imageBase64 = widget.product.image!;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      setState(() {
        _imageBase64 = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                image: _imageBase64 != null
                    ? DecorationImage(
                        image: MemoryImage(_imageBase64!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _imageBase64 == null
                  ? const Center(
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 50,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Name',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Product Name',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Description',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Product Description',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Category',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Product Category',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Price',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Product Price',
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Stock',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _stockController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Product Stock',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              // Validasi input
              if (_categoryController.text.isEmpty ||
                  _priceController.text.isEmpty ||
                  _stockController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  backgroundColor: Colors.red,
                  content: Text('Please fill in all fields'),
                ));
                return;
              }

              final price = int.tryParse(_priceController.text);
              final stock = int.tryParse(_stockController.text);

              if (price == null || stock == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  backgroundColor: Colors.red,
                  content: Text('Invalid price or stock value'),
                ));
                return;
              }

              final product = ProductModel(
                id: widget.product.id,
                name: _nameController.text,
                description: _descriptionController.text,
                category: _categoryController.text, // Ambil nilai kategori dari TextField
                price: price,
                stock: stock,
                image: _imageBase64,
              );

              final response = await DbHelper().update(product);

              if (response > 0) {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.green,
                  content: Text('Product ${product.id} updated successfully'),
                ));

                // ignore: use_build_context_synchronously
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              } else {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.red,
                  content: Text('Failed to update product ${product.id}'),
                ));
              }
            },
            child: const Text('Update Product'),
          ),
        ],
      ),
    );
  }
}
