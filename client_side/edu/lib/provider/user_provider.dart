import 'package:edu/model/user.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(
    id: '',
    name: '',
    roll: '',
    email: '',
    phone: '',
    password: '',
    token: '',
    section: '',
    semester: '', // ✅ Add this line
  );

  User get user => _user;

  void setUser(String userJson) {
    _user = User.fromJson(userJson);
    notifyListeners();
  }

  void setUserFromModel(User userModel) {
    _user = userModel;
    notifyListeners();
  }
}
