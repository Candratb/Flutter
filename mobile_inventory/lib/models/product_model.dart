import 'dart:convert';
import 'dart:typed_data';

class ProductModel {
  final int? id;
  final String name;
  final String description;
  final String category; // Tambahkan kategori
  final int price;
  int stock;
  final Uint8List? image;

  ProductModel(
      {this.id,
      required this.name,
      required this.description,
      required this.category, // Wajib
      required this.price,
      required this.stock,
      this.image});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description':description,
      'category': category, // Tambahkan kategori
      'price': price,
      'stock': stock,
      'image': image,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
  return ProductModel(
    id: map['id'] as int?,
    name: map['name'] ?? '', // Berikan nilai default jika null
    description: map['description'] ?? '', // Berikan nilai default jika null
    category: map['category'] ?? '', // Berikan nilai default jika null
    price: map['price'] as int,
    stock: map['stock'] as int,
    image: map['image'] as Uint8List?,
  );
}

  String toJson() => json.encode(toMap());

  factory ProductModel.fromJson(String source) =>
      ProductModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
