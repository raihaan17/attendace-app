import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../services/auth_services.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key, this.authServices});

  final AuthServices? authServices;

  @override
  Widget build(BuildContext context) {
    final auth = authServices ?? AuthServices();
    return StreamBuilder<User?>(
      stream: auth.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Gagal memeriksa sesi akun: ${snapshot.error}'),
              ),
            ),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return LoginScreen(authServices: auth);
        }
        return HomeScreen(authServices: auth, user: user);
      },
    );
  }
}
