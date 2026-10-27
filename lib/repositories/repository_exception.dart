/// Собственное исключение для ошибок репозитория
class RepositoryException implements Exception {
  final String message;
  final Object? cause;

  RepositoryException(this.message, [this.cause]);

  @override
  String toString() {
    if (cause != null) {
      return 'RepositoryException: $message (причина: $cause)';
    }
    return 'RepositoryException: $message';
  }
}
