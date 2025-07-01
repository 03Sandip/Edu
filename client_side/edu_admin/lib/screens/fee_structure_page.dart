import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import '../widgets/nav_widgets.dart';
import '../utils/dropdown_constants.dart';

class FeeStructurePage extends StatefulWidget {
  const FeeStructurePage({super.key});

  @override
  State<FeeStructurePage> createState() => _FeeStructurePageState();
}

class _FeeStructurePageState extends State<FeeStructurePage> {
  String selectedSemester = DropdownConstants.semesters[0];
  final TextEditingController amountController = TextEditingController();
  bool isLoading = false;
  Map<String, dynamic> feeData = {};
  String? lastUpdated;

  @override
  void initState() {
    super.initState();
    fetchFeeStructure();
  }

  Future<void> fetchFeeStructure() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse('${Constants.uri}/feestructure'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          feeData.clear();
          for (var item in data) {
            feeData[item['semester']] = item['amount'];
          }
          amountController.text = feeData[selectedSemester]?.toString() ?? '';
        });
      } else {
        showSnackBar("Failed to fetch fee structure");
      }
    } catch (e) {
      print('Fetch error: $e');
      showSnackBar("Error fetching data");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateFeeStructure() async {
    final sem = selectedSemester;
    final amount = int.tryParse(amountController.text.trim());

    if (amount == null) {
      showSnackBar("Enter a valid amount");
      return;
    }

    try {
      final res = await http.post(
        Uri.parse('${Constants.uri}/feestructure'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'semester': sem, 'amount': amount}),
      );

      if (res.statusCode == 200) {
        showSnackBar('Fee updated for $sem');
        fetchFeeStructure();
        amountController.clear();
      } else {
        showSnackBar("Failed to update");
      }
    } catch (e) {
      print('Update error: $e');
      showSnackBar("Error updating fee");
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void handleEdit(String semester) {
    setState(() {
      selectedSemester = semester;
      amountController.text = feeData[semester]?.toString() ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideNavBar(selectedItem: "Fee Structure"),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.attach_money, size: 28, color: Colors.blueAccent),
                            SizedBox(width: 10),
                            Text("Manage Semester Fee Structure",
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Update Form
                        Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 20,
                              runSpacing: 12,
                              children: [
                                DropdownButton<String>(
                                  value: selectedSemester,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedSemester = value!;
                                      amountController.text =
                                          feeData[selectedSemester]?.toString() ?? '';
                                    });
                                  },
                                  items: DropdownConstants.semesters
                                      .map((sem) =>
                                          DropdownMenuItem(value: sem, child: Text(sem)))
                                      .toList(),
                                ),
                                SizedBox(
                                  width: 160,
                                  child: TextField(
                                    controller: amountController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: "Amount (₹)",
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: updateFeeStructure,
                                  icon: const Icon(Icons.save),
                                  label: const Text("Save"),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    backgroundColor: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                        const Divider(),
                        const SizedBox(height: 10),
                        const Text("Current Fee Structure",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),

                        feeData.isEmpty
                            ? const Text("No fee structure data available.")
                            : Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: feeData.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1, color: Colors.grey),
                                  itemBuilder: (context, index) {
                                    String sem = feeData.keys.elementAt(index);
                                    int amount = feeData[sem];

                                    return ListTile(
                                      leading: const Icon(Icons.school_outlined),
                                      title: Text(sem),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text("₹$amount",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 10),
                                          IconButton(
                                            onPressed: () => handleEdit(sem),
                                            icon: const Icon(Icons.edit,
                                                color: Colors.orange),
                                            tooltip: 'Edit',
                                          ),
                                        ],
                                      ),
                                      tileColor: sem == selectedSemester
                                          ? Colors.blue.shade50
                                          : null,
                                    );
                                  },
                                ),
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
