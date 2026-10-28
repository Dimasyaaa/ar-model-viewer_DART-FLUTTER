import 'package:flutter_test/flutter_test.dart';
import 'package:ar_catalog/models/ar_model.dart';
import 'package:ar_catalog/data/ar_model_mapper.dart';

void main() {
  group('ArModelMapper', () {
    final originalModel = ArModel(
      id: 42,
      title: 'Test Model',
      description: 'Test Description',
      modelPath: 'assets/models/robot.glb',
      previewPath: 'assets/previews/test.png',
      type: ArModelType.technic,
      scale: 1.5,
    );

    test('round-trip: модель -> Map -> модель', () {
      final map = ArModelMapper.toMap(originalModel);
      final restoredModel = ArModelMapper.fromMap(map);

      // Сравниваем значения всех полей, так как value equality может быть не реализован
      expect(restoredModel.id, equals(originalModel.id));
      expect(restoredModel.title, equals(originalModel.title));
      expect(restoredModel.description, equals(originalModel.description));
      expect(restoredModel.modelPath, equals(originalModel.modelPath));
      expect(restoredModel.previewPath, equals(originalModel.previewPath));
      expect(restoredModel.type, equals(originalModel.type));
      expect(restoredModel.scale, equals(originalModel.scale));
    });

    test('отклоняет Map без model_path', () {
      final invalidMap = {
        ArModelMapper.columnId: 1,
        ArModelMapper.columnTitle: 'Test',
        ArModelMapper.columnDescription: 'Desc',
        // model_path отсутствует
        ArModelMapper.columnPreviewPath: 'assets/previews/test.png',
        ArModelMapper.columnScale: 1.0,
      };

      expect(
        () => ArModelMapper.fromMap(invalidMap),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('отклоняет Map с неправильным типом title', () {
      final invalidMap = {
        ArModelMapper.columnId: 1,
        ArModelMapper.columnTitle: 123, // Должен быть String
        ArModelMapper.columnDescription: 'Desc',
        ArModelMapper.columnModelPath: 'assets/models/test.glb',
        ArModelMapper.columnPreviewPath: 'assets/previews/test.png',
        ArModelMapper.columnScale: 1.0,
      };

      expect(
        () => ArModelMapper.fromMap(invalidMap),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('отклоняет Map с недопустимым типом scale ', () {
      final invalidMap = {
        ArModelMapper.columnId: 1,
        ArModelMapper.columnTitle: 'Test',
        ArModelMapper.columnDescription: 'Desc',
        ArModelMapper.columnModelPath: 'assets/models/test.glb',
        ArModelMapper.columnPreviewPath: 'assets/previews/test.png',
        ArModelMapper.columnScale: 'invalid_string', // Должен быть num
      };

      expect(
        () => ArModelMapper.fromMap(invalidMap),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('корректно обрабатывает scale как int из базы ', () {
      final mapWithIntScale = {
        ArModelMapper.columnId: 1,
        ArModelMapper.columnTitle: 'Test',
        ArModelMapper.columnDescription: 'Desc',
        ArModelMapper.columnModelPath: 'assets/models/test.glb',
        ArModelMapper.columnPreviewPath: 'assets/previews/test.png',
        ArModelMapper.columnScale: 2, // SQLite может вернуть int вместо double
      };

      final model = ArModelMapper.fromMap(mapWithIntScale);
      expect(model.scale, equals(2.0));
      expect(model.scale, isA<double>());
    });
  });
}
