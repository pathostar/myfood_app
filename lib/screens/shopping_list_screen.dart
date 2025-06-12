import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Liste de courses"),
      ),
      body: const Center(
        child: Text("Page Liste de courses - à implémenter"),
      ),
    );
  }
}
