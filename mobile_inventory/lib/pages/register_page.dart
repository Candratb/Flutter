import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_inventory/components/styles.dart';
import 'package:mobile_inventory/components/validators.dart';
import 'package:mobile_inventory/components/input_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? nama;
  String? email;
  String? noHP;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _password = TextEditingController();

  void register() async {
  setState(() {
    _isLoading = true;
  });
  try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email!,
      password: _password.text,
    );

    await userCredential.user!.updateDisplayName(nama);

    print('User registered: ${userCredential.user!.uid}');

    Navigator.pushNamedAndRemoveUntil(
        context, '/login', ModalRoute.withName('/login'));
  } catch (e) {
    print('Registration error: $e');
    final snackbar = SnackBar(content: Text(e.toString()));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 80),
                      Text('Register', style: headerStyle(level: 1)),
                      const SizedBox(height: 10),
                      const Text(
                        'Create your profile to start your journey',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 50),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            InputLayout(
                              'Nama Lengkap',
                              TextFormField(
                                onChanged: (value) => setState(() {
                                  nama = value;
                                }),
                                validator: notEmptyValidator,
                                decoration:
                                    customInputDecoration("Masukkan nama lengkap"),
                              ),
                            ),
                            InputLayout(
                              'Email',
                              TextFormField(
                                onChanged: (value) => setState(() {
                                  email = value;
                                }),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email tidak boleh kosong';
                                  }
                                  final emailRegex = RegExp(
                                      r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                                  if (!emailRegex.hasMatch(value)) {
                                    return 'Format email tidak valid';
                                  }
                                  return null;
                                },
                                decoration:
                                    customInputDecoration("email@email.com"),
                              ),
                            ),
                            InputLayout(
                              'No. Handphone',
                              TextFormField(
                                onChanged: (value) => setState(() {
                                  noHP = value;
                                }),
                                validator: notEmptyValidator,
                                decoration:
                                    customInputDecoration("+62 80000000"),
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                            InputLayout(
                              'Password',
                              TextFormField(
                                controller: _password,
                                validator: notEmptyValidator,
                                obscureText: true,
                                decoration:
                                    customInputDecoration("Masukkan password"),
                              ),
                            ),
                            InputLayout(
                              'Konfirmasi Password',
                              TextFormField(
                                validator: (value) => passConfirmationValidator(
                                    value, _password),
                                obscureText: true,
                                decoration: customInputDecoration(
                                    "Masukkan kembali password"),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                style: buttonStyle,
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    register();
                                  }
                                },
                                child: Text('Register',
                                    style: headerStyle(level: 2)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
