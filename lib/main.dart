import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/app_constants.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();        // ← indispensable avant prefs
  runApp(const MyFoodApp());
}

class MyFoodApp extends StatelessWidget {
  const MyFoodApp({super.key});

  // --------- vérifie la session en prefs ----------
  Future<bool> _isLogged() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('userId');             // on garde la session si userId existe
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyFood',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: AppColors.darkText),
        ),
      ),

      // --------- décision asynchrone : Splash / Welcome / Home ----------
      home: FutureBuilder<bool>(
        future: _isLogged(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            // petit écran de chargement pendant la lecture des prefs
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // connecté → HomeScreen ; sinon WelcomeScreen
          return snapshot.data! ? const HomeScreen() : const WelcomeScreen();
        },
      ),

      // ------------ routes nommées ------------
      routes: {
        '/login'   : (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home'    : (_) => const HomeScreen(),
      },
    );
  }
}
