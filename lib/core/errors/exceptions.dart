class ServerException implements Exception {
  final String message;
  const ServerException({required this.message});

  @override
  String toString() => 'ServerException: $message';
}

class AuthException implements Exception {
  final String message;
  const AuthException({required this.message});

  @override
  String toString() => 'AuthException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException({required this.message});

  @override
  String toString() => 'NotFoundException: $message';
}

class ValidationException implements Exception {
  final String message;
  const ValidationException({required this.message});

  @override
  String toString() => 'ValidationException: $message';
}
