import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  List<String> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _items = prefs.getStringList('shopping') ?? []);
  }

  Future<void> _delete(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _items.removeAt(index);
    await prefs.setStringList('shopping', _items);
    setState(() {});                       // refresh
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Liste de courses'),
          backgroundColor: AppColors.primary,
        ),
        body: _items.isEmpty
            ? const Center(child: Text('Aucun produit.'))
            : ListView.builder(
                itemCount: _items.length,
                itemBuilder: (_, i) => ListTile(
                  title: Text(_items[i]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _delete(i),
                  ),
                ),
              ),
      );
}
