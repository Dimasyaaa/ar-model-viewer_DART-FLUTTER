import '../../ar_model.dart';

abstract interface class ModelRepository {
  /// Получить все модели, отсортированные по id
  Future<List<ArModel>> getAll();

  /// Найти модель по id
  /// Возвращает null, если не найдена
  /// Бросает ArgumentError, если id вне диапазона
  Future<ArModel?> getById(int id);

  /// Добавить новую модель
  /// Бросает RepositoryException, если модель с таким id уже существует
  Future<void> insert(ArModel model);

  /// Обновить существующую модель
  /// Возвращает true, если обновлена
  /// Возвращает false, если модель с таким id не найдена
  Future<bool> update(ArModel model);

  /// Удалить модель по id
  /// Возвращает true, если удалена
  /// Возвращает false, если модель не найдена
  Future<bool> delete(int id);
}
