import 'package:ar_catalog/models/ar_model.dart';

/// Преобразователь между ArModel и Map для SQLite.
/// Инкапсулирует логику преобразования и названия столбцов БД.
class ArModelMapper {
  // Названия столбцов в базе данных
  static const String columnId = 'id';
  static const String columnTitle = 'title';
  static const String columnDescription = 'description';
  static const String columnModelPath = 'model_path';
  static const String columnPreviewPath = 'preview_path';
  static const String columnScale = 'scale';

  /// Преобразование ArModel в Map для записи в БД
  static Map<String, Object?> toMap(ArModel model) {
    return {
      columnId: model.id,
      columnTitle: model.title,
      columnDescription: model.description,
      columnModelPath: model.modelPath,
      columnPreviewPath: model.previewPath,
      columnScale: model.scale,
    };
  }

  /// Преобразование Map из БД в ArModel
  /// Бросает ArgumentError при некорректных данных, чтобы не создавать фиктивные объекты.
  static ArModel fromMap(Map<String, Object?> map) {
    final id = map[columnId];
    final title = map[columnTitle];
    final description = map[columnDescription];
    final modelPath = map[columnModelPath];
    final previewPath = map[columnPreviewPath];
    final scale = map[columnScale];

    // Строгая проверка типов
    if (id is! int) {
      throw ArgumentError('Invalid id type: ${id.runtimeType}');
    }
    if (title is! String) {
      throw ArgumentError('Invalid title type: ${title.runtimeType}');
    }
    if (description is! String) {
      throw ArgumentError(
        'Invalid description type: ${description.runtimeType}',
      );
    }
    if (modelPath is! String) {
      throw ArgumentError('Invalid modelPath type: ${modelPath.runtimeType}');
    }
    if (previewPath is! String) {
      throw ArgumentError(
        'Invalid previewPath type: ${previewPath.runtimeType}',
      );
    }

    // scale может прийти как num (int или double из SQLite), приводим к double
    if (scale is! num) {
      throw ArgumentError('Invalid scale type: ${scale.runtimeType}');
    }

    // Используем обычный конструктор ArModel, чтобы сработали инварианты ЛР1
    return ArModel(
      id: id,
      title: title,
      description: description,
      modelPath: modelPath,
      previewPath: previewPath,
      type: _extractTypeFromPath(modelPath),
      scale: scale.toDouble(),
    );
  }

  /// Временная логика извлечения типа из пути для совместимости с ЛР1-ЛР5
  static ArModelType _extractTypeFromPath(String path) {
    final lowerPath = path.toLowerCase();
    if (lowerPath.contains('robot') ||
        lowerPath.contains('engine') ||
        lowerPath.contains('hammer')) {
      return ArModelType.technic;
    } else if (lowerPath.contains('space') ||
        lowerPath.contains('planet') ||
        lowerPath.contains('helmet') ||
        lowerPath.contains('astronaut')) {
      return ArModelType.space;
    }
    return ArModelType.other;
  }
}
