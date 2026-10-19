enum ArModelType { technic, space, equipment, other }

class ArModel {
  // все необходимые поля
  final int id;
  final String name;
  final String description;
  final String modelPath;
  // допы
  final ArModelType type;
  final double scale;

  // конструктор класса
  ArModel({
    required this.id,
    required this.name,
    required this.description,
    required this.modelPath,
    required this.type,
    required this.scale,
  });

  // Конструктор из МАПЫ
  ArModel.fromMap(Map<String, Object?> map)
    : id = map['id'] as int,
      name = map['name'] as String,
      description = map['description'] as String,
      modelPath = map['model_path'] as String,
      type = ArModelType.values.byName(map['type'] as String),
      scale = (map['scale'] as num?)?.toDouble() ?? 1.0;

  // Геттер для получения имени файла
  String get fileName {
    return modelPath.split('/').last;
  }

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
        'Название: $name\n'
        'Описание: $description\n'
        'Файл: $fileName\n'
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
