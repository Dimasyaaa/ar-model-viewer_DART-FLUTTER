import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ar_catalog/models/ar_model.dart';
import 'package:ar_catalog/widgets/model_card.dart';

void main() {
  group('ModelCard анимации (ЛР5)', () {
    final testModel = ArModel(
      id: 42,
      title: 'Test Model',
      description: 'Test Desc',
      modelPath: 'assets/models/test.glb',
      previewPath: 'assets/previews/test.png',
      type: ArModelType.technic,
      scale: 1.0,
    );

    testWidgets('промежуточный кадр анимации и вызов onTap', (tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 400,
                child: ModelCard(
                  model: testModel,
                  onTap: () => wasTapped = true,
                ),
              ),
            ),
          ),
        ),
      );

      // 1. НАЧИНАЕМ жест нажатия (эмулируем tap down), но НЕ отпускаем палец!
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ModelCard)),
      );

      // 2. Продвигаем время на 100 мс (середина твоей анимации в 200 мс)
      await tester.pump(const Duration(milliseconds: 100));

      // 3. Проверяем состояние В МОМЕНТЕ удержания нажатия
      final ignorePointerFinder = find.descendant(
        of: find.byType(ModelCard),
        matching: find.byType(IgnorePointer),
      );

      final ignorePointer = tester.widget<IgnorePointer>(ignorePointerFinder);
      expect(
        ignorePointer.ignoring,
        isFalse,
        reason:
            'При удержании нажатия (_isPressed=true) ignoring должен быть false',
      );

      // 4. Отпускаем палец (эмулируем tap up)
      await gesture.up();

      // 5. Завершаем анимацию и проверяем вызов callback
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        wasTapped,
        isTrue,
        reason: 'Callback должен сработать после отпускания',
      );
    });

    testWidgets('IgnorePointer блокирует скрытый элемент при opacity 0', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 400,
                child: ModelCard(model: testModel, onTap: () {}),
              ),
            ),
          ),
        ),
      );

      // В начальном состоянии _isPressed == false
      final ignorePointerFinder = find.descendant(
        of: find.byType(ModelCard),
        matching: find.byType(IgnorePointer),
      );
      final ignorePointer = tester.widget<IgnorePointer>(ignorePointerFinder);
      expect(
        ignorePointer.ignoring,
        isTrue,
        reason:
            'В спокойном состоянии скрытый текст должен быть недоступен (ignoring: true)',
      );

      final animatedOpacityFinder = find.descendant(
        of: find.byType(ModelCard),
        matching: find.byType(AnimatedOpacity),
      );
      final animatedOpacity = tester.widget<AnimatedOpacity>(
        animatedOpacityFinder,
      );
      expect(
        animatedOpacity.opacity,
        equals(0.0),
        reason: 'В спокойном состоянии прозрачность должна быть 0.0',
      );
    });
  });
}
