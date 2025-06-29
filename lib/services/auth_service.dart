import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';     // ← pour debugPrint

class AuthService {
  /// ⚠️ 10.0.2.2 si émulateur Android, IP du PC si appareil réel
  final String baseUrl = 'http://10.0.2.2:3000';

  /* -------- INSCRIPTION STEP 1 -------- */
  Future<String?> registerStep1(
    String firstName,
    String lastName,
    String username,
    String password,
    String birthday,
  ) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/auth/register-step1'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'lastName' : lastName,
          'username' : username,
          'password' : password,
          'birthday' : birthday,
        }),
      );

      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        return data['userId'] as String;
      } else {
        debugPrint('Erreur register-step1 : ${res.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception register-step1 : $e');
      return null;
    }
  }

  /* -------- LISTE DES ALLERGÈNES -------- */
  /// Renvoie [{id:'en:milk', label:'lait'}, …]
  Future<List<Map<String, String>>> getAllergens({String lang = 'en'}) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/allergens?lang=$lang'));

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data
            .map<Map<String, String>>((e) => {
                  'id'   : e['id'].toString(),
                  'label': e['name'].toString(),
                })
            .toList();
      } else {
        debugPrint('Erreur backend allergens : ${res.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Exception getAllergens() : $e');
      return [];
    }
  }

  /* -------- INSCRIPTION STEP 2 -------- */
  Future<bool> registerStep2(String userId, List<String> allergens) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/auth/register-step2'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'allergens': allergens}),
      );

      // ➜ on sauvegarde TOUJOURS localement
      await prefs.setStringList('userAllergens', allergens);

      if (res.statusCode == 200) return true;
      debugPrint('registerStep2 backend error : ${res.body}');
      return false;            // on avertit l’UI mais on ne perd pas les données
    } catch (e) {
      debugPrint('registerStep2 exception : $e');
      await prefs.setStringList('userAllergens', allergens); // always cache
      return false;
    }
}
  /* -------- CONNEXION -------- */
  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', data['user']['id']);
        await prefs.setString('firstName', data['user']['firstName']);
        await prefs.setString('username', data['user']['username']);
        return data;
      } else {
        debugPrint('Connexion échouée : ${res.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception login : $e');
      return null;
    }
  }

  /* -------- DÉCONNEXION -------- */
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint('Session supprimée.');
  }
}
