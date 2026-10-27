import 'dart:io';
import 'package:ar_project/ar_model.dart';
import 'package:ar_project/repositories/model_repository.dart';
import 'package:ar_project/repositories/memory_model_repository.dart';

Future<void> main() async {
  // список всех моделей
  final repository = MemoryModelRepository([
    ArModel(
      id: 1,
      title: 'Robot',
      description: 'Тестовый робот',
      modelPath: 'assets/models/robot.glb',
      previewPath: 'assets/previews/robot.png',
      type: ArModelType.technic,
      scale: 1.5,
    ),
    ArModel(
      id: 2,
      title: 'Space Helmet',
      description: 'Шлем космонафта',
      modelPath: 'assets/models/helmet.glb',
      previewPath: 'assets/previews/helmet.png',
      type: ArModelType.space,
      scale: 2.2,
    ),
    ArModel(
      id: 3,
      title: 'Planet',
      description: 'Модель Земли',
      modelPath: 'assets/models/earth.glb',
      previewPath: 'assets/previews/earth.png',
      type: ArModelType.space,
      scale: 2,
    ),
    ArModel(
      id: 4,
      title: 'Astronaut',
      description: 'Модель космонафта',
      modelPath: 'assets/models/astronaut.glb',
      previewPath: 'assets/previews/astronaut.png',
      type: ArModelType.space,
      scale: 3.4,
    ),
    ArModel(
      id: 5,
      title: 'Engine',
      description: 'Реактивный двигатель',
      modelPath: 'assets/models/engine.glb',
      previewPath: 'assets/previews/engine.png',
      type: ArModelType.technic,
      scale: 5,
    ),
    ArModel(
      id: 6,
      title: 'Hammer',
      description: 'Молоток',
      modelPath: 'assets/models/hammer.glb',
      previewPath: 'assets/previews/hammer.png',
      type: ArModelType.equipment,
      scale: 1.1,
    ),
    ArModel(
      id: 7,
      title: 'Dog',
      description: 'Милая собачка',
      modelPath: 'assets/models/dog.glb',
      previewPath: 'assets/previews/dog.png',
      type: ArModelType.other,
      scale: 1.1,
    ),
  ]);

  printHeader('AR КАТАЛОГ: Консольное приложение');

  // список всех моделей
  print('=== Все модели в системе===\n');
  final allModels = await repository.getAll();
  for (var model in allModels) {
    print(model);
    printLine();
  }
  print('');

  // Демонстрация CRUD операций
  await _demonstrateCrud(repository);

  // Интерактивный режим поиска
  await _interactiveSearch(repository);
}

// Вспомогательные функции для оформления вывода
void printHeader(String text) {
  print('==================================================');
  print(' $text');
  print('==================================================\n');
}

void printLine() {
  print('--------------------------------------------------');
}

// Демонстрация CRUD операций
Future<void> _demonstrateCrud(ModelRepository repository) async {
  printHeader('Демонстрация CRUD операций');

  // INSERT
  print('1. Попытка добавления новой модели (ID: 8)...');
  try {
    await repository.insert(
      ArModel(
        id: 8,
        title: 'Satellite',
        description: 'Искусственный спутник',
        modelPath: 'assets/models/satellite.glb',
        previewPath: 'assets/previews/satellite.png',
        type: ArModelType.space,
        scale: 3.0,
      ),
    );
    print('   [УСПЕХ] Модель успешно добавлена.\n');
  } catch (e) {
    print('   [ОШИБКА] $e\n');
  }

  // UPDATE
  print('2. Попытка обновления модели (ID: 8)...');
  final updatedModel = ArModel(
    id: 8,
    title: 'Advanced Satellite',
    description: 'Модернизированный спутник',
    modelPath: 'assets/models/satellite_v2.glb',
    previewPath: 'assets/previews/satellite_v2.png',
    type: ArModelType.space,
    scale: 3.5,
  );
  final isUpdated = await repository.update(updatedModel);
  print('   [РЕЗУЛЬТАТ] Обновление успешно: $isUpdated\n');

  // DELETE
  print('3. Попытка удаления модели (ID: 8)...');
  final isDeleted = await repository.delete(8);
  print('   [РЕЗУЛЬТАТ] Удаление успешно: $isDeleted\n');

  // ПОВТОРНОЕ УДАЛЕНИЕ (должно вернуть false)
  print('4. Повторная попытка удаления той же модели (ID: 8)...');
  final isDeletedAgain = await repository.delete(8);
  print('   [РЕЗУЛЬТАТ] Удаление успешно: $isDeletedAgain (ожидалось false)\n');

  // DUPLICATE INSERT (должно вызвать исключение)
  print('5. Попытка добавления дубликата с существующим ID (ID: 1)...');
  try {
    await repository.insert(
      ArModel(
        id: 1,
        title: 'Duplicate Robot',
        description: 'Эта вставка должна быть отклонена',
        modelPath: 'assets/models/dup.glb',
        previewPath: 'assets/previews/dup.png',
        type: ArModelType.technic,
        scale: 1.0,
      ),
    );
    print('   [ОШИБКА] Дубликат не был отклонен!\n');
  } catch (e) {
    print('   [ОЖИДАЕМАЯ ОШИБКА] Дубликат корректно отклонен: $e\n');
  }
}

// Интерактивный поиск
Future<void> _interactiveSearch(ModelRepository repository) async {
  printHeader('Интерактивный поиск по QR-коду');
  print('Введите числовой идентификатор для поиска или "q" для выхода.');
  print('Допустимый диапазон: от 1 до 2147483647');
  printLine();

  while (true) {
    stdout.write('Ввод QR > ');
    final input = stdin.readLineSync();

    // Обработка конца потока ввода (Ctrl+D или Ctrl+Z)
    if (input == null) {
      print('\n[ИНФО] Обнаружен конец ввода. Завершение работы...');
      break;
    }

    final trimmedInput = input.trim();

    // Команда выхода
    if (trimmedInput.toLowerCase() == 'q') {
      print('[ИНФО] Завершение работы.');
      break;
    }

    // Строгий парсинг
    final id = parseQrId(input);

    if (id == null) {
      print(
        '[ОШИБКА] Некорректный идентификатор. Введите только цифры от 1 до 2147483647.\n',
      );
      continue;
    }

    // Поиск через репозиторий
    try {
      final model = await repository.getById(id);
      if (model != null) {
        print('[УСПЕХ] Модель найдена:');
        print('  Название: ${model.title}');
        print('  Описание: ${model.description}');
        print('  Тип: ${model.typeName}');
        print('  Файл: ${model.fileName}\n');
      } else {
        print('[ИНФО] Модель с ID $id не найдена.\n');
      }
    } catch (e) {
      print('[ОШИБКА] Ошибка репозитория: $e\n');
    }
  }
}

/// Парсинг QR-кода в идентификатор.
/// Вход: String?, Выход: int?.
/// Разрешены только десятичные цифры, диапазон 1..2147483647.
int? parseQrId(String? qrValue) {
  if (qrValue == null) {
    return null;
  }

  final trimmed = qrValue.trim();
  if (trimmed.isEmpty) {
    return null;
  }

  // Регулярное выражение: только цифры от начала до конца строки.
  // Запрещает: пробелы внутри, буквы, знаки +, -, десятичные точки, hex.
  final digitRegExp = RegExp(r'^[0-9]+$');
  if (!digitRegExp.hasMatch(trimmed)) {
    return null;
  }

  final id = int.tryParse(trimmed);
  if (id == null) {
    return null;
  }

  // Проверка диапазона
  if (id < 1 || id > 2147483647) {
    return null;
  }

  return id;
}
