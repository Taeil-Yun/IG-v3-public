import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/main.dart';

class RefreshTokenAPI {
  Future<RefreshTokenAPIResponseModel> refresh(
      {required String accesToken, required String refreshToken}) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/auth/refresh');

    final response = await http.post(
      baseUri,
      headers: {
        // "authorization" : "Bearer ${await SecureStorageConfig().storage.read(key: 'access_token')}",
        // "ig-public-access" : '${await SecureStorageConfig().storage.read(key: 'refresh_token')}',
        "authorization": "Bearer $refreshToken",
        "ig-public-access": accesToken,
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return RefreshTokenAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      SecureStorageConfig().storage.delete(key: 'access_token');
      SecureStorageConfig().storage.delete(key: 'refresh_token');

      navigatorKey.currentState
          ?.pushNamedAndRemoveUntil('login', (route) => false);

      return RefreshTokenAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else {
      SecureStorageConfig().storage.delete(key: 'access_token');
      SecureStorageConfig().storage.delete(key: 'refresh_token');

      navigatorKey.currentState
          ?.pushNamedAndRemoveUntil('login', (route) => false);

      return RefreshTokenAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
      // throw Exception(response.body);
    }
  }
}

class RefreshTokenAPIResponseModel {
  dynamic result;

  RefreshTokenAPIResponseModel({
    this.result,
  });

  factory RefreshTokenAPIResponseModel.fromJson(Map<dynamic, dynamic> data) {
    return RefreshTokenAPIResponseModel(
      result: data,
    );
  }
}
