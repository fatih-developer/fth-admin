import 'package:dartz/dartz.dart';
import 'package:fth_admin/core/error/failures.dart'; // Yol düzeltildi
import 'package:fth_admin/features/auth/domain/repositories/auth_repository.dart';
import 'package:fth_admin/core/models/user_model.dart'; // Yol düzeltildi

class CheckAuthStatusUseCase {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  Future<Either<Failure, UserModel>> call() async {
    try {
      final user = await repository.getCurrentUser();
      if (user != null) {
        return Right(user);
      } else {
        return Left(AuthenticationFailure('Oturum bulunamadı veya kullanıcı bilgisi yok.'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
