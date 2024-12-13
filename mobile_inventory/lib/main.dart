import 'package:flutter/material.dart';
import 'package:mobile_inventory/models/product_model.dart';
import 'package:mobile_inventory/pages/detail_page.dart';
import 'package:mobile_inventory/pages/home_page.dart';
import 'package:mobile_inventory/pages/login_page.dart';
import 'package:mobile_inventory/pages/register_page.dart';
import 'package:mobile_inventory/pages/splash_page.dart';
import 'package:mobile_inventory/pages/transaction_history_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAuth.instance.setLanguageCode('en');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lapor Book',
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/detail': (context) {
          final product = ModalRoute.of(context)?.settings.arguments as ProductModel?;
          if (product == null) {
            return Scaffold(
              appBar: AppBar(title: const Text("Error")),
              body: const Center(child: Text("Product data is missing!")),
            );
          }
          return DetailPage(product: product);
        },
        '/transaction-history': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Map<String, dynamic> && args['productId'] is int) {
            return TransactionHistoryPage(productId: args['productId']);
          } else {
            return Scaffold(
              appBar: AppBar(title: const Text("Error")),
              body: const Center(child: Text("Product ID is missing or invalid!")),
            );
          }
        },
      },
    );
  }
}
