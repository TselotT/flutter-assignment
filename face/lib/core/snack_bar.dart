import 'package:flutter/material.dart';

void displaySnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: const Duration(milliseconds: 1000),
    content: Text(message),
  ));
}