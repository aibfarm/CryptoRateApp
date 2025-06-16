import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_exchange_app/main.dart';

void main() {
  testWidgets('Crypto Exchange App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app starts with the exchange rate screen
    expect(find.text('USDT/BTC Exchange Rate'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('Refresh button test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Find and tap the refresh button
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();

    // Verify loading indicator appears
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}