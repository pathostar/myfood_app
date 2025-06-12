import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Historique"),
      ),
      body: const Center(
        child: Text("Page Historique - à implémenter"),
      ),
    );
  }
}
