import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../utils/constants.dart';

class StudentLibraryPage extends StatefulWidget {
  const StudentLibraryPage({super.key});

  @override
  State<StudentLibraryPage> createState() => _StudentLibraryPageState();
}

class _StudentLibraryPageState extends State<StudentLibraryPage> with TickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> books = [];
  List<dynamic> papers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchLibraryData();
  }

  Future<void> fetchLibraryData() async {
    final url = Uri.parse('${Constants.uri}/api/library');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final allItems = jsonDecode(response.body);
      setState(() {
        books = allItems.where((item) => item['type'] == 'Book').toList();
        papers = allItems.where((item) => item['type'] == 'Research Paper').toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load library data')),
      );
    }
  }

  Widget buildList(List<dynamic> items) {
    if (items.isEmpty) return const Text('No items found');

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final entry = items[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(entry['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(entry['description'] ?? ''),
            trailing: IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.deepPurple),
              onPressed: () {
                final pdfUrl = '${Constants.uri.replaceAll("/api", "")}${entry['fileUrl']}';
                // Use `url_launcher` to open in browser
                launchUrl(Uri.parse(pdfUrl));
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📖 Library'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.deepPurple,
          indicatorColor: Colors.deepPurple,
          tabs: const [
            Tab(text: 'Research Papers'),
            Tab(text: 'Books'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                buildList(papers),
                buildList(books),
              ],
            ),
    );
  }
}
