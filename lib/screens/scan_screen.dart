import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Scanner un produit"),
      ),
      body: const Center(
        child: Text("Page Scanner - à implémenter"),
      ),
    );
  }
}
