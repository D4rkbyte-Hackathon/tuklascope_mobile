import 'package:flutter/material.dart';

/// Reads the three featured badge slots from a profiles row map.
List<String?> displayBadgesFromProfile(Map<String, dynamic> json) {
  return [
    _nullableString(json['display_badge_1']),
    _nullableString(json['display_badge_2']),
    _nullableString(json['display_badge_3']),
  ];
}

String? _nullableString(dynamic value) {
  if (value == null) return null;
  final s = value.toString().trim();
  return s.isEmpty ? null : s;
}

/// Renders a badge from a local asset path or remote URL.
Widget buildBadgeImage(
  String badgePath, {
  BoxFit fit = BoxFit.contain,
  double? width,
  double? height,
}) {
  final isNetwork = badgePath.startsWith('http');
  if (isNetwork) {
    return Image.network(
      badgePath,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.shield_outlined, size: 32),
    );
  }
  return Image.asset(
    badgePath,
    fit: fit,
    width: width,
    height: height,
    errorBuilder: (context, error, stackTrace) => const Icon(Icons.shield_outlined, size: 32),
  );
}
