import 'package:edu/provider/user_provider.dart';
import 'package:edu/screens/home_page.dart';
import 'package:edu/screens/register_page.dart'; 
import 'package:edu/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:edu/screens/loggin_page.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    authService.getUserData(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return MaterialApp(
      title: 'Flutter Node Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Provider.of<UserProvider>(context).user.token.isEmpty
          ? const LoginPage()
          : HomePage(
              name: user.name,
              roll: user.roll,
            ),
      routes: {
        '/register': (context) => RegisterPage(), // ✅ Route registered here
      },
    );
  }
}
