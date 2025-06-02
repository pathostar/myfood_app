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
  List<String> _allAllergens = [];
  List<String> _selected = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAllergens();
  }

  Future<void> _loadAllergens() async {
    try {
      final list = await _authService.getAllergens();
      setState(() {
        _allAllergens = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Erreur lors du chargement.";
        _loading = false;
      });
    }
  }

  Future<void> _submitAllergens() async {
    final success = await _authService.registerStep2(widget.userId, _selected);
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(username: widget.userId), // tu peux ajuster si nécessaire
        ),
      );
    } else {
      setState(() {
        _error = "Erreur lors de l’enregistrement des allergènes.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Choix des allergènes"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text("Cochez vos allergènes :", style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: _allAllergens.map((allergen) {
                        return CheckboxListTile(
                          title: Text(allergen),
                          value: _selected.contains(allergen),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selected.add(allergen);
                              } else {
                                _selected.remove(allergen);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _submitAllergens,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Valider"),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ]
                ],
              ),
            ),
    );
  }
}
