import 'dart:convert'; // jsonDecode, jsonEncode için

import 'package:fth_admin/core/error/exceptions.dart'; // CacheException için
import 'package:fth_admin/core/models/user_model.dart';
import 'package:fth_admin/core/services/hive_service.dart';
import 'package:fth_admin/core/services/logger_service.dart';

// Arayüz Tanımı
abstract class AuthLocalDataSource {
  Future<UserModel?> getCurrentUser();
  Future<void> saveUser(UserModel userToCache);
  Future<UserModel?> getUserByEmail(String email);
  Future<void> logout();
  Future<bool> isLoggedIn();
  Future<void> clearAuthData();
  Future<void> saveToken(String token);
  Future<String?> getToken();
}

// Implementasyon
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  // final HiveService hiveService; // Kaldırıldı, static metotlar kullanılacak

  // Hive kutu ve anahtar isimleri
  static const String _userBoxName = HiveService.userBoxName; 
  static const String _tokenBoxName = HiveService.tokenBoxName;
  static const String _userKey = HiveService.userKey; 
  static const String _tokenKey = HiveService.tokenKey; 
  static const String _allUsersKey = 'all_users_list';

  AuthLocalDataSourceImpl(); // Parametresiz constructor

  @override
  Future<UserModel?> getCurrentUser() async {
    LoggerService.debug('[AuthLocalDataSource] getCurrentUser çağrıldı.');
    final userJson = await HiveService.getData<String>(_userBoxName, _userKey); // Static çağrı
    if (userJson != null) {
      try {
        LoggerService.debug('[AuthLocalDataSource] Mevcut kullanıcı bulundu: $userJson');
        return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      } catch (e, s) {
        LoggerService.error('AuthLocalDataSourceImpl - getCurrentUser JSON parse hatası', e, s);
        // await clearAuthData(); // Bozuk veriyi temizlemek yerine null dönmek daha iyi olabilir
        return null;
      }
    }
    LoggerService.debug('[AuthLocalDataSource] Mevcut kullanıcı (aktif session) bulunamadı.');
    return null;
  }

  Future<List<UserModel>> _getAllUsersFromHive() async {
    final usersJson = await HiveService.getData<String>(_userBoxName, _allUsersKey); // Static çağrı
    if (usersJson != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(usersJson);
        return decodedList.map((json) => UserModel.fromJson(json as Map<String, dynamic>)).toList();
      } catch (e, s) {
        LoggerService.error('AuthLocalDataSourceImpl - _getAllUsersFromHive JSON parse hatası', e, s);
        return []; // Hata durumunda boş liste
      }
    }
    return []; // Kayıt yoksa boş liste
  }

  @override
  Future<void> saveUser(UserModel userToCache) async {
    LoggerService.info('[AuthLocalDataSource] Kullanıcı kaydediliyor/güncelleniyor: ${userToCache.email}');
    try {
      List<UserModel> users = await _getAllUsersFromHive();
      int existingUserIndex = users.indexWhere((u) => u.email == userToCache.email);

      if (existingUserIndex != -1) {
        users[existingUserIndex] = userToCache; // Var olanı güncelle
        LoggerService.info('[AuthLocalDataSource] Mevcut kullanıcı güncellendi: ${userToCache.email}');
      } else {
        users.add(userToCache); // Yeni kullanıcıyı ekle
        LoggerService.info('[AuthLocalDataSource] Yeni kullanıcı eklendi: ${userToCache.email}');
      }
      await HiveService.putData<String>( // Static çağrı
          _userBoxName, _allUsersKey, jsonEncode(users.map((u) => u.toJson()).toList()));
      
      // Aktif kullanıcı olarak da işaretleyebiliriz (opsiyonel, _userKey altına)
      await HiveService.putData<String>( // Static çağrı
          _userBoxName, _userKey, jsonEncode(userToCache.toJson()));

      // Kullanıcı kaydedildiğinde bir token da kaydedebiliriz.
      final token = 'hive_token_for_${userToCache.id}_${DateTime.now().millisecondsSinceEpoch}';
      await saveToken(token); 
      LoggerService.info('[AuthLocalDataSource] Kullanıcı listesi, aktif kullanıcı ve token kaydedildi: ${userToCache.email}');
    } catch (e, s) {
      LoggerService.error('AuthLocalDataSourceImpl - saveUser Hive hatası', e, s);
      throw CacheException('Kullanıcı verisi kaydedilemedi.');
    }
  }

  @override
  Future<UserModel?> getUserByEmail(String email) async {
    LoggerService.info('[AuthLocalDataSource] E-posta ile kullanıcı aranıyor: $email');
    try {
      List<UserModel> users = await _getAllUsersFromHive();
      for (final user in users) {
        if (user.email == email) {
          LoggerService.info('[AuthLocalDataSource] E-posta ile kullanıcı bulundu: $email');
          return user;
        }
      }
      LoggerService.info('[AuthLocalDataSource] E-posta ile kullanıcı bulunamadı: $email');
      return null;
    } catch (e,s) {
       LoggerService.error('AuthLocalDataSourceImpl - getUserByEmail hatası', e, s);
       throw CacheException('Kullanıcı aranırken bir hata oluştu.');
    }
  }

  @override
  Future<void> logout() async {
    LoggerService.info('[AuthLocalDataSource] Logout yapılıyor.');
    await HiveService.deleteData(_tokenBoxName, _tokenKey); // Static çağrı
    await HiveService.deleteData(_userBoxName, _userKey); // Static çağrı
    LoggerService.info('[AuthLocalDataSource] Aktif kullanıcı ve token silindi (logout).');
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    // Sadece token varlığı değil, aktif bir kullanıcı da var mı diye kontrol edilebilir.
    // final currentUser = await getCurrentUser();
    // final isLoggedIn = token != null && token.isNotEmpty && currentUser != null;
    final isLoggedIn = token != null && token.isNotEmpty;
    LoggerService.info('[AuthLocalDataSource] IsLoggedIn kontrolü: $isLoggedIn (Token: ${token?.substring(0,token.length > 10 ? 10 : token.length)})');
    return isLoggedIn;
  }

  @override
  Future<void> clearAuthData() async {
    LoggerService.info('[AuthLocalDataSource] Tüm auth verileri temizleniyor.');
    await HiveService.deleteData(_userBoxName, _allUsersKey);  // Static çağrı
    await HiveService.deleteData(_userBoxName, _userKey);  // Static çağrı
    await HiveService.deleteData(_tokenBoxName, _tokenKey); // Static çağrı
    LoggerService.info('[AuthLocalDataSource] Tüm auth verileri temizlendi.');
  }

  @override
  Future<void> saveToken(String token) async {
    LoggerService.info('[AuthLocalDataSource] Token kaydediliyor.');
    try {
      await HiveService.putData<String>(_tokenBoxName, _tokenKey, token); // Static çağrı
      LoggerService.info('[AuthLocalDataSource] Token kaydedildi.');
    } catch (e, s) {
      LoggerService.error('AuthLocalDataSourceImpl - saveToken Hive hatası', e, s);
      throw CacheException('Token kaydedilemedi.');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      final token = await HiveService.getData<String>(_tokenBoxName, _tokenKey); // Static çağrı
      LoggerService.debug('[AuthLocalDataSource] Token alındı: ${token != null && token.isNotEmpty ? "Var" : "Yok"}');
      return token;
    } catch (e, s) {
      LoggerService.error('AuthLocalDataSourceImpl - getToken Hive hatası', e, s);
      return null;
    }
  }
}
