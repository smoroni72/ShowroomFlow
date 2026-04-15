import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class ImageCacheService {
  static final Dio _dio = Dio();

  /// 📂 path base
  static Future<Directory> _getBaseDir() async {
    final dir = await getTemporaryDirectory();
    return Directory('${dir.path}/images');
  }

  /// 📸 ottieni file locale (se esiste)
  static Future<File?> getImage(String url) async {
    final dir = await _getBaseDir();
    final fileName = url.hashCode.toString();
    final file = File('${dir.path}/$fileName');

    if (await file.exists()) {
      return file;
    }

    return null;
  }

  /// ⬇️ scarica e salva
  static Future<File?> downloadImage(String url) async {
    try {
      final dir = await _getBaseDir();

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final fileName = url.hashCode.toString();
      final file = File('${dir.path}/$fileName');

      final response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      await file.writeAsBytes(response.data);

      return file;
    } catch (_) {
      return null;
    }
  }

  /// 🧹 pulizia cache
  static Future<void> clearCache() async {
    final dir = await _getBaseDir();

    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
}