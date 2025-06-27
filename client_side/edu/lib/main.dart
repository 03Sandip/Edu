import 'package:edu/provider/user_provider.dart';
import 'package:edu/screens/home_page.dart';
import 'package:edu/screens/loggin_page.dart';
import 'package:edu/screens/register_page.dart';
import 'package:edu/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService authService = AuthService();
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('x-auth-token') ?? '';

    if (token.isNotEmpty) {
      bool isValid = await authService.validateToken(token);
      if (isValid) {
        // ✅ await is necessary to ensure user data is loaded before showing HomePage
       await authService.getUserData(context);
        setState(() => _isLoggedIn = true);
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edu App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _isLoading
          ? const SplashScreen()
          : _isLoggedIn
              ? const HomePage()
              : const LoginPage(),
      routes: {
        '/register': (context) => const RegisterPage(),
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
