import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myfood_app/main.dart';

void main() {
  testWidgets('Accueil affiche le logo et le texte', (WidgetTester tester) async {
    // Charge l'application
    await tester.pumpWidget(MyFoodApp());

    // Vérifie que le texte est visible
    expect(find.text('Bienvenue sur MyFood'), findsOneWidget);

    // Vérifie qu'une image est bien affichée
    expect(find.byType(Image), findsOneWidget);
  });
}
