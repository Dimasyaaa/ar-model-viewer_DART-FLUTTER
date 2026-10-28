import 'package:flutter_test/flutter_test.dart';
import 'package:ar_catalog/models/ar_model.dart'; // <-- Исправлен импорт

void main() {
  group('ArModel валидация', () {
    test('создание корректной модели', () {
      final model = ArModel(
        id: 1,
        title: 'Test',
        description: 'Description',
        modelPath: 'assets/models/test.glb',
        previewPath: 'assets/previews/test.png',
        type: ArModelType.technic,
        scale: 1.0,
      );
      expect(model.id, equals(1));
      expect(model.title, equals('Test'));
    });

    test('отклоняет пустой title', () {
      expect(
        () => ArModel(
          id: 1,
          title: '  ',
          description: 'Desc',
          modelPath: 'assets/models/test.glb',
          previewPath: 'assets/previews/test.png',
          type: ArModelType.technic,
          scale: 1.0,
        ),
        throwsArgumentError,
      );
    });

    test('отклоняет отрицательный scale', () {
      expect(
        () => ArModel(
          id: 1,
          title: 'Test',
          description: 'Desc',
          modelPath: 'assets/models/test.glb',
          previewPath: 'assets/previews/test.png',
          type: ArModelType.technic,
          scale: -1.0,
        ),
        throwsArgumentError,
      );
    });

    test('отклоняет id вне диапазона', () {
      expect(
        () => ArModel(
          id: 0,
          title: 'Test',
          description: 'Desc',
          modelPath: 'assets/models/test.glb',
          previewPath: 'assets/previews/test.png',
          type: ArModelType.technic,
          scale: 1.0,
        ),
        throwsArgumentError,
      );

      expect(
        () => ArModel(
          id: 2147483648,
          title: 'Test',
          description: 'Desc',
          modelPath: 'assets/models/test.glb',
          previewPath: 'assets/previews/test.png',
          type: ArModelType.technic,
          scale: 1.0,
        ),
        throwsArgumentError,
      );
    });
  });

  group('ArModel.fromMap', () {
    test('создаёт модель из Map', () {
      final map = <String, Object?>{
        'id': 5,
        'title': 'From Map',
        'description': 'Test',
        'model_path': 'assets/models/test.glb',
        'preview_path': 'assets/previews/test.png',
        'type': 'space',
        'scale': 2.5,
      };

      final model = ArModel.fromMap(map);

      expect(model.id, equals(5));
      expect(model.title, equals('From Map'));
      expect(model.type, equals(ArModelType.space));
      expect(model.scale, equals(2.5));
    });
  });

  group('ArModel геттеры', () {
    final model = ArModel(
      id: 1,
      title: 'Test',
      description: 'Desc',
      modelPath: 'assets/models/folder/test.glb',
      previewPath: 'assets/previews/test.png',
      type: ArModelType.technic,
      scale: 1.0,
    );

    test('fileName возвращает имя файла', () {
      expect(model.fileName, equals('test.glb'));
    });

    test('typeName возвращает русское название', () {
      expect(model.typeName, equals('Техника'));
    });
  });
}
