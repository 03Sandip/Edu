import 'package:flutter/material.dart';
import 'package:adu_admin/screens/fee_structure_page.dart' as fee_structure;
import 'package:adu_admin/screens/fess_page.dart' as fees;
import 'package:adu_admin/screens/home_page.dart';

class SideNavBar extends StatelessWidget {
  final String selectedItem;
  const SideNavBar({super.key, required this.selectedItem});

  static const String navHome = "Home";
  static const String navFees = "Fees";
  static const String navFeeStructure = "Fees Structure";

  void _navigate(BuildContext context, String item, Widget page) {
    if (item.toLowerCase() == selectedItem.toLowerCase()) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.school, color: Colors.white, size: 18),
                  ),
                  SizedBox(width: 10),
                  Text("Edu", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildMenuItem(context, Icons.home, navHome, const AdminDashboardPage()),
                  _buildMenuItem(context, Icons.currency_rupee, navFees, const fees.FeesPage()),
                  _buildMenuItem(context, Icons.account_balance_wallet, navFeeStructure, const fee_structure.FeeStructurePage()),
                  const Divider(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, Widget page) {
    final isSelected = selectedItem.trim().toLowerCase() == title.trim().toLowerCase();
    return Container(
      color: isSelected ? Colors.blue.shade100 : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, size: 20, color: isSelected ? Colors.blue : Colors.black87),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: isSelected ? Colors.blue : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () => _navigate(context, title, page),
      ),
    );
  }
}
