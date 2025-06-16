import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import

class StudentInfoCard extends StatelessWidget {
  final String name;
  final String roll;

  StudentInfoCard({
    required this.name,
    required this.roll,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, d MMMM').format(now); // e.g. Sunday, 16 June
    final formattedTime = DateFormat('hh:mm a').format(now); // e.g. 11:00 AM

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF198CFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT SIDE: Student Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  roll,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Container(height: 1, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  formattedDate,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedTime,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage('assets/images/profile.png'),
            backgroundColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
