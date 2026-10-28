import 'package:sqflite/sqflite.dart';
import 'package:ar_catalog/data/ar_model_mapper.dart';
import 'package:ar_catalog/data/database_service.dart';
import 'package:ar_catalog/models/ar_model.dart';
import 'package:ar_catalog/repositories/model_repository.dart';
import 'package:ar_catalog/repositories/repository_exception.dart';

/// Реализация ModelRepository на основе SQLite.
/// Сохраняет данные между перезапусками приложения.
class SqliteModelRepository implements ModelRepository {
  final DatabaseService _databaseService;

  const SqliteModelRepository(this._databaseService);

  @override
  Future<List<ArModel>> getAll() async {
    try {
      final db = await _databaseService.getDatabase();
      // Выполняем query таблицы с порядком по id
      final maps = await db.query('ar_models', orderBy: 'id ASC');

      // Преобразуем каждую строку и возвращаем неизменяемый список
      return List<ArModel>.unmodifiable(
        maps.map((map) => ArModelMapper.fromMap(map)),
      );
    } catch (e) {
      throw RepositoryException('Не удалось получить список моделей: $e');
    }
  }

  @override
  Future<ArModel?> getById(int id) async {
    // Проверяем диапазон ID
    if (id < 1 || id > 2147483647) {
      throw ArgumentError('ID должен быть от 1 до 2147483647');
    }

    try {
      final db = await _databaseService.getDatabase();
      // Параметризованный поиск по первичному ключу с ограничением результата
      final maps = await db.query(
        'ar_models',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) {
        return null;
      }

      return ArModelMapper.fromMap(maps.first);
    } catch (e) {
      throw RepositoryException('Не удалось найти модель с ID $id: $e');
    }
  }

  @override
  Future<void> insert(ArModel model) async {
    try {
      final db = await _databaseService.getDatabase();
      final map = ArModelMapper.toMap(model);

      // Обычная вставка. Не используем ConflictAlgorithm.replace
      await db.insert('ar_models', map);
    } on DatabaseException catch (e) {
      // Переводим ошибку ограничения UNIQUE в согласованное исключение
      if (e.isUniqueConstraintError()) {
        throw RepositoryException('Модель с ID ${model.id} уже существует');
      }
      throw RepositoryException('Ошибка базы данных при вставке: $e');
    } catch (e) {
      throw RepositoryException('Не удалось вставить модель: $e');
    }
  }

  @override
  Future<bool> update(ArModel model) async {
    try {
      final db = await _databaseService.getDatabase();
      final map = ArModelMapper.toMap(model);

      // Передаем измененные поля и условие по id
      final rowsAffected = await db.update(
        'ar_models',
        map,
        where: 'id = ?',
        whereArgs: [model.id],
      );

      // Возвращаемое число измененных строк определяет bool
      return rowsAffected > 0;
    } catch (e) {
      throw RepositoryException('Не удалось обновить модель: $e');
    }
  }

  @override
  Future<bool> delete(int id) async {
    try {
      final db = await _databaseService.getDatabase();

      // Условие по id (п. 25)
      final rowsAffected = await db.delete(
        'ar_models',
        where: 'id = ?',
        whereArgs: [id],
      );

      return rowsAffected > 0;
    } catch (e) {
      throw RepositoryException('Не удалось удалить модель с ID $id: $e');
    }
  }
}
