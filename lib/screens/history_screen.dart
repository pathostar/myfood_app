import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import 'scan_result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list  = prefs.getStringList('history') ?? [];
    setState(() {
      _items = list.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Historique des scans'),
          backgroundColor: AppColors.primary,
        ),
        body: _items.isEmpty
            ? const Center(child: Text('Aucun produit scanné.'))
            : ListView.builder(
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final it  = _items[i];
                  final dt  = DateTime.parse(it['scannedAt']);
                  final fmt = '${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2,'0')}';
                  return ListTile(
                    leading : const Icon(Icons.history),
                    title   : Text(it['name']),
                    subtitle: Text('Scanné le $fmt · Compat ${it['compat'].toStringAsFixed(1)} %'),
                    onTap   : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ScanResultScreen(
                          productName      : it['name'],
                          productAllergens : List<String>.from(it['allergens']),
                          
                        ),
                      ),
                    ),
                  );
                },
              ),
      );
}
