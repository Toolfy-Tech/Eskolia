import 'package:shared_preferences/shared_preferences.dart';
import 'eskolia_folder_service_common.dart';

class EskoliaFolderService {
  EskoliaFolderService._();
  static final EskoliaFolderService instance = EskoliaFolderService._();

  bool get isSupported => false;

  Future<bool> pickFolder() async => false;
  Future<bool> hasFolder() async => false;
  Future<String?> getFolderName() async => null;

  Future<void> saveFile(
    EskoliaFolder folder,
    String filename,
    String content, {
    String mimeType = 'application/octet-stream',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final prefKey = 'eskolia_virtual_fs:${folder.folderName}:$filename';
    await prefs.setString(prefKey, content);
  }

  Future<List<String>> listFiles(EskoliaFolder folder) async {
    final prefs = await SharedPreferences.getInstance();
    final prefix = 'eskolia_virtual_fs:${folder.folderName}:';
    final keys = prefs.getKeys();
    final List<String> files = [];
    for (final key in keys) {
      if (key.startsWith(prefix)) {
        files.add(key.substring(prefix.length));
      }
    }
    return files;
  }

  Future<String?> readFile(EskoliaFolder folder, String filename) async {
    final prefs = await SharedPreferences.getInstance();
    final prefKey = 'eskolia_virtual_fs:${folder.folderName}:$filename';
    return prefs.getString(prefKey);
  }

  Future<void> forgetFolder() async {}
}
