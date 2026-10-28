import 'package:flutter/material.dart';
import 'package:ar_catalog/app.dart';
import 'package:ar_catalog/models/ar_model.dart';
import 'package:ar_catalog/repositories/memory_model_repository.dart';

void main() {
  // ЕДИНСТВЕННОЕ место создания репозитория
  final repository = MemoryModelRepository([
    ArModel(
      id: 1,
      title: 'Robot',
      description: 'Тестовый промышленный робот',
      modelPath: 'assets/models/robot.glb',
      previewPath: 'assets/previews/robot.png',
      type: ArModelType.technic,
      scale: 1.5,
    ),
    ArModel(
      id: 2,
      title: 'Space Helmet',
      description: 'Шлем космонавта для AR',
      modelPath: 'assets/models/helmet.glb',
      previewPath: 'assets/previews/helmet.png',
      type: ArModelType.space,
      scale: 2.2,
    ),
    ArModel(
      id: 3,
      title: 'Planet Earth',
      description: 'Модель планеты Земля',
      modelPath: 'assets/models/earth.glb',
      previewPath: 'assets/previews/earth.png',
      type: ArModelType.space,
      scale: 2.0,
    ),
  ]);

  runApp(ArCatalogApp(repository: repository));
}
