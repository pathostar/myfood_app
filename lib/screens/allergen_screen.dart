import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../constants/app_constants.dart';
import 'home_screen.dart';

class AllergenScreen extends StatefulWidget {
  final String userId;

  const AllergenScreen({super.key, required this.userId});

  @override
  State<AllergenScreen> createState() => _AllergenScreenState();
}

class _AllergenScreenState extends State<AllergenScreen> {
  final AuthService _authService = AuthService();

  List<String> _allergens = [];
  List<String> _selectedAllergens = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAllergens();
  }

  Future<void> _loadAllergens() async {
    try {
      // Récupère uniquement les allergènes en français
      final allergens = await _authService.getAllergens(lang: 'fr');
      setState(() {
        _allergens = allergens;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement des allergènes.';
        _loading = false;
      });
    }
  }

  void _toggleSelection(String allergen) {
    setState(() {
      if (_selectedAllergens.contains(allergen)) {
        _selectedAllergens.remove(allergen);
      } else {
        _selectedAllergens.add(allergen);
      }
    });
  }

  Future<void> _validateSelection() async {
    if (_selectedAllergens.isEmpty) {
      setState(() {
        _error = 'Veuillez sélectionner au moins un allergène.';
      });
      return;
    }

    try {
      final success = await _authService.registerStep2(widget.userId, _selectedAllergens);
      if (success) {
        // Aller vers HomeScreen après inscription complète
        if (!mounted) return;

        // On redirige vers HomeScreen → username sera récupéré au login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(username: 'Utilisateur'), // tu pourras plus tard passer le vrai username après login
          ),
        );
      } else {
        setState(() {
          _error = 'Erreur lors de la validation des allergènes.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur inattendue : $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Sélectionnez vos allergènes"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: _allergens.isEmpty
                        ? const Center(
                            child: Text(
                              'Aucun allergène disponible.',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : ListView(
                            children: _allergens.map((allergen) {
                              return CheckboxListTile(
                                title: Text(
                                  // Supprime le préfixe 'fr:' pour afficher proprement
                                  allergen.startsWith('fr:') ? allergen.substring(3) : allergen,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                value: _selectedAllergens.contains(allergen),
                                onChanged: (_) => _toggleSelection(allergen),
                                activeColor: AppColors.primary,
                              );
                            }).toList(),
                          ),
                  ),
                  ElevatedButton(
                    onPressed: _validateSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text("Valider mes choix"),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
