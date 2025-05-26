import 'package:hive/hive.dart';
import 'package:fth_admin/core/models/user_model.dart';

class HiveService {
  static const String _authBox = 'auth_box';
  static const String _userBox = 'user_box';
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';
  static const String _isLoggedInKey = 'is_logged_in';

  static late Box _authBoxInstance;
  static late Box<UserModel> _userBoxInstance;

  static Future<void> init() async {
    _authBoxInstance = await Hive.openBox(_authBox);
    _userBoxInstance = await Hive.openBox<UserModel>(_userBox);
  }

  // Kullanıcı işlemleri
  static Future<void> saveUser(UserModel user) async {
    print('[HiveService] saveUser: Kullanıcı kaydediliyor - ID: ${user.id}, Email: ${user.email}');
    try {
      print('[HiveService] saveUser: _userBoxInstance.put çağrılıyor - Key: ${user.id}');
      await _userBoxInstance.put(user.id, user);
      print('[HiveService] saveUser: _userBoxInstance.put başarıyla tamamlandı - Key: ${user.id}');
      
      print('[HiveService] saveUser: _authBoxInstance.put çağrılıyor (user.id ile) - Key: $_userKey');
      await _authBoxInstance.put(_userKey, user.id);
      print('[HiveService] saveUser: _authBoxInstance.put (user.id ile) başarıyla tamamlandı - Key: $_userKey');
    } catch (e, s) {
      print('[HiveService] saveUser: Kullanıcı kaydedilirken HATA oluştu - $e');
      print('[HiveService] saveUser: StackTrace - $s');
      rethrow;
    }
  }

  static Future<void> saveCurrentAuthUser(UserModel user) async {
    print('[HiveService] saveCurrentAuthUser: Mevcut kullanıcı IDsi _authBoxInstance içine kaydediliyor - ID: ${user.id}, Key: $_userKey');
    try {
      await _authBoxInstance.put(_userKey, user.id);
      print('[HiveService] saveCurrentAuthUser: _authBoxInstance.put (user.id ile) başarıyla tamamlandı - Key: $_userKey');
    } catch (e, s) {
      print('[HiveService] saveCurrentAuthUser: Mevcut kullanıcı IDsi kaydedilirken HATA oluştu - $e');
      print('[HiveService] saveCurrentAuthUser: StackTrace - $s');
      rethrow;
    }
  }

  static UserModel? getCurrentUser() {
    print('[HiveService] getCurrentUser: Mevcut kullanıcı IDsi alınıyor - Key: $_userKey');
    final String? userId = _authBoxInstance.get(_userKey);
    print('[HiveService] getCurrentUser: Alınan User ID - $userId');
    if (userId != null) {
      print('[HiveService] getCurrentUser: _userBoxInstance.get çağrılıyor - Key: $userId');
      final user = _userBoxInstance.get(userId);
      print('[HiveService] getCurrentUser: Getirilen kullanıcı - ${user?.email}');
      return user;
    }
    print('[HiveService] getCurrentUser: User ID bulunamadı.');
    return null;
  }

  static UserModel? getUser(String id) {
    return _userBoxInstance.get(id);
  }

  static List<UserModel> getAllUsers() {
    return _userBoxInstance.values.toList();
  }

  static Future<void> deleteUser(String id) async {
    await _userBoxInstance.delete(id);
    if (getCurrentUser()?.id == id) {
      await _authBoxInstance.delete(_userKey);
    }
  }

  // Token işlemleri
  static Future<void> saveToken(String token) async {
    await _authBoxInstance.put(_tokenKey, token);
    await _authBoxInstance.put(_isLoggedInKey, true);
  }

  static String? getToken() {
    return _authBoxInstance.get(_tokenKey);
  }
  
  static Future<void> deleteToken() async {
    await _authBoxInstance.delete(_tokenKey);
    await _authBoxInstance.put(_isLoggedInKey, false);
  }

  // Oturum durumu
  static bool isLoggedIn() {
    return _authBoxInstance.get(_isLoggedInKey, defaultValue: false) ?? false;
  }

  static Future<void> logout() async {
    await _authBoxInstance.delete(_userKey);
    await deleteToken();
  }

  // Box'ı temizle (testler için)
  static Future<void> clearBox() async {
    await _authBoxInstance.clear();
    await _userBoxInstance.clear();
  }
}
