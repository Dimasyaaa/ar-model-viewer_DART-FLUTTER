import 'package:ar_catalog/models/ar_model.dart';
import 'package:ar_catalog/repositories/model_repository.dart';
import 'package:ar_catalog/services/qr_parser.dart';

/// Статусы результата сканирования QR-кода
enum QrScanStatus {
  invalid, // Некорректный формат строки
  notFound, // Формат верный, но модели с таким ID нет в базе
  found, // Модель успешно найдена
  storageError, // Ошибка при обращении к базе данных
}

/// Объект результата сканирования
class QrScanResult {
  final QrScanStatus status;
  final ArModel? model; // Заполняется только если status == found

  QrScanResult(this.status, {this.model});
}

/// Сервис для обработки строки QR-кода и поиска модели
/// Не содержит UI, Context, Navigator и логики камеры.
class QrCatalogService {
  final ModelRepository _repository;

  QrCatalogService(this._repository);

  /// Обрабатывает сырую строку из QR-кода или ручного ввода
  Future<QrScanResult> processQrString(String? rawValue) async {
    // 1. Проверка на null или пустую строку (п. 17)
    if (rawValue == null || rawValue.trim().isEmpty) {
      return QrScanResult(QrScanStatus.invalid);
    }

    // 2. Парсинг идентификатора
    final id = parseQrId(rawValue);

    // Если parseQrId вернул null, значит формат некорректный
    if (id == null) {
      return QrScanResult(QrScanStatus.invalid);
    }

    // 3. Поиск в репозитории (п. 16)
    try {
      final model = await _repository.getById(id);

      if (model == null) {
        return QrScanResult(QrScanStatus.notFound);
      }

      return QrScanResult(QrScanStatus.found, model: model);
    } catch (e) {
      // Любая ошибка репозитория (например, сбой БД) считается storageError
      return QrScanResult(QrScanStatus.storageError);
    }
  }
}
