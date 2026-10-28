import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ar_catalog/models/ar_model.dart';
import 'package:ar_catalog/repositories/memory_model_repository.dart';
import 'package:ar_catalog/screens/home_screen.dart';
import 'package:ar_catalog/screens/scanner_screen.dart';

void main() {
  group('Widget тесты экранов и навигации', () {
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

    // Универсальный поиск текста (игнорирует регистр)
    Finder findTextContaining(String substring) {
      return find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data != null &&
            widget.data!.toLowerCase().contains(substring.toLowerCase()),
        description: 'Text containing "$substring"',
      );
    }

    testWidgets(
      'HomeScreen отображает карточки и передает модель при нажатии',
      (tester) async {
        final repository = MemoryModelRepository([
          createTestModel(1),
          createTestModel(2),
        ]);

        await tester.pumpWidget(
          MaterialApp(home: HomeScreen(repository: repository)),
        );

        await tester.pumpAndSettle();

        expect(find.text('Model 1'), findsWidgets);
        expect(find.text('Description 1'), findsWidgets);

        await tester.tap(find.text('Model 1'));
        await tester.pumpAndSettle();

        expect(find.text('Description 1'), findsOneWidget);
        expect(find.textContaining('ЛР8'), findsOneWidget);
      },
    );

    testWidgets('ScannerScreen рендерится напрямую и имеет кнопку ввода', (
      tester,
    ) async {
      final repository = MemoryModelRepository([createTestModel(1)]);

      // 1. Делаем ScannerScreen корневым виджетом. Это исключает ошибки навигации.
      await tester.pumpWidget(
        MaterialApp(home: ScannerScreen(repository: repository)),
      );

      // 2. Даем время на отрисовку и анимацию (без pumpAndSettle, чтобы не зависнуть!)
      await tester.pump(const Duration(milliseconds: 500));

      // 3. Проверяем, что экран вообще отрисовался
      expect(
        find.byType(ScannerScreen),
        findsOneWidget,
        reason: 'ScannerScreen не отрисовался!',
      );

      // 4. Ищем кнопку по слову "проверить"
      final buttonFinder = findTextContaining('проверить');

      // 5. Проверяем наличие кнопки
      expect(
        buttonFinder,
        findsWidgets,
        reason:
            'Кнопка не найдена. Тексты на экране: ${find.byType(Text).evaluate().map((e) => '"${(e.widget as Text).data}"').join(', ')}',
      );

      // 6. Имитируем нажатие на кнопку
      await tester.tap(buttonFinder.first);
      await tester.pump(const Duration(milliseconds: 500));

      // 7. Проверяем, что открылся диалог
      expect(find.textContaining('идентификатор'), findsWidgets);

      // 8. Нажимаем Отмена и завершаем тест
      await tester.tap(find.text('Отмена'));
      await tester.pump(const Duration(milliseconds: 500));
    });
  });
}
