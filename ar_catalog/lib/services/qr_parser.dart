int? parseQrId(String? qrValue) {
  if (qrValue == null) return null;
  final trimmed = qrValue.trim();
  if (trimmed.isEmpty) return null;

  final digitRegExp = RegExp(r'^[0-9]+$');
  if (!digitRegExp.hasMatch(trimmed)) return null;

  final id = int.tryParse(trimmed);
  if (id == null) return null;
  if (id < 1 || id > 2147483647) return null;

  return id;
}
