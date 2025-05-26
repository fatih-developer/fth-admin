import 'package:dartz/dartz.dart';
import 'package:fth_admin/core/error/failures.dart';
import 'package:fth_admin/core/models/user_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserModel>> login(String email, String password);
  Future<Either<Failure, UserModel>> register(
    String username,
    String email,
    String password,
    String confirmPassword,
  );
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<UserModel?> getCurrentUser();
  Future<Either<Failure, void>> clearAuthData();
}
