import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:fth_admin/core/error/failures.dart';
import 'package:fth_admin/core/models/user_model.dart';
import 'package:fth_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:fth_admin/features/auth/domain/usecases/usecase.dart';

class RegisterUseCase implements UseCase<UserModel, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, UserModel>> call(RegisterParams params) async {
    if (params.username.isEmpty ||
        params.email.isEmpty ||
        params.password.isEmpty ||
        params.confirmPassword.isEmpty) {
      return const Left(InvalidInputFailure('Lütfen tüm alanları doldurun'));
    }

    if (params.password != params.confirmPassword) {
      return const Left(InvalidInputFailure('Şifreler eşleşmiyor'));
    }

    if (params.password.length < 6) {
      return const Left(InvalidInputFailure('Şifre en az 6 karakter olmalıdır'));
    }

    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(params.email)) {
      return const Left(InvalidInputFailure('Lütfen geçerli bir email adresi girin'));
    }

    return await repository.register(
      params.username,
      params.email,
      params.password,
    );
  }
}

class RegisterParams extends Equatable {
  final String username;
  final String email;
  final String password;
  final String confirmPassword;

  const RegisterParams({
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object> get props => [username, email, password, confirmPassword];
}
