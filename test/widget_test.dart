// Prueba básica de widgets.
//
// Comprueba que la pantalla de login se dibuja con sus botones. No depende de
// Supabase porque LoginPage solo lo usa al pulsar los botones, no al construirse.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kirolive/pages/login_page.dart';

void main() {
  testWidgets('La pantalla de login muestra los botones', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Registrarse'), findsOneWidget);
    expect(find.text('Continuar con Google'), findsOneWidget);
  });
}
