import 'package:flutter/material.dart';
import 'package:flutter_prueba_mil/providers/user_provider.dart';
import 'package:flutter_prueba_mil/services/user_service.dart';
import 'package:flutter_prueba_mil/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginController {
  static final UserService _userService = UserService();

  static Future<void> handleLogin({
    required BuildContext context,
    required String email,
    required String password,
    required UserProvider userProvider,
  }) async {
    try {
      final user = await _userService.getUserByEmail(email);

      if (user == null) {
        if (!context.mounted) return;
        _showSnackbar(context, 'User not found');
        return;
      }

      final storedPassword = user['password'] as String?;
      if (storedPassword == null || storedPassword != password) {
        if (!context.mounted) return;
        _showSnackbar(context, 'Invalid email or password');
        return;
      }

      userProvider.setUser(user['email'], user['name']);
      if (!context.mounted) return;
      _navigateToHome(context);
    } catch (e) {
      if (!context.mounted) return;
      _showSnackbar(context, 'Login failed: $e');
    }
  }

  static Future<User?> handleGoogleLogin() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in was canceled');
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      throw Exception('Google login failed: $e');
    }
  }

  static void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  static void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }
}