class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Sunucuyla iletişimde bir sorun oluştu.']);

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Önbellek hatası oluştu.']);

  @override
  String toString() => 'CacheException: $message';
}

class AuthenticationFailure implements Exception {
  final String message;
  AuthenticationFailure([this.message = 'Kimlik doğrulama başarısız.']);

  @override
  String toString() => 'AuthenticationFailure: $message';
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Ağ bağlantısı hatası.']);

  @override
  String toString() => 'NetworkException: $message';
}
