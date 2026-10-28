import 'package:flutter/material.dart';
import 'package:ar_catalog/app.dart';
import 'package:ar_catalog/data/database_service.dart';
import 'package:ar_catalog/repositories/sqlite_model_repository.dart';

void main() async {
  // 1. Гарантируем инициализацию Flutter binding перед асинхронными вызовами
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Создаем сервис базы данных и SQLite репозиторий
  final databaseService = DatabaseService();
  final repository = SqliteModelRepository(databaseService);

  // 3. Передаем репозиторий в приложение (MemoryModelRepository больше не используется)
  runApp(ArCatalogApp(repository: repository));
}
