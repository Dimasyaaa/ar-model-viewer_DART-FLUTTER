import '../models/ar_model.dart';

abstract interface class ModelRepository {
  Future<List<ArModel>> getAll();
  Future<ArModel?> getById(int id);
  Future<void> insert(ArModel model);
  Future<bool> update(ArModel model);
  Future<bool> delete(int id);
}
