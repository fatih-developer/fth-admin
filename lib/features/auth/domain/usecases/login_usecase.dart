import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart'; // Equatable ekledik
import 'package:fth_admin/core/error/failures.dart';
import 'package:fth_admin/core/models/user_model.dart';
import 'package:fth_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:fth_admin/features/auth/domain/usecases/usecase.dart';

class LoginUseCase implements UseCase<UserModel, LoginParams> {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  @override
  Future<Either<Failure, UserModel>> call(LoginParams params) async {
    // Giriş parametrelerinin boş olup olmadığını kontrol etmeye gerek yok,
    // bu kontrolü BLoC veya UI katmanında yapmak daha uygun olabilir.
    // E-posta formatı kontrolü de benzer şekilde ele alınabilir.
    return await repository.login(
      params.email,
      params.password,
    );
  }
}

class LoginParams extends Equatable { // Equatable'dan türettik
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password]; // props ekledik
}