import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import 'allergen_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<String> _allergens = [];   // ex. ["en:milk","en:nuts"]
  bool _loading           = true;

  /*──────── helpers ────────*/

  String _label(String id) => id.split(':').last;   // « en:milk » → « milk »

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _allergens = prefs.getStringList('userAllergens') ?? [];
      _loading   = false;
    });
  }

  /*──────── life-cycle ────────*/

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  /*──────── UI ────────*/

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Mon profil'),
          backgroundColor: AppColors.primary,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /*──────── allergènes ────────*/
                    const Text('Mes allergènes :',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _allergens.isEmpty
                        ? const Text('Aucun allergène défini.')
                        : Wrap(
                            spacing: 8,
                            children: _allergens
                                .map((id) => Chip(label: Text(_label(id))))
                                .toList(),
                          ),
                    const Spacer(),

                    /*──────── bouton édition ────────*/
                    Center(
                      child: ElevatedButton.icon(
                        icon : const Icon(Icons.edit),
                        label: const Text('Modifier mes allergènes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                        ),
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final userId = prefs.getString('userId');
                          if (userId == null || !mounted) return;

                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AllergenScreen(userId: userId, isEdit: true),
                            ),
                          );
                          if (mounted) _loadPrefs(); // rafraîchir après retour
                        },
                      ),
                    ),
                  ],
                ),
              ),
      );
}
