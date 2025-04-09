import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_prueba_mil/screens/splash/splash_screen.dart';
import 'package:flutter_prueba_mil/screens/login/login_screen.dart';
import 'package:flutter_prueba_mil/screens/home/home_screen.dart';
import 'package:flutter_prueba_mil/providers/user_provider.dart';
import 'package:flutter_prueba_mil/providers/theme_provider.dart'; 
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), 
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(), 
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
            },
            theme: themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
          );
        },
      ),
    );
  }
}
