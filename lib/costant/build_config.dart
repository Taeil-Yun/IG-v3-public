import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ig-publicBuildConfig {
  final String baseUrl;
  final String acceessToken;
  String? buildType = '';

  ig-publicBuildConfig._dev()
      : baseUrl = 'https://a.ig-public.biz',
        acceessToken = '',
        buildType = 'dev';

  ig-publicBuildConfig._product()
      : baseUrl = 'https://a.ig-public.net',
        acceessToken = '',
        buildType = 'product';

  static ig-publicBuildConfig? instance;

  factory ig-publicBuildConfig(String? flavor) {
    if (flavor == 'dev') {
      instance = ig-publicBuildConfig._dev();
    } else if (flavor == 'product') {
      instance = ig-publicBuildConfig._product();
    } else {
      throw Exception("Unknown flaver : $flavor");
    }

    return instance!;
  }
}

class SecureStorageConfig {
  final FlutterSecureStorage storage;

  SecureStorageConfig._storage()
      : storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
        );

  static SecureStorageConfig? instance;

  factory SecureStorageConfig() {
    instance = SecureStorageConfig._storage();

    return instance!;
  }
}
