import 'package:ar_project/ar_model.dart';
import 'package:ar_project/model_repository.dart';
import 'package:ar_project/memory_model_repository.dart';

Future<void> main() async {
  // список всех моделей
  final repository = MemoryModelRepository([
    ArModel(
      id: 1,
      name: 'Robot',
      description: 'Тестовый робот',
      modelPath: 'assets/models/robot.glb',
      type: ArModelType.technic,
      scale: 1.5,
    ),
    ArModel(
      id: 2,
      name: 'Space Helmet',
      description: 'Шлем космонафта',
      modelPath: 'assets/models/helmet.glb',
      type: ArModelType.space,
      scale: 2.2,
    ),
    ArModel(
      id: 3,
      name: 'Planet',
      description: 'Модель Земли',
      modelPath: 'assets/models/earth.glb',
      type: ArModelType.space,
      scale: 2,
    ),
    ArModel(
      id: 4,
      name: 'Astronaut',
      description: 'Модель космонафта',
      modelPath: 'assets/models/astronaut.glb',
      type: ArModelType.space,
      scale: 3.4,
    ),
    ArModel(
      id: 5,
      name: 'Engine',
      description: 'Реактивный двигатель',
      modelPath: 'assets/models/engine.glb',
      type: ArModelType.technic,
      scale: 5,
    ),
    ArModel(
      id: 6,
      name: 'Hammer',
      description: 'Молоток',
      modelPath: 'assets/models/hammer.glb',
      type: ArModelType.equipment,
      scale: 1.1,
    ),
    ArModel(
      id: 7,
      name: 'Dog',
      description: 'Милая собачка',
      modelPath: 'assets/models/dog.glb',
      type: ArModelType.other,
      scale: 1.1,
    ),
  ]);

  // список всех моделей
  print('=== Все модели в системе===\n');
  final allModels = await repository.getAll();
  for (var model in allModels) {
    print(model);
    print('------------------');
  }

  // тесты
  print('\n=== Поиск по QR ===\n');

  await _testQr(repository, '2');
  await _testQr(repository, '4');
  await _testQr(repository, '999');
  await _testQr(repository, 'abc');
  await _testQr(repository, '0');
  await _testQr(repository, '-5');
  await _testQr(repository, '');
  await _testQr(repository, '  3  ');

  //  тест fromMap
  print('\n=== Проверка fromMap ===');
  final mapData = <String, Object?>{
    'id': 10,
    'name': 'Test Object',
    'description': 'From Map',
    'model_path': 'models/test.glb',
    'type': 'other',
    'scale': 1.0,
  };
  final mappedModel = ArModel.fromMap(mapData);
  print('Создана модель: ${mappedModel.name}, тип: ${mappedModel.typeName}');
}

// Парсинг QR
int parseQrId(String qrValue) {
  final trimmed = qrValue.trim();
  if (trimmed.isEmpty) {
    throw const FormatException('QR-код пуст');
  }
  final id = int.tryParse(trimmed);
  if (id == null || id <= 0) {
    throw const FormatException('QR-код должен быть положительным числом');
  }
  return id;
}

// Поиск через репозиторий
Future<ArModel?> findModelByQr(
  ModelRepository repository,
  String qrValue,
) async {
  try {
    final id = parseQrId(qrValue);
    return await repository.getById(id);
  } on FormatException catch (e) {
    print('Ошибка: ${e.message}');
    return null;
  }
}

// Вывод результатов теста
Future<void> _testQr(ModelRepository repository, String qrValue) async {
  print('QR: "$qrValue"');
  final model = await findModelByQr(repository, qrValue);
  if (model != null) {
    print('Найдена: ${model.name}\n');
  } else {
    print('Не найдена\n');
  }
}
