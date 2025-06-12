import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  final String username; // ici c'est en fait le firstName qu'on reçoit

  const HomeScreen({super.key, required this.username});

  void _logout(BuildContext context) async {
    final authService = AuthService();
    await authService.logout();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Widget _buildMenuButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, size: 32, color: AppColors.primary),
              const SizedBox(width: 16),
              Text(label, style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("MyFood"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bienvenue $username",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            // Les boutons restent visibles, on met juste un print() temporaire
            _buildMenuButton(context, Icons.qr_code_scanner, "Scanner un produit", () {
              print("Scanner un produit cliqué");
            }),
            _buildMenuButton(context, Icons.list_alt, "Liste de courses", () {
              print("Liste de courses cliquée");
            }),
            _buildMenuButton(context, Icons.history, "Historique", () {
              print("Historique cliqué");
            }),
            _buildMenuButton(context, Icons.person, "Profil / Préférences", () {
              print("Profil / Préférences cliqué");
            }),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                icon: const Icon(Icons.logout),
                label: const Text("Déconnexion"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
