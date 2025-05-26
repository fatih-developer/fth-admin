import 'package:fth_admin/core/models/user_model.dart';
import 'package:fth_admin/core/services/hive_service.dart';
import 'package:fth_admin/core/utils/password_hasher.dart';
import 'package:uuid/uuid.dart';

class AuthLocalDataSource {
  final _uuid = const Uuid();

  Future<UserModel?> login(String email, String password) async {
    final users = HiveService.getAllUsers();
    print('[AuthLocalDataSource] Login: Kullanıcılar getirildi, Sayı: ${users.length}');
    
    for (final user in users) {
      print('[AuthLocalDataSource] Login: Kullanıcı kontrol ediliyor - Email: ${user.email}');
      if (user.email == email) {
        print('[AuthLocalDataSource] Login: E-posta eşleşti - ${user.email}');
        final isPasswordValid = PasswordHasher.verifyPassword(
          password,
          user.passwordHash,
          user.salt,
        );
        print('[AuthLocalDataSource] Login: Şifre doğrulama sonucu - $isPasswordValid');

        if (isPasswordValid) {
          print('[AuthLocalDataSource] Login: Şifre doğrulandı. Kullanıcı güncelleniyor - ID: ${user.id}');
          // Son giriş zamanını güncelle
          user.lastLogin = DateTime.now();
          await user.save(); // UserModel'in kendi save metodunu kullan
          print('[AuthLocalDataSource] Login: user.save() başarıyla tamamlandı - ID: ${user.id}');
          
          // Güncel kullanıcıyı _authBox'a da kaydet (HiveService üzerinden değil, doğrudan)
          // Bu kısım için HiveService'e bir metod eklenebilir veya doğrudan erişim sağlanabilir.
          // Şimdilik doğrudan erişim varsayalım (eğer _authBoxInstance public ise)
          // VEYA HiveService'e _authBox'a özel bir saveCurrentUser metodu ekleyelim.
          // Şimdilik HiveService'e yeni bir metod ekleyerek ilerleyelim.
          await HiveService.saveCurrentAuthUser(user);
          print('[AuthLocalDataSource] Login: HiveService.saveCurrentAuthUser başarıyla tamamlandı - ID: ${user.id}');
          
          // Token oluştur ve kaydet
          print('[AuthLocalDataSource] Login: Token oluşturuluyor ve kaydediliyor - User ID: ${user.id}');
          final token = _generateToken(user.id);
          await HiveService.saveToken(token);
          print('[AuthLocalDataSource] Login: Token başarıyla kaydedildi - User ID: ${user.id}');
          
          return user;
        }
        print('[AuthLocalDataSource] Login: Şifre yanlış - Email: ${user.email}');
        break; // E-posta bulundu ama şifre yanlış, başka kullanıcıya bakmaya gerek yok
      }
    }
    print('[AuthLocalDataSource] Login: Kullanıcı bulunamadı veya şifre yanlış - Email: $email');
    return null;
  }

  Future<UserModel> register(String username, String email, String password) async {
    // E-posta adresinin benzersiz olduğunu kontrol et
    print('[AuthLocalDataSource] Register: E-posta kontrol ediliyor - $email');
    final users = HiveService.getAllUsers();
    if (users.any((user) => user.email == email)) {
      print('[AuthLocalDataSource] Register: E-posta zaten kullanımda - $email');
      throw Exception('Bu e-posta adresi zaten kullanılıyor');
    }

    // Yeni kullanıcı oluştur
    print('[AuthLocalDataSource] Register: Yeni kullanıcı oluşturuluyor - Username: $username, Email: $email');
    final userId = _uuid.v4();
    final salt = PasswordHasher.generateSalt();
    final passwordHash = PasswordHasher.hashPassword(password, salt);
    
    final user = UserModel(
      id: userId,
      username: username,
      email: email,
      passwordHash: passwordHash,
      salt: salt,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );
    print('[AuthLocalDataSource] Register: UserModel oluşturuldu - ID: ${user.id}');

    // Kullanıcıyı kaydet
    try {
      print('[AuthLocalDataSource] Register: HiveService.saveUser çağrılıyor - User ID: ${user.id}');
      await HiveService.saveUser(user);
      print('[AuthLocalDataSource] Register: HiveService.saveUser başarıyla tamamlandı - User ID: ${user.id}');
      
      // Token oluştur ve kaydet
      print('[AuthLocalDataSource] Register: Token oluşturuluyor ve kaydediliyor - User ID: ${user.id}');
      final token = _generateToken(userId);
      await HiveService.saveToken(token);
      print('[AuthLocalDataSource] Register: Token başarıyla kaydedildi - User ID: ${user.id}');
      
      return user;
    } catch (e, s) {
      print('[AuthLocalDataSource] Register: Kullanıcı kaydedilirken HATA oluştu - $e');
      print('[AuthLocalDataSource] Register: StackTrace - $s');
      rethrow;
    }
  }
  
  Future<void> logout() async {
    await HiveService.logout();
  }
  
  Future<void> clearAuthData() async {
    await HiveService.clearBox();
  }
  
  bool isLoggedIn() {
    return HiveService.isLoggedIn();
  }
  
  UserModel? getCurrentUser() {
    return HiveService.getCurrentUser();
  }
  
  String _generateToken(String userId) {
    // Basit bir token oluşturma (gerçek uygulamada daha güvenli bir yöntem kullanılmalıdır)
    return 'token_$userId';
  }
}
