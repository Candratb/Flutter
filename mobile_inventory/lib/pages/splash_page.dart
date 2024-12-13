import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkUserLogin();
  }

  void _checkUserLogin() async {
  User? user = _auth.currentUser;

    // Tambahkan delay untuk menampilkan splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return; // Pastikan widget masih aktif sebelum navigasi

    if (user != null) {
      // Jika user sudah login, arahkan ke home
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Jika user belum login, arahkan ke login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Selamat datang di Aplikasi Laporan',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
