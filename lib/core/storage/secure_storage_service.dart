import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );
});

class SecureStorageService {
  SecureStorageService(this._storage);
  final FlutterSecureStorage _storage;

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(
      key: AppConstants.secureTokenKey,
      value: accessToken,
    );
    await _storage.write(
      key: AppConstants.secureRefreshKey,
      value: refreshToken,
    );
  }

  Future<String?> readAccessToken() =>
      _storage.read(key: AppConstants.secureTokenKey);

  Future<String?> readRefreshToken() =>
      _storage.read(key: AppConstants.secureRefreshKey);

  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.secureTokenKey);
    await _storage.delete(key: AppConstants.secureRefreshKey);
  }
}
