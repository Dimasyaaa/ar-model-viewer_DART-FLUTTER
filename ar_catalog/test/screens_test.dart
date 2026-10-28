import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ar_catalog/models/ar_model.dart';
import 'package:ar_catalog/repositories/memory_model_repository.dart';
import 'package:ar_catalog/screens/home_screen.dart';
import 'package:ar_catalog/screens/scanner_screen.dart';

void main() {
  group('Widget тесты экранов и навигации', () {
    // Вспомогательная функция для создания тестовой модели
    ArModel createTestModel(int id) {
      return ArModel(
        id: id,
        title: 'Model $id',
        description: 'Description $id',
        modelPath: 'assets/models/test.glb',
        previewPath: 'assets/previews/test.png',
        type: ArModelType.technic,
        scale: 1.0,
      );
    }

    testWidgets('HomeScreen отображает карточки и передает модель при нажатии', (
      WidgetTester tester,
    ) async {
      final repository = MemoryModelRepository([
        createTestModel(1),
        createTestModel(2),
      ]);

      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(repository: repository)),
      );

      // Ждем завершения асинхронной загрузки
      await tester.pumpAndSettle();

      // Используем findsWidgets, так как текст может встречаться в нескольких местах
      expect(find.text('Model 1'), findsWidgets);
      expect(find.text('Description 1'), findsWidgets);

      // Имитируем нажатие на первую карточку
      await tester.tap(find.text('Model 1'));
      await tester.pumpAndSettle();

      // Проверяем, что открылся ArScreen с правильными данными.
      // Используем уникальные тексты, чтобы избежать конфликтов с HomeScreen
      expect(find.text('Description 1'), findsOneWidget);
      expect(find.textContaining('ЛР8'), findsOneWidget);
    });

    testWidgets('ScannerScreen: возврат без выбора (нажатие Отмена)', (
      WidgetTester tester,
    ) async {
      final repository = MemoryModelRepository([createTestModel(1)]);
      ArModel? returnedModel;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  returnedModel = await Navigator.push<ArModel?>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScannerScreen(repository: repository),
                    ),
                  );
                },
                child: const Text('Open Scanner'),
              );
            },
          ),
        ),
      );

      // Открываем сканер
      await tester.tap(find.text('Open Scanner'));
      await tester.pumpAndSettle();

      // Находим и нажимаем кнопку "Проверить идентификатор вручную"
      await tester.tap(find.text('Проверить идентификатор вручную'));
      await tester.pumpAndSettle();

      // В диалоге нажимаем "Отмена"
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();

      // Проверяем, что вернули null (выбора не было)
      expect(returnedModel, isNull);
    });

    testWidgets('ScannerScreen: успешный ручной ввод и возврат модели', (
      WidgetTester tester,
    ) async {
      final repository = MemoryModelRepository([createTestModel(2)]);
      ArModel? returnedModel;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  returnedModel = await Navigator.push<ArModel?>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ScannerScreen(repository: repository),
                    ),
                  );
                },
                child: const Text('Open Scanner'),
              );
            },
          ),
        ),
      );

      // Открываем сканер
      await tester.tap(find.text('Open Scanner'));
      await tester.pumpAndSettle();

      // Открываем диалог
      await tester.tap(find.text('Проверить идентификатор вручную'));
      await tester.pumpAndSettle();

      // Вводим 2 в текстовое поле
      await tester.enterText(find.byType(TextField), '2');
      await tester.pump();

      // Нажимаем Проверить
      await tester.tap(find.text('Проверить'));
      await tester.pumpAndSettle();

      // Проверяем, что вернулась правильная модель
      expect(returnedModel, isNotNull);
      expect(returnedModel!.id, equals(2));
      expect(returnedModel!.title, equals('Model 2'));
    });
  });
}
