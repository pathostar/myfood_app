import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'scan_screen.dart';   // chemin: ../screens/scan_screen.dart si besoin
import 'history_screen.dart';   // ⇦ nouveau
import 'shopping_list_screen.dart';
import 'profile_screen.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _firstName = '';

  @override
  void initState() {
    super.initState();
    _loadFirstName();
  }

  Future<void> _loadFirstName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _firstName = prefs.getString('firstName') ?? 'Utilisateur';
    });
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Widget _buildMenuButton(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
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
        // 🔹 AUCUNE icône de déconnexion ici
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bienvenue $_firstName",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildMenuButton(
              context,
              Icons.qr_code_scanner,
              "Scanner un produit",
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScanScreen()),
              ),
            ),

            _buildMenuButton(
              context,
              Icons.history,
              "Historique",
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              ),
            ),

           _buildMenuButton(
              context,
              Icons.list_alt,
              'Liste de courses',
              () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ShoppingListScreen()),
                  ),
            ),
            _buildMenuButton(
              context,
              Icons.person,
              'Profil / Préférences',
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
            ),

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
