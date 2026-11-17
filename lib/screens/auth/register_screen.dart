import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_services.dart';
import '../../utils/app_alert.dart';
import 'widgets/auth_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.authServices});

  final AuthServices? authServices;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  late final AuthServices _auth;
  bool _isLoading = false;
  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    _auth = widget.authServices ?? AuthServices();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmation = _confirmationController.text;
    if (email.isEmpty) {
      _showMessage('Email wajib diisi.');
      return;
    }
    if (password.length < 6) {
      _showMessage('Kata sandi minimal 6 karakter.');
      return;
    }
    if (password != confirmation) {
      _showMessage('Konfirmasi kata sandi tidak cocok.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _auth.registerWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (mounted) Navigator.of(context).pop();
    } on FirebaseAuthException catch (error) {
      _showMessage('Gagal mendaftar: ${error.message}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    showErrorAlert(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Buat akun',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                AuthTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _passwordController,
                  label: 'Kata sandi',
                  isPassword: true,
                  obscureText: _hidePassword,
                  onToggleVisibility: () {
                    setState(() => _hidePassword = !_hidePassword);
                  },
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _confirmationController,
                  label: 'Konfirmasi kata sandi',
                  isPassword: true,
                  obscureText: _hidePassword,
                  onToggleVisibility: () {
                    setState(() => _hidePassword = !_hidePassword);
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Daftar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
