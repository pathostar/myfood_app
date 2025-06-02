import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://localhost:3000/api';

  Future<String?> registerStep1(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register-step1'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['userId'];
    } else {
      return null;
    }
  }

  Future<List<String>> getAllergens() async {
    final response = await http.get(Uri.parse('$baseUrl/allergens'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return data.map((e) => e['id'] as String).toList();
    } else {
      return [];
    }
  }

  Future<bool> registerStep2(String userId, List<String> allergens) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register-step2'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'allergens': allergens}),
    );
    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // 🔒 Sauvegarde du token JWT
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);

      return data;
    } else {
      return null;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
