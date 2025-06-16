import 'dart:convert';

class User {
  final String id;
  final String name;
  final String roll;
  final String email;
  final String phone;
  final String password;
  final String token;
  final String section;
  final String semester;

  User({
    required this.id,
    required this.name,
    required this.roll,
    required this.email,
    required this.phone,
    required this.password,
    required this.token,
    required this.section,
    required this.semester,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'roll': roll,
      'email': email,
      'phone': phone,
      'password': password,
      'token': token,
      'section': section,
      'semester': semester,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] ?? '',
      name: map['name'] ?? '',
      roll: map['roll'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      password: map['password'] ?? '',
      token: map['token'] ?? '',
      section: map['section'] ?? '',
      semester: map['semester'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));
}
