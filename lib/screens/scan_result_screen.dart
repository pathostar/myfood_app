import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class ScanResultScreen extends StatefulWidget {
  /// Identifiants canoniques OFF (ex. « en:milk »)
  final String productName;
  final List<String> productAllergens;
  final List<String>? userAllergens;

  const ScanResultScreen({
    super.key,
    required this.productName,
    required this.productAllergens,
    this.userAllergens,
  });

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  /* ───────── STATE ───────── */
  List<String> _userAllergens = []; // prefs → ["en:milk", …]
  bool _loading = true;

  /* ───────── LIFE-CYCLE ───────── */
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (widget.userAllergens != null) {
      _userAllergens = List<String>.from(widget.userAllergens!);
    } else {
      final prefs = await SharedPreferences.getInstance();
      _userAllergens = prefs.getStringList('userAllergens') ?? [];
    }

    // enregistre dans l’historique
    final prefs = await SharedPreferences.getInstance();
    await _saveToHistory(prefs);

    if (mounted) setState(() => _loading = false);
  }

  /* ───────── HELPERS ───────── */

  /// « en:milk » → « milk »
  String _label(String id) => id.split(':').last;

  double _compatibility(List<String> prod, List<String> user) {
    if (user.isEmpty) return 100.0;
    final nbCommon = prod.where(user.contains).length;
    return ((user.length - nbCommon) / user.length) * 100.0;
  }

  Color _trafficColor(double compat) => compat < 50.0 ? Colors.red : Colors.green;
  IconData _trafficIcon(double compat) =>
      compat < 50.0 ? Icons.close : Icons.check;

  /* ───────── PERSISTENCE ───────── */

  Future<void> _saveToHistory(SharedPreferences prefs) async {
    final history = prefs.getStringList('history') ?? [];

    // supprime une éventuelle entrée identique (nom + même jour)
    history.removeWhere((e) {
      final m = jsonDecode(e);
      final sameName = m['name'] == widget.productName;
      final sameDay =
          DateTime.parse(m['scannedAt']).day == DateTime.now().day;
      return sameName && sameDay;
    });

    history.insert(
      0,
      jsonEncode({
        'name': widget.productName,
        'allergens': widget.productAllergens,
        'compat': _compatibility(widget.productAllergens, _userAllergens),
        'scannedAt': DateTime.now().toIso8601String(),
      }),
    );

    await prefs.setStringList('history', history);
  }

  Future<void> _addToShoppingList() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('shopping') ?? [];

    if (!list.contains(widget.productName)) {
      list.add(widget.productName);
      await prefs.setStringList('shopping', list);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ajouté à la liste de courses')),
        );
      }
    }
  }

  /* ───────── UI ───────── */

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final prod = widget.productAllergens;
    final user = _userAllergens;
    final common = prod.where(user.contains).toList();
    final compat = _compatibility(prod, user);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Résultat du scan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Produit : ${widget.productName}',
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _section(
              'Allergènes du produit :',
              prod,
              'Aucun allergène trouvé.',
            ),
            const SizedBox(height: 16),
            _section(
              'Vos allergènes :',
              user,
              'Aucun allergène défini.',
            ),
            const SizedBox(height: 16),
            _section(
              'Allergènes en commun :',
              common,
              'Aucun allergène en commun.',
              warning: true,
            ),

            const SizedBox(height: 32),

            /* ───────── feu rouge / vert ───────── */
            Center(
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: _trafficColor(compat),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _trafficIcon(compat),
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    compat < 50.0
                        ? 'Produit non compatible'
                        : 'Produit compatible',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),
            _actionButtons(context),
          ],
        ),
      ),
    );
  }

  /* ───────── WIDGETS UTILITAIRES ───────── */

  Widget _section(
    String title,
    List<String> items,
    String empty, {
    bool warning = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        items.isEmpty
            ? Text(empty)
            : Wrap(
                spacing: 8,
                children: items
                    .map(
                      (id) => Chip(
                        label: Text(_label(id)),
                        backgroundColor: warning
                            ? Colors.redAccent
                            : AppColors.background,
                        labelStyle: warning
                            ? const TextStyle(color: Colors.white)
                            : null,
                      ),
                    )
                    .toList(),
              ),
      ],
    );
  }

  Widget _actionButtons(BuildContext ctx) => Center(
        child: Column(
          children: [
            _btn('➕  Ajouter à la liste de courses', _addToShoppingList),
            const SizedBox(height: 12),
            _btn('Scanner un autre produit', () => Navigator.pop(ctx)),
          ],
        ),
      );


  ElevatedButton _btn(String label, VoidCallback onTap) => ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
        child: Text(label),
      );
}
