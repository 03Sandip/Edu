import 'package:flutter/material.dart';

Widget buildDropdown(
  String hint,
  String? selectedValue,
  List<String> items,
  ValueChanged<String?> onChanged,
) {
  return DropdownButton<String>(
    hint: Text(hint),
    value: selectedValue,
    onChanged: onChanged,
    borderRadius: BorderRadius.circular(12),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    items: items
        .map((item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            ))
        .toList(),
  );
}
