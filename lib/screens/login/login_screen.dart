import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:provider/provider.dart';
import 'package:flutter_prueba_mil/providers/user_provider.dart';
import 'package:flutter_prueba_mil/widgets/animated_logo.dart';
import 'package:flutter_prueba_mil/screens/home/home_screen.dart';
import 'package:flutter_prueba_mil/services/user_service.dart';
import 'package:logger/logger.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _controller;
  final UserService _userService = UserService();
  final Logger _logger = Logger();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final email = _emailController.text;
      final password = _passwordController.text;
      final user = await _userService.getUserByEmail(email);

      if (!mounted) return;

      if (user == null) {
        _showSnackbar('User not found');
        return;
      }

      final storedPassword = user['password'] as String?;
      if (storedPassword == null || storedPassword != password) {
        _showSnackbar('Invalid email or password');
        return;
      }

      userProvider.setUser(user['email'], user['name']);
      _navigateToHome();
    } catch (e) {
      _showSnackbar('Login failed: $e');
      _logger.e('Login failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF00ACC1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedLogo(controller: _controller),
              const SizedBox(height: 32.0),
              _buildValidatedTextField(_emailController, 'Email', Icons.email, false),
              const SizedBox(height: 16.0),
              _buildValidatedTextField(_passwordController, 'Password', Icons.lock, true),
              const SizedBox(height: 8.0),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFF00ACC1))),
                ),
              ),
              const SizedBox(height: 16.0),
              _buildLoginButton(),
              const SizedBox(height: 16.0),
              SignInButton(Buttons.Google, onPressed: () {}),
              const SizedBox(height: 16.0),
              SignInButton(Buttons.Facebook, onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValidatedTextField(TextEditingController controller, String label, IconData icon, bool isPassword) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        prefixIcon: Icon(icon, color: Color(0xFF00ACC1)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Color(0xFF00ACC1)),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $label';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1565C0),
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Login', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
