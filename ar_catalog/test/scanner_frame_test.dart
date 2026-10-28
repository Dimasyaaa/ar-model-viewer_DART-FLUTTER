import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ar_catalog/widgets/scanner_frame.dart';

void main() {
  group('ScannerFrame анимации', () {
    testWidgets('пульсирует в waiting и НЕ зависает при pump', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ScannerFrame(status: ScannerStatus.waiting)),
        ),
      );

      expect(find.byType(ScannerFrame), findsOneWidget);

      // Используем pump с конкретной длительностью, а НЕ pumpAndSettle
      await tester.pump(const Duration(milliseconds: 750));

      // Ищем AnimatedBuilder ТОЛЬКО внутри ScannerFrame
      final animatedBuilderFinder = find.descendant(
        of: find.byType(ScannerFrame),
        matching: find.byType(AnimatedBuilder),
      );
      expect(animatedBuilderFinder, findsOneWidget);
    });

    testWidgets('корректно останавливается и показывает ошибку', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ScannerFrame(status: ScannerStatus.processing)),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ScannerFrame(status: ScannerStatus.error)),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });
}
