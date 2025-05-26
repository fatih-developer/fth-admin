import 'package:logger/logger.dart';

class LoggerService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1, // Sadece 1 metot gösterilir
      errorMethodCount: 8, // Hata durumunda daha fazla stack trace gösterilir
      lineLength: 120, // Satır uzunluğu
      colors: true, // Renkli loglar
      printEmojis: true, // Emoji ikonları
      printTime: true, // Zaman damgası
    ),
    // İsterseniz log seviyesini buradan ayarlayabilirsiniz:
    // level: Level.debug, 
  );

  static Logger get logger => _logger;

  // Kolay erişim için kısayol metotları (isteğe bağlı)
  static void verbose(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.v(message, error: error, stackTrace: stackTrace);
  }

  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}
