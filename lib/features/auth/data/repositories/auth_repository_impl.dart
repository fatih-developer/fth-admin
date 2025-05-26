import 'package:dartz/dartz.dart';
import 'package:fth_admin/core/error/exceptions.dart'; 
import 'package:fth_admin/core/error/failures.dart';
import 'package:fth_admin/core/models/user_model.dart';
import 'package:fth_admin/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:fth_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:fth_admin/core/services/logger_service.dart'; 
import 'dart:convert'; 
import 'package:crypto/crypto.dart'; 

String _generateSalt() {
  return 'fth_admin_super_secret_salt_12345!'; 
}

String _hashPassword(String password, String salt) {
  final saltedPassword = utf8.encode(password + salt);
  final hashedPassword = sha256.convert(saltedPassword);
  return hashedPassword.toString();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  const AuthRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserModel>> login(String email, String password) async {
    LoggerService.info('[AuthRepo] Login isteği: $email');
    try {
      final userModel = await localDataSource.getUserByEmail(email);

      if (userModel == null) {
        LoggerService.warning('[AuthRepo] Kullanıcı bulunamadı: $email');
        return Left(AuthenticationFailure('Kullanıcı bulunamadı veya şifre hatalı.'));
      }

      final String expectedPasswordHash = _hashPassword(password, userModel.salt); 

      if (userModel.passwordHash == expectedPasswordHash) {
        LoggerService.info('[AuthRepo] Giriş başarılı: $email');
        return Right(userModel);
      } else {
        LoggerService.warning('[AuthRepo] Şifre eşleşmedi: $email');
        return Left(AuthenticationFailure('Kullanıcı bulunamadı veya şifre hatalı.'));
      }
    } on CacheException catch (e) {
      LoggerService.error('[AuthRepo] Login CacheException: ${e.message}');
      return Left(CacheFailure(e.message));
    } catch (e, s) {
      LoggerService.error('[AuthRepo] Login bilinmeyen hata: $e', e, s);
      return Left(ServerFailure('Giriş sırasında beklenmedik bir hata oluştu: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> register(
    String username, 
    String email, 
    String password,
    String confirmPassword,
  ) async {
    LoggerService.info('[AuthRepo] Register isteği: $email, $username');
    if (password != confirmPassword) {
      LoggerService.warning('[AuthRepo] Şifreler eşleşmiyor: $email');
      return Left(AuthenticationFailure('Şifreler eşleşmiyor.'));
    }

    try {
      final existingUser = await localDataSource.getUserByEmail(email);
      if (existingUser != null) {
        LoggerService.warning('[AuthRepo] E-posta zaten kayıtlı: $email');
        return Left(AuthenticationFailure('Bu e-posta adresi zaten kayıtlı.'));
      }

      final salt = _generateSalt(); 
      final passwordHash = _hashPassword(password, salt);
      
      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(), 
        username: username,
        email: email,
        passwordHash: passwordHash, 
        salt: salt,                 
        createdAt: DateTime.now(), 
      );

      await localDataSource.saveUser(newUser);
      LoggerService.info('[AuthRepo] Kullanıcı başarıyla kaydedildi: $email');
      return Right(newUser);

    } on CacheException catch (e) {
      LoggerService.error('[AuthRepo] Register CacheException: ${e.message}');
      return Left(CacheFailure(e.message));
    } catch (e, s) {
      LoggerService.error('[AuthRepo] Register bilinmeyen hata: $e', e, s);
      return Left(ServerFailure('Kayıt sırasında beklenmedik bir hata oluştu: ${e.toString()}'));
    }
  }

  @override
  Future<void> logout() async {
    LoggerService.info('[AuthRepo] Logout isteği');
    try {
      await localDataSource.logout(); 
      LoggerService.info('[AuthRepo] Logout başarılı');
    } on CacheException catch (e) {
      LoggerService.error('[AuthRepo] Logout CacheException: ${e.message}');
      throw CacheFailure(e.message); 
    } catch (e,s) {
      LoggerService.error('[AuthRepo] Logout bilinmeyen hata: $e', e, s);
      throw ServerFailure(e.toString()); 
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final result = await localDataSource.isLoggedIn();
    LoggerService.info('[AuthRepo] IsLoggedIn: $result');
    return result;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = await localDataSource.getCurrentUser();
    LoggerService.info('[AuthRepo] GetCurrentUser: ${user?.email}');
    return user;
  }

  @override
  Future<Either<Failure, void>> clearAuthData() async {
    LoggerService.info('[AuthRepo] ClearAuthData isteği');
    try {
      await localDataSource.clearAuthData();
      LoggerService.info('[AuthRepo] ClearAuthData başarılı');
      return const Right(unit);
    } on CacheException catch (e) {
      LoggerService.error('[AuthRepo] ClearAuthData CacheException: ${e.message}');
      return Left(CacheFailure(e.message));
    } catch (e, s) {
      LoggerService.error('[AuthRepo] ClearAuthData bilinmeyen hata: $e', e, s);
      return Left(ServerFailure(e.toString()));
    }
  }
}
