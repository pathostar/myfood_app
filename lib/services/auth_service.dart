import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseBackendUrl = 'http://localhost:3000';

  // Etape 1 - Création compte
  Future<String?> registerStep1(String firstName, String lastName, String username, String password, int age) async {
    final response = await http.post(
      Uri.parse('$baseBackendUrl/api/register-step1'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'username': username.trim(),
        'password': password.trim(),
        'age': age,
      }),
    );

    print('registerStep1 status: ${response.statusCode}');
    print('registerStep1 body: ${response.body}');

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['userId'];
    } else {
      return null;
    }
  }

  // Récupération des allergènes
  Future<List<String>> getAllergens({String lang = 'fr'}) async {
    final response = await http.get(Uri.parse('$baseBackendUrl/api/allergens?lang=$lang'));

    print('getAllergens status: ${response.statusCode}');
    print('getAllergens body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map<String>((item) => item['name'] as String).toList();
    } else {
      throw Exception('Failed to load allergens');
    }
  }

  // Etape 2 - Enregistrement des allergènes
  Future<bool> registerStep2(String userId, List<String> allergens) async {
    final response = await http.post(
      Uri.parse('$baseBackendUrl/api/register-step2'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'allergens': allergens,
      }),
    );

    print('registerStep2 status: ${response.statusCode}');
    print('registerStep2 body: ${response.body}');

    return response.statusCode == 200;
  }

  // Connexion utilisateur
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseBackendUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username.trim(),
          'password': password.trim(),
        }),
      );

      print('login status: ${response.statusCode}');
      print('login body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Sauvegarde du token JWT
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);

        return data;
      } else {
        return null;
      }
    } catch (e) {
      print('Exception lors du login: $e');
      return null;
    }
  }

  // Récupérer le token stocké
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Déconnexion
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    print('Utilisateur déconnecté (token supprimé)');
  }
}
