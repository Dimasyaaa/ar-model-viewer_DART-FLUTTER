import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ar_catalog/data/database_service.dart';
import 'package:ar_catalog/models/ar_model.dart';
import 'package:ar_catalog/repositories/sqlite_model_repository.dart';
import 'package:ar_catalog/repositories/repository_exception.dart';
import 'package:path/path.dart' hide equals;
import 'package:sqflite/sqflite.dart';

void main() {
  // Инициализация binding для интеграционных тестов
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Интеграционные тесты SQLite (ЛР6)', () {
    late DatabaseService databaseService;
    late SqliteModelRepository repository;

    setUp(() async {
      // 1. Гарантируем чистоту перед каждым тестом
      final databasesPath = await getDatabasesPath();
      final mainDbPath = join(databasesPath, 'ar_catalog.db');
      await deleteDatabase(mainDbPath);

      // 2. Создаем новые экземпляры сервиса и репозитория
      databaseService = DatabaseService();
      repository = SqliteModelRepository(databaseService);
    });

    tearDown(() async {
      // 3. Закрываем соединение и удаляем базу после теста
      await databaseService.close();
      final databasesPath = await getDatabasesPath();
      final mainDbPath = join(databasesPath, 'ar_catalog.db');
      await deleteDatabase(mainDbPath);
    });

    testWidgets('Первый запуск: создаются seed-данные', (tester) async {
      final models = await repository.getAll();

      expect(models.length, greaterThanOrEqualTo(3));
      expect(models.map((m) => m.id), containsAll([1, 2, 3]));
    });

    testWidgets(
      'Сохранность: изменение сохраняется после закрытия и повторного открытия',
      (tester) async {
        // 1. Открываем и изменяем
        final model = await repository.getById(2);
        expect(model, isNotNull);

        final updatedModel = ArModel(
          id: 2,
          title: 'Updated Space Helmet Integration Test',
          description: model!.description,
          modelPath: model.modelPath,
          previewPath: model.previewPath,
          type: model.type,
          scale: model.scale,
        );

        final updateResult = await repository.update(updatedModel);
        expect(updateResult, isTrue);

        // 2. Закрываем базу (эмуляция полного закрытия приложения)
        await databaseService.close();

        // 3. Создаем новый сервис и открываем тот же файл
        databaseService = DatabaseService();
        repository = SqliteModelRepository(databaseService);

        // 4. Проверяем сохранность
        final reopenedModel = await repository.getById(2);
        expect(
          reopenedModel?.title,
          equals('Updated Space Helmet Integration Test'),
        );
      },
    );

    testWidgets('CRUD операции: вставка, обновление, удаление', (tester) async {
      // INSERT
      final newModel = ArModel(
        id: 1001,
        title: 'Test Model CRUD',
        description: 'Test Description',
        modelPath: 'assets/models/test.glb',
        previewPath: 'assets/previews/test.png',
        type: ArModelType.technic,
        scale: 1.5,
      );

      await repository.insert(newModel);
      final inserted = await repository.getById(1001);
      expect(inserted?.title, equals('Test Model CRUD'));

      // UPDATE
      final updated = ArModel(
        id: 1001,
        title: 'Updated Test Model CRUD',
        description: inserted!.description,
        modelPath: inserted.modelPath,
        previewPath: inserted.previewPath,
        type: inserted.type,
        scale: 2.0,
      );

      await repository.update(updated);
      final afterUpdate = await repository.getById(1001);
      expect(afterUpdate?.title, equals('Updated Test Model CRUD'));
      expect(afterUpdate?.scale, equals(2.0));

      // DELETE
      final deleteResult = await repository.delete(1001);
      expect(deleteResult, isTrue);

      final afterDelete = await repository.getById(1001);
      expect(afterDelete, isNull);

      // Повторное удаление возвращает false
      final deleteAgain = await repository.delete(1001);
      expect(deleteAgain, isFalse);
    });

    testWidgets('Дубликат: повторная вставка того же ID выбрасывает ошибку', (
      tester,
    ) async {
      final model1 = await repository.getById(1);
      expect(model1, isNotNull);

      expect(
        () => repository.insert(model1!),
        throwsA(isA<RepositoryException>()),
      );

      // Старая запись не уничтожена
      final stillExists = await repository.getById(1);
      expect(stillExists, isNotNull);
    });

    testWidgets(
      'Пустой каталог: при удалении всех записей getAll возвращает пустой список',
      (tester) async {
        await repository.delete(1);
        await repository.delete(2);
        await repository.delete(3);

        final models = await repository.getAll();
        expect(models, isEmpty);
      },
    );
  });
}
