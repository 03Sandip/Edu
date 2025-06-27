import 'package:edu/services/auth_services.dart';
import 'package:edu/widget/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:edu/screens/UserDetails_page.dart';
import 'package:edu/screens/eduai_page.dart';
import 'package:edu/screens/home_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 1;

  void signOutUser(BuildContext context) {
    AuthService().signOutUser(context);
  }

  void _onBottomNavTap(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(), // ✅ Removed name & roll
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EduAIPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Main List
              Expanded(
                child: ListView(
                  children: [
                    buildProfileTile(
                      context,
                      icon: Icons.person_outline,
                      title: "My Profile",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const UserDetailsPage()),
                        );
                      },
                    ),
                    buildProfileTile(
                      context,
                      icon: Icons.settings_outlined,
                      title: "Setting",
                    ),
                    buildProfileTile(
                      context,
                      icon: Icons.payment_outlined,
                      title: "Payment",
                    ),
                    buildProfileTile(
                      context,
                      icon: Icons.man,
                      title: "About Us",
                    ),
                  ],
                ),
                
              ),

              // Logout Button
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

      // Bottom Navigation Bar
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget buildProfileTile(BuildContext context,
      {required IconData icon, required String title, VoidCallback? onTap}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Icon(icon, color: Colors.blue.shade700, size: 28),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
