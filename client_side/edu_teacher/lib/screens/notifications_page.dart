import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/constants.dart';
import '../../widgets/nav_widgets.dart';
import '../../utils/dropdown_constants.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _customTargetValue = TextEditingController();

  String targetType = 'all';
  bool isLoading = false;
  String? editingId;
  List<dynamic> notifications = [];

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final res = await http.get(Uri.parse('${Constants.uri}/notifications'));
      if (res.statusCode == 200) {
        setState(() => notifications = jsonDecode(res.body));
      }
    } catch (e) {
      showSnackBar("Error loading notifications");
    }
  }

  Future<void> sendNotification() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    final targetValue = _customTargetValue.text.trim();

    if (title.isEmpty || message.isEmpty) {
      showSnackBar("Title and message cannot be empty");
      return;
    }

    Map<String, dynamic> body = {
      'title': title,
      'message': message,
    };

    if (targetType == 'semester') {
      body['targetSemester'] = targetValue;
    } else if (targetType == 'section') {
      body['targetSection'] = targetValue;
    } else if (targetType == 'roll') {
      body['targetUserId'] = targetValue;
    }

    setState(() => isLoading = true);
    try {
      final uri = editingId != null
          ? Uri.parse('${Constants.uri}/notifications/$editingId')
          : Uri.parse('${Constants.uri}/notifications');

      final res = await (editingId != null
          ? http.put(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body))
          : http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body)));

      if (res.statusCode == 200 || res.statusCode == 201) {
        showSnackBar(editingId != null ? "Notification updated!" : "Notification sent!");
        _titleController.clear();
        _messageController.clear();
        _customTargetValue.clear();
        setState(() {
          targetType = 'all';
          editingId = null;
        });
        fetchNotifications();
      } else {
        showSnackBar("Failed to send notification");
      }
    } catch (e) {
      showSnackBar("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      final res = await http.delete(Uri.parse('${Constants.uri}/notifications/$id'));
      if (res.statusCode == 200) {
        showSnackBar("Deleted successfully");
        fetchNotifications();
      } else {
        showSnackBar("Failed to delete");
      }
    } catch (e) {
      showSnackBar("Error: $e");
    }
  }

  void showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SideNavBar(selectedItem: 'Notifications'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Send Notification", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: "Title", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _messageController,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: "Message", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: targetType,
                    decoration: const InputDecoration(labelText: "Target Audience", border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Students')),
                      DropdownMenuItem(value: 'semester', child: Text('By Semester')),
                      DropdownMenuItem(value: 'section', child: Text('By Section')),
                      DropdownMenuItem(value: 'roll', child: Text('By Roll Number')),
                    ],
                    onChanged: (value) {
                      setState(() => targetType = value!);
                    },
                  ),
                  if (targetType == 'semester')
                    DropdownButtonFormField<String>(
                      value: DropdownConstants.semesters.contains(_customTargetValue.text) ? _customTargetValue.text : null,
                      items: DropdownConstants.semesters
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (value) => _customTargetValue.text = value!,
                      decoration: const InputDecoration(labelText: 'Select Semester', border: OutlineInputBorder()),
                    ),
                  if (targetType == 'section')
                    DropdownButtonFormField<String>(
                      value: DropdownConstants.sections.contains(_customTargetValue.text) ? _customTargetValue.text : null,
                      items: DropdownConstants.sections
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (value) => _customTargetValue.text = value!,
                      decoration: const InputDecoration(labelText: 'Select Section', border: OutlineInputBorder()),
                    ),
                  if (targetType == 'roll')
                    TextField(
                      controller: _customTargetValue,
                      decoration: const InputDecoration(labelText: "Enter Roll Number", border: OutlineInputBorder()),
                    ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : sendNotification,
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Send", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.deepPurple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text("All Notifications", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      final timestamp = DateTime.tryParse(item['createdAt'] ?? '')?.toLocal();
                      final formattedTime = timestamp != null
                          ? '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}'
                          : '';
                      return Card(
                        child: ListTile(
                          title: Text(item['title'] ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['message'] ?? ''),
                              if (formattedTime.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text("Sent: $formattedTime", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.orange),
                                onPressed: () {
                                  setState(() {
                                    editingId = item['_id'];
                                    _titleController.text = item['title'];
                                    _messageController.text = item['message'];
                                    if (item['targetSemester'] != null) {
                                      targetType = 'semester';
                                      _customTargetValue.text = item['targetSemester'];
                                    } else if (item['targetSection'] != null) {
                                      targetType = 'section';
                                      _customTargetValue.text = item['targetSection'];
                                    } else if (item['targetUserId'] != null) {
                                      targetType = 'roll';
                                      _customTargetValue.text = item['targetUserId'];
                                    } else {
                                      targetType = 'all';
                                      _customTargetValue.clear();
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteNotification(item['_id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


