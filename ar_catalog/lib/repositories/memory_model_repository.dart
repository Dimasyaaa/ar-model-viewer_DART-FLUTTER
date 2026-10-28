import '../models/ar_model.dart';
import 'model_repository.dart';
import 'repository_exception.dart';

class MemoryModelRepository implements ModelRepository {
  final Map<int, ArModel> _storage;

  MemoryModelRepository(List<ArModel> initialModels) : _storage = {} {
    for (final model in initialModels) {
      if (_storage.containsKey(model.id)) {
        throw ArgumentError('Дублирующийся id: ${model.id}.');
      }
      _storage[model.id] = model;
    }
  }

  @override
  Future<List<ArModel>> getAll() async {
    final sorted = _storage.values.toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    return List.unmodifiable(sorted);
  }

  @override
  Future<ArModel?> getById(int id) async {
    if (id < 1 || id > 2147483647) {
      throw ArgumentError.value(id, 'id', 'должен быть от 1 до 2147483647');
    }
    return _storage[id];
  }

  @override
  Future<void> insert(ArModel model) async {
    if (_storage.containsKey(model.id)) {
      throw RepositoryException('Модель с id ${model.id} уже существует.');
    }
    _storage[model.id] = model;
  }

  @override
  Future<bool> update(ArModel model) async {
    if (model.id < 1 || model.id > 2147483647) {
      throw ArgumentError.value(
        model.id,
        'id',
        'должен быть от 1 до 2147483647',
      );
    }
    if (!_storage.containsKey(model.id)) return false;
    _storage[model.id] = model;
    return true;
  }

  @override
  Future<bool> delete(int id) async {
    if (id < 1 || id > 2147483647) {
      throw ArgumentError.value(id, 'id', 'должен быть от 1 до 2147483647');
    }
    return _storage.remove(id) != null;
  }
}
