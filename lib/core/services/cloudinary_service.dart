import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  return CloudinaryService();
});

/// Service untuk mengunggah gambar ke Cloudinary.
///
/// Kredensial diambil dari compile-time constants (--dart-define) agar
/// tidak bocor ke repositori publik.
class CloudinaryService {
  // Kredensial Cloudinary dari compile-time constants.
  // Default value disediakan agar app tetap berjalan tanpa --dart-define.
  // Di production, gunakan: flutter run --dart-define=CLOUDINARY_CLOUD_NAME=xxx
  static const String _cloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: 'dzl0dstef',
  );
  static const String _uploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: 'ignisave_uploads',
  );

  /// Mengecek apakah kredensial Cloudinary sudah dikonfigurasi
  bool get isConfigured => _cloudName.isNotEmpty && _uploadPreset.isNotEmpty;

  Future<String?> uploadImage(File imageFile) async {
    // Validasi kredensial sebelum mengirim request
    if (!isConfigured) {
      debugPrint(
        'CloudinaryService: Kredensial belum dikonfigurasi! '
        'Gunakan --dart-define saat build.',
      );
      return null;
    }

    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(responseString);
        if (kDebugMode) {
          debugPrint('CloudinaryService: Upload berhasil');
        }
        return jsonMap['secure_url'];
      } else {
        if (kDebugMode) {
          debugPrint(
            'CloudinaryService: Upload gagal (${response.statusCode})',
          );
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('CloudinaryService: Error: $e');
      }
      return null;
    }
  }

  Future<String?> uploadProfilePhoto(File imageFile) async {
    return uploadImage(imageFile);
  }

  Future<String?> uploadProofImage(File imageFile) async {
    return uploadImage(imageFile);
  }
}
