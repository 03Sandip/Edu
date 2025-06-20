import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../provider/user_provider.dart';
import '../utils/constants.dart';

class MarksheetPage extends StatefulWidget {
  const MarksheetPage({super.key});

  @override
  State<MarksheetPage> createState() => _MarksheetPageState();
}

class _MarksheetPageState extends State<MarksheetPage> {
  List<dynamic> marksheets = [];
  String? semester;
  String? section;
  String? roll;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserInfoAndFetchMarksheets();
  }

  Future<void> loadUserInfoAndFetchMarksheets() async {
    final prefs = await SharedPreferences.getInstance();
    semester = prefs.getString('semester');
    section = prefs.getString('section');
    roll = prefs.getString('roll');

    debugPrint("🟢 Semester: $semester, Section: $section, Roll: $roll");

    if (semester == null || section == null || roll == null) {
      final user = Provider.of<UserProvider>(context, listen: false).user;
      semester = user.semester;
      section = user.section;
      roll = user.roll;

      // Save to SharedPreferences
      await prefs.setString('semester', semester!);
      await prefs.setString('section', section!);
      await prefs.setString('roll', roll!);
      debugPrint("✅ Loaded from Provider and saved to SharedPreferences");
    }

    if (semester != null && section != null && roll != null) {
      await fetchMarksheets();
    } else {
      debugPrint("❌ Still missing user data.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User info missing. Please re-login.')),
      );
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchMarksheets() async {
    try {
      final uri = Uri.parse(
        '${Constants.uri}/api/marksheet/list?semester=$semester&section=${Uri.encodeComponent(section!)}',
      );
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final List<dynamic> allMarksheets = jsonDecode(res.body);
        final filtered = allMarksheets.where((m) => m['roll'].toString() == roll).toList();

        setState(() {
          marksheets = filtered;
          isLoading = false;
        });
      } else {
        debugPrint("❌ Failed to fetch marksheets. Status: ${res.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("❌ Error fetching marksheets: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> openFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch file')),
      );
    }
  }

  String formatDateTime(String dateTimeString) {
    try {
      final dt = DateTime.parse(dateTimeString);
      return '${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Marksheets')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : marksheets.isEmpty
                ? const Center(child: Text('No marksheets available.'))
                : ListView.builder(
                    itemCount: marksheets.length,
                    itemBuilder: (context, index) {
                      final m = marksheets[index];
                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                          title: Text('Marksheet - ${m['roll']}'),
                          subtitle: m['uploadedAt'] != null
                              ? Text('Uploaded: ${formatDateTime(m['uploadedAt'])}')
                              : const Text('Upload time not available'),
                          trailing: IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: () => openFile(m['fileUrl']),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
