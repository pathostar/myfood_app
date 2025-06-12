import 'package:flutter/material.dart';
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
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String? _error;
  bool _isLoading = false;

  Future<void> _register() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final ageText = _ageController.text.trim();
    final age = int.tryParse(ageText);

    if (firstName.isEmpty || lastName.isEmpty || username.isEmpty || password.isEmpty || age == null) {
      setState(() => _error = "Veuillez remplir tous les champs correctement.");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    // ✅ ICI on récupère bien le userId
    final userId = await _authService.registerStep1(firstName, lastName, username, password, age);

    setState(() {
      _isLoading = false;
    });

    if (userId != null) {
      // Aller vers l'écran de sélection des allergènes
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AllergenScreen(userId: userId), // ✅ ici la variable existe
        ),
      );
    } else {
      setState(() => _error = "Erreur lors de l'inscription.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Inscription"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: "Prénom"),
              ),
              TextField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: "Nom"),
              ),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Nom d'utilisateur"),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Mot de passe"),
                obscureText: true,
              ),
              TextField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: "Âge"),
                keyboardType: TextInputType.number,
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
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
