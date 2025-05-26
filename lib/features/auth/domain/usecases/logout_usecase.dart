import 'package:dartz/dartz.dart';
import 'package:fth_admin/core/error/failures.dart'; // Yol düzeltildi
import 'package:fth_admin/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    try {
      await repository.logout();
      return const Right(unit); // Başarı durumu
    } catch (e) {
      // Burada daha spesifik hata yönetimi yapılabilir
      return Left(ServerFailure(e.toString())); // Hata durumu - Konumsal argümanla düzeltildi
    }
  }
}
