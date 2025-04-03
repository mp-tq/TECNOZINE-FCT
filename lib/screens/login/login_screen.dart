import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_prueba_mil/widgets/animated_logo.dart';
import 'package:flutter_prueba_mil/screens/home/home_screen.dart';
import 'package:flutter_prueba_mil/services/auth_service.dart';
import 'package:flutter_prueba_mil/services/user_service.dart';
import 'package:logger/logger.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _controller;
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  bool _isLoading = false;
  bool _isPasswordVisible = false; // Nueva variable para controlar la visibilidad de la contraseña

  // Usamos Logger para registrar eventos y errores
  final Logger _logger = Logger();

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
    _usernameController.dispose();
    _passwordController.dispose();
    if (_controller.isAnimating) {
      _controller.stop();
    }
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_usernameController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email to reset password')),
      );
      return;
    }

    try {
      await _authService.resetPassword(_usernameController.text);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );

      // Usamos el Logger para registrar el error
      _logger.e('Error resetting password: $e');
    }
  }

  Future<void> _handleLoginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Obtener el usuario por correo electrónico
      final user = await _userService.getUserByEmail(_usernameController.text);

      if (user == null) {
        if (!mounted) return;  // Verificar que el widget está montado antes de usar BuildContext
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
        return;
      }

      // Validar la contraseña
      if (user['password'] != _passwordController.text) {
        if (!mounted) return;  // Verificar que el widget está montado antes de usar BuildContext
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid password')),
        );
        return;
      }

      // Login exitoso
      if (!mounted) return;  // Verificar que el widget está montado antes de usar BuildContext

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;  // Verificar que el widget está montado antes de usar BuildContext

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleLoginWithGoogle() async {
    try {
      await _authService.loginWithGoogle();

      if (!mounted) return;  // Verificar que el widget está montado antes de usar BuildContext

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;  // Verificar que el widget está montado antes de usar BuildContext

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: ${e.toString()}')),
      );

      // Usamos el Logger para registrar el error
      _logger.e('Google sign-in failed: $e');
    }
  }

  Future<void> _handleLoginWithFacebook() async {
    try {
      await _authService.loginWithFacebook();

      if (!mounted) return;  // Verificar que el widget está montado antes de usar BuildContext

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;  // Verificar que el widget está montado antes de usar BuildContext

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Facebook sign-in failed: ${e.toString()}')),
      );

      // Usamos el Logger para registrar el error
      _logger.e('Facebook sign-in failed: $e');
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
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.black87),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: const Icon(Icons.email, color: Color(0xFF00ACC1)),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,  // Cambiar la visibilidad de la contraseña
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: Colors.black87),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: const Icon(Icons.lock, color: Color(0xFF00ACC1)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: const Color(0xFF00ACC1),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible; // Alternar la visibilidad
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8.0),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _handleResetPassword,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Color(0xFF00ACC1)),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLoginWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16.0),
              SignInButton(Buttons.Google, onPressed: _handleLoginWithGoogle),
              const SizedBox(height: 16.0),
              SignInButton(Buttons.Facebook, onPressed: _handleLoginWithFacebook),
            ],
          ),
        ),
      ),
    );
  }
}

