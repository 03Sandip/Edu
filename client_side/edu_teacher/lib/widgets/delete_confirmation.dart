import 'package:flutter/material.dart';

Future<bool> showDeleteConfirmationDialogs(BuildContext context) async {
  bool agreed = false;

  // First Dialog: Checkbox with terms
  final continueToSecond = await showDialog<bool>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Delete Confirmation'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('I hereby acknowledge that I want to delete this student.'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: agreed,
                      onChanged: (value) => setState(() => agreed = value!),
                    ),
                    const Expanded(child: Text('I agree to the above statement.')),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: agreed ? () => Navigator.pop(context, true) : null,
                child: const Text('Continue'),
              ),
            ],
          );
        },
      );
    },
  );

  if (continueToSecond != true) return false;

  // Second Dialog: Yes/No confirmation
  final confirmFinal = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Are you sure?'),
      content: const Text('This action cannot be undone. Do you want to proceed?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('No'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Yes'),
        ),
      ],
    ),
  );

  return confirmFinal == true;
}
