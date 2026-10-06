/// Exception mentah yang dilempar oleh datasource (lapisan data).
/// Akan ditangkap oleh repository dan dikonversi menjadi [Failure].
class DatabaseException implements Exception {
  final String message;
  const DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException(this.message);

  @override
  String toString() => 'NotFoundException: $message';
}

class DuplicateException implements Exception {
  final String message;
  const DuplicateException(this.message);

  @override
  String toString() => 'DuplicateException: $message';
}
