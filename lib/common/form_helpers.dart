import 'package:flutter/material.dart';

InputDecoration labelInput(String label) {
  return InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
    isDense: true,
  );
}

Widget gap12() => const SizedBox(height: 12);
Widget gap8() => const SizedBox(height: 8);
Widget gap16() => const SizedBox(height: 16);
