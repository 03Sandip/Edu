import 'package:edu/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:edu/screens/UserDetails_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  void signOutUser(BuildContext context) {
    AuthService().signOutUser(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Profile"),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text("My Profile"),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserDetailsPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    const ListTile(
                      leading: Icon(Icons.notifications_none),
                      title: Text("Notification"),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                    const Divider(),
                    const ListTile(
                      leading: Icon(Icons.settings_outlined),
                      title: Text("Setting"),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                    const Divider(),
                    const ListTile(
                      leading: Icon(Icons.payment_outlined),
                      title: Text("Payment"),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                    const Divider(),
                  ],
                ),
              ),

              // Logout Button
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => signOutUser(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
