/// Сервис для разрешения пути к 3D-модели.
/// Поддерживает как локальные assets, так и внешние HTTPS-источники.
class ModelSourceService {
  final String baseUrl;

  // Задаем значение по умолчанию прямо в параметре конструктора
  ModelSourceService({
    this.baseUrl =
        'https://github.com/Dimasyaaa/ar-model-viewer_DART-FLUTTER/releases/download/lr08-assets',
  });

  /// Возвращает источник для model_viewer_plus.
  /// Если baseUrl задан, возвращает полную HTTPS-ссылку на файл.
  String resolveSource(String modelPath) {
    if (baseUrl.isNotEmpty) {
      // Проверка безопасности
      if (!modelPath.startsWith('assets/models/') || modelPath.contains('..')) {
        throw ArgumentError('Недопустимый путь модели: $modelPath');
      }
      if (!modelPath.endsWith('.glb')) {
        throw ArgumentError('Путь должен указывать на .glb файл');
      }

      // Извлекаем только имя файла (например, "Robot.glb") из "assets/models/Robot.glb"
      final fileName = modelPath.split('/').last;

      // Возвращаем полную HTTPS-ссылку
      return '$baseUrl/$fileName';
    }

    // Локальный asset (fallback, если baseUrl пустой)
    return modelPath;
  }
}
