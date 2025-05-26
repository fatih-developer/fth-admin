import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// Genel hatalar
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

// Auth hataları
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(String message) : super(message);
}

class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure() : super('Bu e-posta adresi zaten kullanılıyor');
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure() : super('Geçersiz e-posta veya şifre');
}

class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure() : super('Kullanıcı bulunamadı');
}

// Form hataları
class InvalidInputFailure extends Failure {
  const InvalidInputFailure(String message) : super(message);
}
