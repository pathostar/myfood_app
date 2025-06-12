import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Profil / Préférences"),
      ),
      body: const Center(
        child: Text("Page Profil - à implémenter"),
      ),
    );
  }
}
