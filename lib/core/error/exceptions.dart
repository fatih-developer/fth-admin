abstract class AppException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const AppException(this.message, [this.stackTrace]);

  @override
  String toString() => message;
}

// Cache ile ilgili istisnalar
class CacheException extends AppException {
  const CacheException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

// Ağ ile ilgili istisnalar
class ServerException extends AppException {
  final int? statusCode;

  const ServerException(
    String message, {
    this.statusCode,
    StackTrace? stackTrace,
  }) : super(message, stackTrace);
}

// Kimlik doğrulama ile ilgili istisnalar
class AuthenticationException extends AppException {
  const AuthenticationException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class EmailAlreadyExistsException extends AuthenticationException {
  const EmailAlreadyExistsException() : super('Bu e-posta adresi zaten kullanılıyor');
}

class InvalidCredentialsException extends AuthenticationException {
  const InvalidCredentialsException() : super('Geçersiz e-posta veya şifre');
}

class UserNotFoundException extends AuthenticationException {
  const UserNotFoundException() : super('Kullanıcı bulunamadı');
}

// İzinlerle ilgili istisnalar
class PermissionDeniedException extends AppException {
  const PermissionDeniedException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

// Geçersiz girdi istisnaları
class InvalidInputException extends AppException {
  const InvalidInputException(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}
