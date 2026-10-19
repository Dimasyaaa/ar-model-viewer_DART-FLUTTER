import 'ar_model.dart';

abstract interface class ModelRepository {
  Future<List<ArModel>> getAll();
  Future<ArModel?> getById(int id);
}
