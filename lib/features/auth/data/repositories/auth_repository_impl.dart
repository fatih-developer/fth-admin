import 'package:dartz/dartz.dart';
import 'package:fth_admin/core/error/exceptions.dart';
import 'package:fth_admin/core/error/failures.dart';
import 'package:fth_admin/core/models/user_model.dart';
import 'package:fth_admin/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:fth_admin/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;

  const AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, UserModel>> login(String email, String password) async {
    try {
      final user = await localDataSource.login(email, password);
      if (user != null) {
        return Right(user);
      } else {
        return const Left(InvalidCredentialsFailure());
      }
    } on CacheException {
      return const Left(CacheFailure('Önbellek hatası'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> register(String username, String email, String password) async {
    try {
      final user = await localDataSource.register(username, email, password);
      return Right(user);
    } on EmailAlreadyExistsException {
      return const Left(EmailAlreadyInUseFailure());
    } on CacheException {
      return const Left(CacheFailure('Önbellek hatası'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.logout();
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure('Çıkış yapılırken bir hata oluştu'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  bool isLoggedIn() {
    return localDataSource.isLoggedIn();
  }

  @override
  UserModel? getCurrentUser() {
    return localDataSource.getCurrentUser();
  }

  @override
  Future<Either<Failure, void>> clearAuthData() async {
    try {
      await localDataSource.clearAuthData();
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure('Önbellek temizlenirken bir hata oluştu'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
