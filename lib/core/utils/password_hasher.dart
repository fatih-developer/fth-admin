import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class PasswordHasher {
  // Rastgele tuz oluştur
  static String generateSalt([int length = 32]) {
    final random = Random.secure();
    final saltBytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Url.encode(saltBytes);
  }

  // Şifreyi hashle
  static String hashPassword(String password, String salt) {
    final codec = Utf8Codec();
    final key = codec.encode(password);
    final saltBytes = codec.encode(salt);
    
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(saltBytes);
    
    return digest.toString();
  }

  // Şifre doğrulama
  static bool verifyPassword(
    String enteredPassword, 
    String storedHash, 
    String storedSalt,
  ) {
    final hashedPassword = hashPassword(enteredPassword, storedSalt);
    return hashedPassword == storedHash;
  }
}
