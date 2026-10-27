/// Парсинг QR-кода в идентификатор
/// Строго только десятичные цифры, диапазон 1..2147483647
int? parseQrId(String? qrValue) {
  if (qrValue == null) {
    return null;
  }

  final trimmed = qrValue.trim();

  // Пустая строка после trim
  if (trimmed.isEmpty) {
    return null;
  }

  // Проверяем, что строка состоит ТОЛЬКО из цифр (п. 46 ЛР1)
  // Никаких знаков +, -, пробелов внутри, букв и т.д.
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
