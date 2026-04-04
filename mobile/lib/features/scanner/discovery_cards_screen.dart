import 'package:flutter/material.dart';
import '../../core/widgets/gradient_scaffold.dart';

class DiscoveryCardsScreen extends StatelessWidget {
  final String title;

  // We require a title so the screen knows WHICH door you clicked!
  const DiscoveryCardsScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Color(0xFF0B3C6A))),
        iconTheme: const IconThemeData(color: Color(0xFF0B3C6A)),
      ),
      body: Center(
        child: Text(
          'Screen 3.4: Discovery Cards\n\nYou opened the $title door!',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, color: Color(0xFF0B3C6A)),
        ),
      ),
    );
  }
}