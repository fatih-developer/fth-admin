import 'package:hive/hive.dart';
import 'package:fth_admin/core/models/user_model.dart';
import 'package:fth_admin/core/services/logger_service.dart';

class HiveService {
  static const String userBoxName = 'user_data_box';
  static const String tokenBoxName = 'auth_token_box';
  static const String userKey = 'current_active_user';
  static const String tokenKey = 'session_auth_token';
  
  static const String _internalAuthBox = 'internal_auth_details_box';
  static const String _internalUserStorageBox = 'internal_user_storage_box';

  static Future<void> init() async {
    if (!Hive.isAdapterRegistered(UserModelAdapter().typeId)) {
      Hive.registerAdapter(UserModelAdapter());
    }

    await Hive.openBox<String>(userBoxName); 
    await Hive.openBox<String>(tokenBoxName); 

    LoggerService.info("[HiveService] Hive başlatıldı ve ana kutular açıldı.");
  }

  static Future<T?> getData<T>(String boxName, dynamic key) async {
    try {
      final box = await Hive.openBox<T>(boxName);
      LoggerService.debug('[HiveService] getData - Box: $boxName, Key: $key');
      if (!box.isOpen) {
        LoggerService.info('[HiveService] getData - Box $boxName kapalıydı, yeniden açılıyor.');
        await Hive.openBox<T>(boxName); 
      }
      return box.get(key);
    } catch (e,s) {
      LoggerService.error('[HiveService] getData HATA - Box: $boxName, Key: $key', e, s);
      return null;
    }
  }

  static Future<void> putData<T>(String boxName, dynamic key, T value) async {
    try {
      final box = await Hive.openBox<T>(boxName);
      LoggerService.debug('[HiveService] putData - Box: $boxName, Key: $key');
      if (!box.isOpen) {
        LoggerService.info('[HiveService] putData - Box $boxName kapalıydı, yeniden açılıyor.');
        await Hive.openBox<T>(boxName); 
      }
      await box.put(key, value);
    } catch (e,s) {
      LoggerService.error('[HiveService] putData HATA - Box: $boxName, Key: $key', e, s);
      rethrow; 
    }
  }

  static Future<void> deleteData(String boxName, dynamic key) async {
    try {
      final box = await Hive.openBox(boxName); 
      LoggerService.debug('[HiveService] deleteData - Box: $boxName, Key: $key');
      if (!box.isOpen) {
        LoggerService.info('[HiveService] deleteData - Box $boxName kapalıydı, yeniden açılıyor.');
        await Hive.openBox(boxName); 
      }
      await box.delete(key);
    } catch (e,s) {
      LoggerService.error('[HiveService] deleteData HATA - Box: $boxName, Key: $key', e, s);
      rethrow;
    }
  }
  
  static Future<void> clearSpecificBox(String boxName) async {
    try {
      final box = await Hive.openBox(boxName);
      await box.clear();
      LoggerService.info('[HiveService] clearSpecificBox - Box: $boxName temizlendi.');
    } catch (e,s) {
      LoggerService.error('[HiveService] clearSpecificBox HATA - Box: $boxName', e, s);
    }
  }

  static Future<void> clearAllKnownBoxes() async {
    LoggerService.info('[HiveService] clearAllKnownBoxes: Bilinen tüm kutular temizleniyor!');
    await clearSpecificBox(userBoxName);
    await clearSpecificBox(tokenBoxName);
    await clearSpecificBox(_internalUserStorageBox); 
    await clearSpecificBox(_internalAuthBox);      
    LoggerService.info("[HiveService] Bilinen tüm Hive kutuları temizlendi.");
  }

  static Future<void> deleteAllHiveDataForAppFromDisk() async {
    LoggerService.error('[HiveService] deleteAllHiveDataForAppFromDisk: TÜM HIVE VERİLERİ DİSKTEN SİLİNİYOR!');
    try {
      await Hive.deleteBoxFromDisk(userBoxName);
      await Hive.deleteBoxFromDisk(tokenBoxName);
      await Hive.deleteBoxFromDisk(_internalUserStorageBox);
      await Hive.deleteBoxFromDisk(_internalAuthBox);
      LoggerService.info("[HiveService] Tüm bilinen Hive kutuları diskten silindi. Uygulamanın yeniden başlatılması ve Hive.init() çağrılması gerekebilir.");
    } catch (e, s) {
       LoggerService.error('[HiveService] deleteAllHiveDataForAppFromDisk HATA', e, s);
    }
  }
}
