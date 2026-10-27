enum ArModelType { technic, space, equipment, other }

class ArModel {
  // все необходимые поля
  final int id;
  final String title;
  final String description;
  final String modelPath;
  final String previewPath;
  // допы
  final ArModelType type;
  final double scale;

  // конструктор класса
  ArModel({
    required this.id,
    required this.title,
    required this.description,
    required this.modelPath,
    required this.previewPath,
    required this.type,
    required this.scale,
  }) {
    // Валидация инвариантов (ЛР1)
    if (id < 1 || id > 2147483647) {
      throw ArgumentError.value(id, 'id', 'должен быть от 1 до 2147483647');
    }
    if (title.trim().isEmpty) {
      throw ArgumentError.value(title, 'title', 'не может быть пустым');
    }
    if (description.trim().isEmpty) {
      throw ArgumentError.value(
        description,
        'description',
        'не может быть пустым',
      );
    }
    if (!modelPath.endsWith('.glb')) {
      throw ArgumentError.value(
        modelPath,
        'modelPath',
        'должен заканчиваться на .glb',
      );
    }
    if (scale.isNaN || scale <= 0) {
      throw ArgumentError.value(
        scale,
        'scale',
        'должен быть положительным числом',
      );
    }
  }

  // Конструктор из МАПЫ
  ArModel.fromMap(Map<String, Object?> map)
    : id = map['id'] as int,
      title = map['title'] as String,
      description = map['description'] as String,
      modelPath = map['model_path'] as String,
      previewPath = map['preview_path'] as String,
      type = ArModelType.values.byName(map['type'] as String),
      scale = (map['scale'] as num?)?.toDouble() ?? 1.0;

  // Геттер для получения имени файла
  String get filetitle {
    return modelPath.split('/').last;
  }

  String get fileName => modelPath.split('/').last;

  // Геттер для названия типа модели
  String get typeName {
    return switch (type) {
      ArModelType.technic => 'Техника',
      ArModelType.space => 'Космос',
      ArModelType.equipment => 'Оборудование',
      ArModelType.other => 'Другое',
    };
  }

  // переопределяем toString для вывода информации
  @override
  String toString() {
    return 'ID: $id\n'
        'Название: $title\n'
        'Описание: $description\n'
        'Файл: $filetitle\n'
        'Превью: ${previewPath.split('/').last}\n'
        'Тип: $typeName\n'
        'Масштаб: $scale';
  }
}

// теперь не нужно!!
// поиск модели по id

/* ArModel? findModelById(List<ArModel> models, int id) {
  for (var model in models) {
    if (model.id == id) {
      return model;
    }
  }
  return null;
}

// поиск по строке из qr-кода
ArModel? findModelByQr(List<ArModel> models, String qrValue) {
  // Безопасное преобразование строки в число
  int? id = int.tryParse(qrValue);

  // Если строка не число или id <= 0, возвращаем null
  if (id == null || id <= 0) {
    return null;
  }
  // модель по найденному id
  return findModelById(models, id);
}
*/
