import 'package:sqflite/sqflite.dart';
import '../models/product_model.dart';
import '../models/transaction_history_model.dart';
import 'package:intl/intl.dart';

class DbHelper {
  Database? _database;

  // Membuat database dan tabel
  Future<void> _createDB(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE IF NOT EXISTS product(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT, 
        price INTEGER NOT NULL,
        stock INTEGER NOT NULL,
        image BLOB
      )
    ''');

    await db.execute(''' 
      CREATE TABLE IF NOT EXISTS transaction_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER NOT NULL,
        type TEXT NOT NULL, 
        quantity INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  // Fungsi untuk memformat tanggal
  String formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm');
    return formatter.format(dateTime);
  }

  // Migrasi database jika versi berubah
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Tambahkan kolom kategori jika belum ada
      await db.execute('ALTER TABLE product ADD COLUMN category TEXT');
    }
    if (oldVersion < 3) { 
      // Pastikan kolom description ada pada versi 3
      await db.execute('ALTER TABLE product ADD COLUMN description TEXT');
    }
  }

  // Inisialisasi database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = dbPath + filePath;
    return await openDatabase(
      path,
      version: 3, 
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // Mendapatkan instance database
  Future<Database> get getDB async {
    _database ??= await _initDB('inventory.db');
    return _database!;
  }

  // Fungsi untuk memvalidasi input sebelum insert
  Future<int> insert(ProductModel product) async {
    final db = await getDB;

    // Validasi input
    if (product.name.isEmpty || product.description.isEmpty || product.price < 0 || product.stock < 0) {
      throw Exception('Data tidak valid: Pastikan semua kolom diisi dengan benar');
    }

    try {
      return await db.insert('product', product.toMap());
    } catch (e) {
      throw Exception('Gagal menambahkan data: $e');
    }
  }

  // Fungsi untuk mendapatkan semua produk
  Future<List<ProductModel>> getProduct({int limit = 10, int offset = 0}) async {
    final db = await getDB;
    try {
      final List<Map<String, dynamic>> results = await db.query(
        'product',
        orderBy: 'id DESC',
        limit: limit,
        offset: offset,
      );
      return results.map((res) => ProductModel.fromMap(res)).toList();
    } catch (e) {
      throw Exception('Gagal mendapatkan data: $e');
    }
  }

  // Menambahkan riwayat transaksi
  Future<int> addTransactionHistory(TransactionHistoryModel transaction) async {
    final db = await getDB;

    // Menambahkan transaksi ke tabel riwayat
    return await db.insert('transaction_history', transaction.toMap());
  }

  // Ambil riwayat transaksi berdasarkan id produk
  Future<List<TransactionHistoryModel>> getTransactionHistory(int productId) async {
    final db = await getDB;

    final result = await db.query(
      'transaction_history',
      where: 'productId = ?',
      whereArgs: [productId],
    );

    return result.isNotEmpty
        ? result.map((e) => TransactionHistoryModel.fromMap(e)).toList()
        : [];
  }

  // Fungsi untuk memperbarui produk
  Future<int> update(ProductModel product) async {
    final db = await getDB;
    try {
      return await db.update(
        'product',
        product.toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );
    } catch (e) {
      throw Exception('Gagal memperbarui data: $e');
    }
  }

  // Fungsi untuk menghapus produk
  Future<int> delete(int productId) async {
    final db = await getDB;
    try {
      return await db.delete(
        'product',
        where: 'id = ?',
        whereArgs: [productId],
      );
    } catch (e) {
      throw Exception('Gagal menghapus data: $e');
    }
  }

  // Fungsi untuk menghapus riwayat transaksi
  Future<int> deleteHistory(int historyId) async {
    final db = await getDB;
    try {
      return await db.delete(
        'transaction_history',
        where: 'id = ?',
        whereArgs: [historyId],
      );
    } catch (e) {
      throw Exception('Gagal menghapus riwayat: $e');
    }
  }

  // Menambahkan transaksi ke database
  Future<int> insertTransaction(TransactionHistoryModel transaction) async {
    final db = await getDB;
    return await db.insert('transaction_history', transaction.toMap());
  }

  // Memperbarui produk di database
  Future<void> updateProduct(ProductModel product) async {
    final db = await getDB;
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }
  Future<ProductModel?> getProductById(int productId) async {
    final db = await getDB;
    final result = await db.query(
      'product',
      where: 'id = ?',
      whereArgs: [productId],
    );
    if (result.isNotEmpty) {
      return ProductModel.fromMap(result.first);
    }
    return null;
  }

}