import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ar_catalog/models/ar_model.dart';
import 'package:ar_catalog/repositories/memory_model_repository.dart';
import 'package:ar_catalog/screens/home_screen.dart';
import 'package:ar_catalog/screens/scanner_screen.dart';
import 'package:ar_catalog/screens/ar_screen.dart';

void main() {
  group('Widget тесты экранов', () {
    testWidgets('HomeScreen отображает список моделей', (
      WidgetTester tester,
    ) async {
      final repository = MemoryModelRepository([
        ArModel(
          id: 1,
          title: 'Test Model',
          description: 'Test description',
          modelPath: 'assets/models/test.glb',
          previewPath: 'assets/previews/test.png',
          type: ArModelType.technic,
          scale: 1.0,
        ),
      ]);

      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(repository: repository)),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Model'), findsWidgets);
      expect(find.text('Test description'), findsWidgets);
    });

    testWidgets('ScannerScreen отображает заглушку', (
      WidgetTester tester,
    ) async {
      final repository = MemoryModelRepository([]);
      await tester.pumpWidget(
        MaterialApp(home: ScannerScreen(repository: repository)),
      );

      // Проверяем наличие иконки (она точно одна)
      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);

      // Ищем уникальное слово из текста заглушки, чтобы избежать дубликатов слова "QR"
      expect(find.textContaining('камеры'), findsOneWidget);
    });

    testWidgets('ArScreen отображает данные переданной модели', (
      WidgetTester tester,
    ) async {
      final model = ArModel(
        id: 2,
        title: 'AR Model',
        description: 'AR description',
        modelPath: 'assets/models/test.glb',
        previewPath: 'assets/previews/test.png',
        type: ArModelType.space,
        scale: 2.0,
      );

      await tester.pumpWidget(MaterialApp(home: ArScreen(model: model)));

      // Проверяем уникальное описание
      expect(find.text('AR description'), findsOneWidget);

      // Проверяем наличие иконки заглушки AR
      expect(find.byIcon(Icons.view_in_ar), findsOneWidget);

      // Заголовок может встречаться и в AppBar, и в теле, поэтому findsWidgets
      expect(find.text('AR Model'), findsWidgets);
    });
  });
}
