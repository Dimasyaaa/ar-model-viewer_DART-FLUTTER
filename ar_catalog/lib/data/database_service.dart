import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Сервис для управления базой данных SQLite.
/// Отвечает за жизненный цикл соединения и схему.
class DatabaseService {
  static const String _databaseName = 'ar_catalog.db';
  static const int _databaseVersion = 1;

  // Кешируем Future открытия, а не сам Database
  Future<Database>? _databaseFuture;

  /// Получение соединения с базой данных.
  /// Два одновременных запроса дождутся одного и того же открытия.
  Future<Database> getDatabase({String? customPath}) {
    _databaseFuture ??= _initDatabase(customPath: customPath);
    return _databaseFuture!;
  }

  /// Инициализация базы данных.
  Future<Database> _initDatabase({String? customPath}) async {
    try {
      // Получаем путь к каталогу баз данных
      final databasesPath = await getDatabasesPath();
      final pathToDb = customPath ?? join(databasesPath, _databaseName);

      return await openDatabase(
        pathToDb,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      // При неуспешном открытии сбрасываем кеш для корректной повторной попытки
      _databaseFuture = null;
      rethrow;
    }
  }

  /// Создание таблицы и начальных данных (вызывается только при первом создании)
  Future<void> _onCreate(Database db, int version) async {
    // Создаем таблицу ar_models
    await db.execute('''
      CREATE TABLE ar_models (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        model_path TEXT NOT NULL,
        preview_path TEXT NOT NULL,
        scale REAL NOT NULL
      )
    ''');

    // Вставляем seed-данные (атомарно, т.к. onCreate уже выполняется в транзакции)
    final seedModels = [
      {
        'id': 1,
        'title': 'Robot',
        'description': 'Advanced robotics model',
        'model_path': 'assets/models/Robot.glb',
        'preview_path': 'assets/previews/robot.png',
        'scale': 1.0,
      },
      {
        'id': 2,
        'title': 'Space Helmet',
        'description': 'Astronaut helmet for space missions',
        'model_path': 'assets/models/Helmet.glb',
        'preview_path': 'assets/previews/helmet.png',
        'scale': 1.0,
      },
      {
        'id': 3,
        'title': 'Planet',
        'description': '3D model of a planet',
        'model_path': 'assets/models/Earth.glb',
        'preview_path': 'assets/previews/earth.png',
        'scale': 1.0,
      },
    ];

    for (final model in seedModels) {
      await db.insert('ar_models', model);
    }
  }

  /// Миграция базы данных (при увеличении версии схемы)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // В этой работе новая рабочая схема не нужна.
    // Добавление столбца потребует увеличения версии и преобразования старой базы.
  }

  /// Закрытие соединения (используется в интеграционных тестах)
  Future<void> close() async {
    if (_databaseFuture != null) {
      final db = await _databaseFuture!;
      await db.close();
      _databaseFuture = null;
    }
  }
}
