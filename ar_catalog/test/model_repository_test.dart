import 'package:flutter_test/flutter_test.dart';
import 'package:ar_catalog/models/ar_model.dart'; // <-- Исправлены импорты
import 'package:ar_catalog/repositories/model_repository.dart';
import 'package:ar_catalog/repositories/memory_model_repository.dart';
import 'package:ar_catalog/repositories/repository_exception.dart';

ArModel _createModel(int id) {
  return ArModel(
    id: id,
    title: 'Model $id',
    description: 'Test',
    modelPath: 'assets/models/test.glb',
    previewPath: 'assets/previews/test.png',
    type: ArModelType.technic,
    scale: 1.0,
  );
}

void main() {
  group('ModelRepository CRUD', () {
    late ModelRepository repository;

    setUp(() {
      repository = MemoryModelRepository([
        _createModel(1),
        _createModel(2),
        _createModel(3),
      ]);
    });

    test('getAll возвращает все модели', () async {
      final models = await repository.getAll();
      expect(models.length, equals(3));
      expect(models.map((m) => m.id), containsAll([1, 2, 3]));
    });

    test('getAll возвращает неизменяемый список', () async {
      final models = await repository.getAll();
      expect(() => models.add(_createModel(99)), throwsUnsupportedError);
    });

    test('getById находит модель', () async {
      final model = await repository.getById(2);
      expect(model, isNotNull);
      expect(model!.id, equals(2));
    });

    test('getById возвращает null для несуществующей', () async {
      final model = await repository.getById(999);
      expect(model, isNull);
    });

    test('getById бросает ArgumentError для 0', () async {
      expect(() => repository.getById(0), throwsArgumentError);
    });

    test('insert добавляет модель', () async {
      final newModel = _createModel(4);
      await repository.insert(newModel);

      final found = await repository.getById(4);
      expect(found, isNotNull);
      expect(found!.title, equals('Model 4'));
    });

    test('insert бросает RepositoryException для дубликата', () async {
      final duplicate = _createModel(1);
      expect(
        () => repository.insert(duplicate),
        throwsA(isA<RepositoryException>()),
      );

      final original = await repository.getById(1);
      expect(original!.title, equals('Model 1'));
    });

    test('update обновляет модель', () async {
      final updated = ArModel(
        id: 2,
        title: 'Updated Model 2',
        description: 'New desc',
        modelPath: 'assets/models/new.glb',
        previewPath: 'assets/previews/new.png',
        type: ArModelType.space,
        scale: 2.0,
      );

      final result = await repository.update(updated);
      expect(result, isTrue);

      final found = await repository.getById(2);
      expect(found!.title, equals('Updated Model 2'));
    });

    test('update возвращает false для несуществующей', () async {
      final fakeModel = _createModel(999);
      final result = await repository.update(fakeModel);
      expect(result, isFalse);
    });

    test('delete удаляет модель', () async {
      final result = await repository.delete(2);
      expect(result, isTrue);

      final found = await repository.getById(2);
      expect(found, isNull);
    });

    test('delete возвращает false для несуществующей', () async {
      final result1 = await repository.delete(999);
      expect(result1, isFalse);

      final result2 = await repository.delete(999);
      expect(result2, isFalse);
    });
  });

  group('MemoryModelRepository изоляция', () {
    test('не зависит от изменений исходного списка', () async {
      final initialModels = [_createModel(1)];
      final repository = MemoryModelRepository(initialModels);

      initialModels.add(_createModel(2));

      final models = await repository.getAll();
      expect(models.length, equals(1));
    });

    test('пустой каталог', () async {
      final repository = MemoryModelRepository([]);
      final models = await repository.getAll();
      expect(models, isEmpty);
    });
  });
}
