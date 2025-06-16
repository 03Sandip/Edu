import 'package:edu/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'loggin_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController rollController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService authService = AuthService();

  String? selectedSection;
  String? selectedSemester;

  bool _obscureText = true;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (selectedSection == null || selectedSemester == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select section and semester')),
        );
        return;
      }

      authService.signUpUser(
        context: context,
        name: nameController.text.trim(),
        roll: rollController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text.trim(),
        section: selectedSection!,
        semester: selectedSemester!,
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    rollController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset('assets/images/auth.jpg', height: 200),
                const SizedBox(height: 20),
                const Text(
                  "Register Yourself",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Please fill the details and create account",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: "Full name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        validator: (value) => value!.isEmpty ? "Enter full name" : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: rollController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Roll Number",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        validator: (value) => value!.isEmpty ? "Enter roll number" : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        validator: (value) => value!.isEmpty ? "Enter email" : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: "Phone",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        validator: (value) => value!.isEmpty ? "Enter phone number" : null,
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: "Select Section",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        value: selectedSection,
                        items: ["CSE 1", "CSE 2", "ECE", "MECH"]
                            .map((section) => DropdownMenuItem(
                                  value: section,
                                  child: Text(section),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => selectedSection = value),
                        validator: (value) =>
                            value == null ? "Select section" : null,
                      ),
                      const SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: "Select Semester",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        value: selectedSemester,
                        items: ["1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th"]
                            .map((sem) => DropdownMenuItem(
                                  value: sem,
                                  child: Text(sem),
                                ))
                            .toList(),
                        onChanged: (value) => setState(() => selectedSemester = value),
                        validator: (value) =>
                            value == null ? "Select semester" : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: passwordController,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          hintText: "Password",
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        validator: (value) =>
                            value!.length < 6 ? "Min 6 characters" : null,
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: const Color.fromARGB(255, 16, 23, 234),
                          ),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => LoginPage()),
                          );
                        },
                        child: const Text("Already have an account?  Log In"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
