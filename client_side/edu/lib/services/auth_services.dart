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
  // ✅ Sign up user
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
        headers: <String, String>{
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
                  MaterialPageRoute(builder: (_) => LoginPage()),
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

  // ✅ Sign in user
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
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      httpErrorHandle(
        response: res,
        context: context,
        onSuccess: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          userProvider.setUser(res.body);
          await prefs.setString('user', res.body);
          await prefs.setString('x-auth-token', jsonDecode(res.body)['token']);

          navigator.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => HomePage(
                name: jsonDecode(res.body)['name'],
                roll: jsonDecode(res.body)['roll'],
              ),
            ),
            (route) => false,
          );
        },
      );
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  /// ✅ Get user data
/// ✅ Get user data
void getUserData(BuildContext context) async {
  try {
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('x-auth-token');

    print('🔐 Token from storage: $token');

    if (token == null || token.isEmpty) {
      print('⚠️ No token found. User not logged in.');
      prefs.setString('x-auth-token', '');
      return;
    }

    // Step 1: Validate token
    var tokenRes = await http.post(
    Uri.parse('${Constants.uri}/api/tokenIsValid'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token,
      },
    );

    if (tokenRes.statusCode != 200) {
      print('❌ Token validation failed. Status: ${tokenRes.statusCode}');
      showSnackBar(context, 'Session expired. Please log in again.');
      return;
    }

    var response = jsonDecode(tokenRes.body);
    print('✅ Token validation response: $response');

    if (response == true) {
      // Step 2: Get user data
      http.Response userRes = await http.get(
        Uri.parse('${Constants.uri}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'x-auth-token': token,
        },
      );

      if (userRes.statusCode != 200) {
        print('❌ Failed to fetch user data. Status: ${userRes.statusCode}');
        print('🧾 Response body: ${userRes.body}');
        showSnackBar(context, 'Failed to get user data');
        return;
      }

      print('📦 User data: ${userRes.body}');
      userProvider.setUser(userRes.body);
    } else {
      print('❌ Invalid token');
      showSnackBar(context, 'Invalid token. Please login again.');
    }
  } catch (e) {
    print('🔥 Exception in getUserData: $e');
    showSnackBar(context, 'Exception: Failed to get user');
  }
}
  // ✅ Sign out user
  void signOutUser(BuildContext context) async {
    final navigator = Navigator.of(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('x-auth-token');
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }
}
