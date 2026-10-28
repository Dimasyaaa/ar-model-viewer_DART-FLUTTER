enum ArModelType { technic, space, equipment, other }

class ArModel {
  final int id;
  final String title;
  final String description;
  final String modelPath;
  final String previewPath;
  final ArModelType type;
  final double scale;

  ArModel({
    required this.id,
    required this.title,
    required this.description,
    required this.modelPath,
    required this.previewPath,
    required this.type,
    required this.scale,
  }) {
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

  ArModel.fromMap(Map<String, Object?> map)
    : id = map['id'] as int,
      title = map['title'] as String,
      description = map['description'] as String,
      modelPath = map['model_path'] as String,
      previewPath = map['preview_path'] as String,
      type = ArModelType.values.byName(map['type'] as String),
      scale = (map['scale'] as num?)?.toDouble() ?? 1.0;

  String get fileName => modelPath.split('/').last;
  String get typeName => switch (type) {
    ArModelType.technic => 'Техника',
    ArModelType.space => 'Космос',
    ArModelType.equipment => 'Оборудование',
    ArModelType.other => 'Другое',
  };

  @override
  String toString() {
    return 'ID: $id\nНазвание: $title\nОписание: $description\nМодель: $fileName\nТип: $typeName\nМасштаб: $scale';
  }
}
