import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import '../constants/app_constants.dart';
import 'home_screen.dart';

class AllergenScreen extends StatefulWidget {
  final String userId;
  final bool   isEdit;            // true quand on passe depuis le profil

  const AllergenScreen({
    super.key,
    required this.userId,
    this.isEdit = false,
  });

  @override
  State<AllergenScreen> createState() => _AllergenScreenState();
}

class _AllergenScreenState extends State<AllergenScreen> {
  final AuthService _auth = AuthService();

  /// liste complète [{id:'en:milk', label:'milk'}, …]
  List<Map<String,String>> _allergens = [];
  /// sélection de l’utilisateur  ["en:milk", …]
  List<String> _selected   = [];

  bool   _loading = true;
  String? _error;

  /* ---------------- initialisation ---------------- */

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    /* récupère la sélection courante si on édite depuis Profil */
    final prefs = await SharedPreferences.getInstance();
    _selected   = widget.isEdit
        ? (prefs.getStringList('userAllergens') ?? [])
        : [];

    await _loadAllergens();
  }

  /* ---------- charge la liste (langue EN) ---------- */
  Future<void> _loadAllergens() async {
    try {
      final list = await _auth.getAllergens(lang: 'en');     // ⚠️ EN
      list.sort((a,b) => a['label']!.compareTo(b['label']!)); // tri alpha
      setState(() {
        _allergens = list;
        _loading   = false;
      });
    } catch (_) {
      setState(() {
        _error   = 'Erreur lors du chargement des allergènes.';
        _loading = false;
      });
    }
  }

  /* ---------------- interactions ---------------- */

  void _toggle(String id) =>
    setState(() => _selected.contains(id) ? _selected.remove(id)
                                          : _selected.add(id));

  Future<void> _validate() async {
    if (_selected.isEmpty) {
      setState(() => _error = 'Veuillez sélectionner au moins un allergène.');
      return;
    }

    final ok = await _auth.registerStep2(widget.userId, _selected);
    if (!ok) {
      setState(() => _error = 'Erreur lors de la validation.');
      return;
    }

    if (!mounted) return;

    widget.isEdit
        ? Navigator.pop(context)                                    // retour profil
        : Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(widget.isEdit
            ? 'Modifier mes allergènes'
            : 'Sélectionnez vos allergènes'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: _allergens.isEmpty
                        ? const Center(child: Text('Aucun allergène disponible.'))
                        : ListView(
                            children: _allergens.map((a) {
                              final id    = a['id']!;     // en:milk
                              final label = a['label']!;  // milk
                              return CheckboxListTile(
                                dense       : true,
                                title       : Text(label),
                                value       : _selected.contains(id),
                                onChanged   : (_) => _toggle(id),
                                activeColor : AppColors.primary,
                              );
                            }).toList(),
                          ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed : _validate,
                    style     : ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                    ),
                    child     : const Text('Valider mes choix'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                ],
              ),
            ),
    );
  }
}
