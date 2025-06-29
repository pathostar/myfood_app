import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';     // ← ajout
import '../services/auth_service.dart';
import '../constants/app_constants.dart';
import 'allergen_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController  = TextEditingController();
  final TextEditingController _usernameController  = TextEditingController();
  final TextEditingController _passwordController  = TextEditingController();
  final TextEditingController _birthdayController  = TextEditingController();

  String? _error;
  bool _isLoading = false;

  Future<void> _register() async {
    final firstName = _firstNameController.text.trim();
    final lastName  = _lastNameController.text.trim();
    final username  = _usernameController.text.trim();
    final password  = _passwordController.text.trim();
    final birthday  = _birthdayController.text.trim();

    if ([firstName, lastName, username, password, birthday].any((e) => e.isEmpty)) {
      setState(() => _error = 'Veuillez remplir tous les champs.');
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    final userId = await _authService.registerStep1(
      firstName, lastName, username, password, birthday,
    );

    setState(() => _isLoading = false);

    if (userId != null) {
      /* ---------- ENREGISTRE LE PRÉNOM AVANT DE CONTINUER ---------- */
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('firstName', firstName);     // ← clé 'firstName'

      /* ---------- Navigation vers la sélection d’allergènes ---------- */
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AllergenScreen(userId: userId)),
      );
    } else {
      setState(() => _error = 'Erreur lors de l\'inscription.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Inscription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _firstNameController,
                  decoration: const InputDecoration(labelText: 'Prénom')),
              TextField(controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Nom')),
              TextField(controller: _usernameController,
                  decoration: const InputDecoration(labelText: "Nom d'utilisateur")),
              TextField(controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                  obscureText: true),
              TextField(
                controller: _birthdayController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Date de naissance'),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (d != null) {
                    _birthdayController.text = d.toIso8601String().split('T').first;
                  }
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                      child: const Text("S'inscrire"),
                    ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
