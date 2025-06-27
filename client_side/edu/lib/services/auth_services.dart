import 'dart:convert';
import 'package:edu/provider/user_provider.dart';
import 'package:edu/screens/loggin_page.dart';
import 'package:edu/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:edu/model/user.dart' as model;
import 'package:edu/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:edu/screens/home_page.dart';
import 'package:edu/widget/success_popup.dart';

class AuthService {
  // ✅ Register
  void signUpUser({
    required BuildContext context,
    required String name,
    required String roll,
    required String email,
    required String phone,
    required String password,
    required String section,
    required String semester,
  }) async {
    try {
      model.User user = model.User(
        id: '',
        name: name,
        roll: roll,
        email: email,
        phone: phone,
        password: password,
        token: '',
        section: section,
        semester: semester,
      );

      http.Response res = await http.post(
        Uri.parse('${Constants.uri}/api/signup'),
        body: user.toJson(),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => SuccessPopup(
              message: 'Registration Successful!',
              onDone: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
            ),
          );
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // ✅ Login
  void signInUser({
    required BuildContext context,
    required String roll,
    required String password,
  }) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);
      final navigator = Navigator.of(context);

      http.Response res = await http.post(
        Uri.parse('${Constants.uri}/api/signin'),
        body: jsonEncode({'roll': roll, 'password': password}),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          final data = jsonDecode(res.body);

          userProvider.setUser(res.body);
          await prefs.setString('user', res.body);
          await prefs.setString('x-auth-token', data['token']);
          await prefs.setString('name', data['name']);
          await prefs.setString('roll', data['roll']);
          await prefs.setString('semester', data['semester']);
          await prefs.setString('section', data['section']);

          navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
          );
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  // ✅ Token Validator for persistent login
  Future<bool> validateToken(String token) async {
    try {
      final res = await http.post(
        Uri.parse('${Constants.uri}/api/tokenIsValid'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body) == true;
      }
    } catch (e) {
      debugPrint('Token validation error: $e');
    }
    return false;
  }

  // ✅ Get User Data (for persistent login)
  Future<void> getUserData(BuildContext context) async {
    try {
      var userProvider = Provider.of<UserProvider>(context, listen: false);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('x-auth-token');

      if (token == null || token.isEmpty) {
        await prefs.setString('x-auth-token', '');
        return;
      }

      bool isValid = await validateToken(token);
      if (!isValid) return;

      http.Response userRes = await http.get(
        Uri.parse('${Constants.uri}/api/'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      if (userRes.statusCode == 200) {
        userProvider.setUser(userRes.body);
        final data = jsonDecode(userRes.body);

        await prefs.setString('name', data['name']);
        await prefs.setString('roll', data['roll']);
        await prefs.setString('semester', data['semester']);
        await prefs.setString('section', data['section']);
        await prefs.setString('user', userRes.body);
      } else {
        debugPrint("❌ Failed to fetch user data: ${userRes.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error getting user data: $e");
    }
  }

  // ✅ Logout
  void signOutUser(BuildContext context) async {
    final navigator = Navigator.of(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }
}
