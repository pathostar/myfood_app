import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../screens/scan_result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  /* ----- baseUrl choisi dynamiquement ----- */
  final String baseUrl = kIsWeb
      ? 'http://localhost:3000'               // Web / desktop
      : Platform.isAndroid
          ? 'http://10.0.2.2:3000'            // Émulateur Android
          : 'http://localhost:3000';          // iOS Simulator

  late TabController _tabController;
  final _codeCtl           = TextEditingController();
  final _scannerController =
      MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  List<String> _userAllergens = [];
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    _userAllergens = prefs.getStringList('userAllergens') ?? [];
  });
}

  /* ---------- Appel backend + navigation ---------- */
  Future<void> _handleBarcode(String code) async {
    if (_isBusy) return;                // évite les doubles appels
    setState(() => _isBusy = true);

    final url = '$baseUrl/api/product/$code?lang=fr';
    debugPrint('GET $url');

    try {
      final res = await http.get(Uri.parse(url));
      debugPrint('HTTP status: ${res.statusCode}');

      if (res.statusCode == 200) {
        final data          = jsonDecode(res.body);
        final prodAllergens = List<String>.from(data['allergens'] ?? []);

        if (!mounted) return;           // sécurité
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScanResultScreen(
              productName      : data['name'] ?? 'Produit inconnu',
              productAllergens : prodAllergens,
              userAllergens    : _userAllergens,
              // ⚠️ on ne passe plus userAllergens
            ),
          ),
        );
      } else if (res.statusCode == 404) {
        _showSnack('Produit non trouvé.');
      } else {
        _showSnack('Erreur serveur (${res.statusCode}).');
      }
    } catch (e) {
      _showSnack('Erreur réseau.');
      debugPrint('Exception : $e');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  /* --------------------------- UI --------------------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Rechercher un produit'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.qr_code_scanner), text: 'Scanner'),
            Tab(icon: Icon(Icons.keyboard),        text: 'Saisir un code'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          /* ---------- Scanner caméra ---------- */
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              final code = capture.barcodes.first.rawValue ?? '';
              if (code.isNotEmpty) _handleBarcode(code);
            },
          ),

          /* ---------- Saisie manuelle ---------- */
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _codeCtl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Entrez un code-barres',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    final code = _codeCtl.text.trim();
                    if (code.isNotEmpty) _handleBarcode(code);
                  },
                  icon : const Icon(Icons.search),
                  label: const Text('Rechercher'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
