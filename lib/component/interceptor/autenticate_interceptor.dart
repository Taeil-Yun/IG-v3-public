import 'dart:developer';

import 'package:http_interceptor/http_interceptor.dart';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/api/auth/refresh.dart';
import 'package:ig-public_v3/main.dart';

class AuthenticateInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    try {
      //   data.headers.clear();
      //   data.headers['authorization'] = 'Bearer ' + token;
      //   data.headers['content-type'] = 'application/json';
    } catch (e) {
      log('$e');
    }
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    return data;
  }
}

class ExpiredTokenRetryPolicy extends RetryPolicy {
  @override
  // ignore: overridden_fields
  int maxRetryAttempts = 2;

  @override
  Future<bool> shouldAttemptRetryOnResponse(ResponseData response) async {
    final String accessToken =
        await SecureStorageConfig().storage.read(key: 'access_token') ?? '';
    final String refreshToken =
        await SecureStorageConfig().storage.read(key: 'refresh_token') ?? '';

    // SecureStorageConfig().storage.write(key: 'access_token', value: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJraW5kIjoiYXBwIiwiYXVkIjoiYXBwLmktZ2V0LmJpeiIsImlzcyI6Imh0dHBzOi8vYXBwLmktZ2V0LmJpeiIsImlhdCI6MTY4MTQzNzg1OCwiZXhwIjoxNjgxNDgxMDU4fQ.5ohxrg1TCJfYa0QgTeTGW4v0OzGu0uZsmsdA2MWUNCU');
    // SecureStorageConfig().storage.write(key: 'refresh_token', value: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJraW5kIjoiYXBwIiwiYXVkIjoiYXBwLmktZ2V0LmJpeiIsImlzcyI6Imh0dHBzOi8vYXBwLmktZ2V0LmJpeiIsImlhdCI6MTY4MTQzNzg1OCwiZXhwIjoxNjg5MjEzODU4fQ.WF-s3scmlWsCjPiLKTsHvSMs7of4BM_r9CFk2pq6oEI');

    if (response.statusCode == 402) {
      // Perform your token refresh here.
      if (await SecureStorageConfig().storage.read(key: 'token_status') ==
          'false') {
        await RefreshTokenAPI()
            .refresh(accesToken: accessToken, refreshToken: refreshToken)
            .then((refresh) async {
          if (refresh.result['status'] == 1) {
            await SecureStorageConfig().storage.write(
                key: 'access_token',
                value: refresh.result['data']['access_token']);
            await SecureStorageConfig().storage.write(
                key: 'refresh_token',
                value: refresh.result['data']['refresh_token']);
          }
          // else {
          //   Future.wait([
          //     SecureStorageConfig().storage.delete(key: 'access_token'),
          //     SecureStorageConfig().storage.delete(key: 'refresh_token'),
          //   ]).then((_) async {
          //     if (await SecureStorageConfig().storage.read(key: 'token_status') == 'false') {
          //       navigatorKey.currentState?.pushNamedAndRemoveUntil('login', (route) => false);
          //       await SecureStorageConfig().storage.write(key: 'token_status', value: 'true');
          //     }
          //   });
          // }
        });
      }

      return true;
    }

    return false;
  }
}
