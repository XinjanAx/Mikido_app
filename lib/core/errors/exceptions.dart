class ServerException implements Exception {
  final String message;
  const ServerException({required this.message});

  @override
  String toString() => 'ServerException: $message';
}

/// Supabase rechazó borrar una fila porque otra la referencia (violación de
/// clave foránea, código Postgres 23503) — p. ej. una mesa que todavía tiene
/// categorías en el servidor aunque el dispositivo aún no las haya bajado.
class StillReferencedException implements Exception {
  final String message;
  const StillReferencedException({required this.message});

  @override
  String toString() => 'StillReferencedException: $message';
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
