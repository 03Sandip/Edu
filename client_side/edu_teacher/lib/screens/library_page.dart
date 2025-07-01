import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/nav_widgets.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String description = '';
  String type = 'Book';
  html.File? file;
  bool isLoading = false;
  bool isEditing = false;
  String? editingId;

  List<dynamic> libraryItems = [];

  final purple = Colors.deepPurple;

  @override
  void initState() {
    super.initState();
    fetchLibraryItems();
  }

  void pickFile() {
    final input = html.FileUploadInputElement()..accept = '.pdf';
    input.click();
    input.onChange.listen((event) {
      if (input.files != null && input.files!.isNotEmpty) {
        setState(() => file = input.files!.first);
      }
    });
  }

  Future<void> uploadFile() async {
    if (!_formKey.currentState!.validate()) return;
    if (!isEditing && file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📎 Please select a PDF file')),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() => isLoading = true);

    if (isEditing) {
      // ✅ Update entry
      final response = await html.HttpRequest.request(
        '${Constants.uri}/library/$editingId',
        method: 'PUT',
        requestHeaders: {'Content-Type': 'application/json'},
        sendData: jsonEncode({
          'title': title,
          'description': description,
          'type': type.toLowerCase(),
        }),
      );

      if (response.status == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Updated successfully')),
        );
        resetForm();
        fetchLibraryItems();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Update failed: ${response.responseText}')),
        );
      }

    } else {
      // ✅ Upload new
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file!);
      await reader.onLoad.first;

      final formData = html.FormData();
      formData.appendBlob('file', file!, file!.name);
      formData.append('title', title);
      formData.append('description', description);
      formData.append('type', type.toLowerCase());

      final request = html.HttpRequest();
      request.open('POST', '${Constants.uri}/library');
      request.send(formData);

      await request.onLoadEnd.first;

      if (request.status == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Upload successful')),
        );
        resetForm();
        fetchLibraryItems();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Upload failed: ${request.responseText}')),
        );
      }
    }

    setState(() => isLoading = false);
  }

  void resetForm() {
    setState(() {
      _formKey.currentState?.reset();
      file = null;
      title = '';
      description = '';
      type = 'Book';
      isEditing = false;
      editingId = null;
    });
  }

  Future<void> fetchLibraryItems() async {
    final response = await html.HttpRequest.request('${Constants.uri}/library');
    if (response.status == 200) {
      setState(() => libraryItems = jsonDecode(response.responseText!));
    }
  }

  Future<void> deleteItem(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Confirmation'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      final response = await html.HttpRequest.request(
        '${Constants.uri}/library/$id',
        method: 'DELETE',
      );
      if (response.status == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🗑️ Deleted successfully')),
        );
        fetchLibraryItems();
      }
    }
  }

  void populateFormForEdit(Map item) {
    setState(() {
      title = item['title'];
      description = item['description'] ?? '';
      type = item['type'] == 'paper' ? 'Research Paper' : 'Book';
      isEditing = true;
      editingId = item['_id'];
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const SideNavBar(selectedItem: "Library"),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: const Text('📚 Library'),
                backgroundColor: purple,
                foregroundColor: Colors.white,
                elevation: 2,
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Form
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEditing ? "✏️ Edit Library Item" : "📤 Upload Library Item",
                                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: purple),
                              ),
                              const SizedBox(height: 30),

                              TextFormField(
                                initialValue: title,
                                decoration: InputDecoration(
                                  labelText: 'Title',
                                  border: const OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: purple),
                                  ),
                                ),
                                validator: (val) => val == null || val.isEmpty ? 'Enter title' : null,
                                onSaved: (val) => title = val ?? '',
                              ),
                              const SizedBox(height: 20),

                              TextFormField(
                                initialValue: description,
                                decoration: InputDecoration(
                                  labelText: 'Description',
                                  border: const OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: purple),
                                  ),
                                ),
                                maxLines: 3,
                                onSaved: (val) => description = val ?? '',
                              ),
                              const SizedBox(height: 20),

                              DropdownButtonFormField<String>(
                                value: type,
                                decoration: InputDecoration(
                                  labelText: 'Type',
                                  border: const OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: purple),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'Book', child: Text('Book')),
                                  DropdownMenuItem(value: 'Research Paper', child: Text('Research Paper')),
                                ],
                                onChanged: (val) => setState(() => type = val ?? 'Book'),
                              ),
                              const SizedBox(height: 20),
                              if (!isEditing) ...[
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: pickFile,
                                      icon: const Icon(Icons.attach_file),
                                      label: const Text('Choose File'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: purple,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        file?.name ?? 'No file selected',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontStyle: FontStyle.italic),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                              ],
                              Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: isLoading ? null : uploadFile,
                                    icon: Icon(isEditing ? Icons.save : Icons.cloud_upload),
                                    label: Text(isLoading
                                        ? (isEditing ? 'Saving...' : 'Uploading...')
                                        : (isEditing ? 'Save Changes' : 'Upload')),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: purple,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  if (isEditing)
                                    TextButton(
                                      onPressed: resetForm,
                                      child: const Text('Cancel'),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                        /// Uploaded Items List
                        const Divider(thickness: 1),
                        const Text("📁 Uploaded Items", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: libraryItems.length,
                          itemBuilder: (_, i) {
                            final item = libraryItems[i];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item['title']),
                              subtitle: Text(item['type']),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.deepPurple),
                                    onPressed: () => populateFormForEdit(item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => deleteItem(item['_id']),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
