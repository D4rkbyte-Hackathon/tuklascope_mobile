import 'package:flutter/material.dart';

// Removed the '_' so this can be imported and used anywhere
Color getProgressColor(int progress) {
  if (progress <= 40) return Colors.orangeAccent;
  if (progress <= 60) return Colors.yellow[700]!;
  if (progress <= 80) return Colors.lime;
  return Colors.green;
}