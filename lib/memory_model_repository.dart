import 'ar_model.dart';
import 'model_repository.dart';

class MemoryModelRepository implements ModelRepository {
  final List<ArModel> _models;

  MemoryModelRepository(this._models);

  @override
  Future<List<ArModel>> getAll() async {
    return _models;
  }

  @override
  Future<ArModel?> getById(int id) async {
    for (final model in _models) {
      if (model.id == id) {
        return model;
      }
    }
    return null;
  }
}
