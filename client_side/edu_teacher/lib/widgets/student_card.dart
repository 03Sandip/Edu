// import 'package:flutter/material.dart';
// import '../screens/student_attendance_details.dart';

// class StudentCard extends StatelessWidget {
//   final String name;
//   final String roll;
//   final String selectedStatus;
//   final Function(String roll, String status) onSelect;

//   const StudentCard({
//     Key? key,
//     required this.name,
//     required this.roll,
//     required this.selectedStatus,
//     required this.onSelect,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//         child: Row(
//           children: [
//             const CircleAvatar(
//               backgroundColor: Colors.blueAccent,
//               child: Icon(Icons.person, color: Colors.white),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                   Text('Roll: $roll', style: const TextStyle(color: Colors.black54)),
//                 ],
//               ),
//             ),
//             Row(
//               children: [
//                 ChoiceChip(
//                   label: const Text("Present"),
//                   selected: selectedStatus == "Present",
//                   selectedColor: Colors.green[300],
//                   onSelected: (_) => onSelect(roll, "Present"),
//                 ),
//                 const SizedBox(width: 8),
//                 ChoiceChip(
//                   label: const Text("Absent"),
//                   selected: selectedStatus == "Absent",
//                   selectedColor: Colors.red[300],
//                   onSelected: (_) => onSelect(roll, "Absent"),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => StudentAttendanceDetailsPage(roll: roll, name: name),
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.grey[200],
//                     foregroundColor: Colors.black,
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                   ),
//                   child: const Text("Details"),
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
