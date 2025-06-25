import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  BottomNavigationBarItem _buildAnimatedNavItem(
      IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: AnimatedScale(
        scale: selectedIndex == index ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Icon(icon),
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onTap,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: [
            _buildAnimatedNavItem(Icons.home, "Home", 0),
            _buildAnimatedNavItem(Icons.person, "Profile", 1),
            _buildAnimatedNavItem(Icons.smart_toy, "Edu AI", 2),
          ],
        ),
      ),
    );
  }
}
