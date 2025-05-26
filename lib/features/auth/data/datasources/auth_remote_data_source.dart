import 'package:dio/dio.dart'; 
import 'package:fth_admin/core/models/user_model.dart';
import 'package:fth_admin/core/services/logger_service.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginUser(String email, String password);
  Future<UserModel> registerUser(String username, String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio; 

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> loginUser(String email, String password) async {
    LoggerService.warning('[AuthRemoteDataSourceImpl] loginUser çağrıldı ancak API kullanılmıyor. Bu metot implemente edilmemeli.');
    throw UnimplementedError('API kullanılmadığı için RemoteDataSource.loginUser implemente edilmedi.');
  }

  @override
  Future<UserModel> registerUser(
      String username, String email, String password) async {
    LoggerService.warning('[AuthRemoteDataSourceImpl] registerUser çağrıldı ancak API kullanılmıyor. Bu metot implemente edilmemeli.');
    throw UnimplementedError('API kullanılmadığı için RemoteDataSource.registerUser implemente edilmedi.');
  }
}
