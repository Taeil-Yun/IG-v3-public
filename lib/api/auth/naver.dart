import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:ig-public_v3/costant/build_config.dart';

class ig-publicLoginWithNaverAPI {
  Future<ig-publicLoginWithNaverAPIResponseModel> naver({required String naverToken, required String fcmToken}) async {
    final baseUri = Uri.parse('${ig-publicBuildConfig.instance?.baseUrl}/auth/naver/${Platform.isAndroid ? 'android' : 'ios'}');

    final response = await http.post(
      baseUri,
      headers: {
        // "Content-Type" : "application/json",
      },
      body: {
        "access_token": naverToken,
        "fcm_token": fcmToken,
      }

    );

    if (response.statusCode == 200) {
      // print('data: ${response.body}');

      return ig-publicLoginWithNaverAPIResponseModel.fromJson(json.decode(utf8.decode(response.bodyBytes.toList())));
    } else {
      throw Exception(response.body);
    }
  }
}

class ig-publicLoginWithNaverAPIResponseModel {
  dynamic result;

  ig-publicLoginWithNaverAPIResponseModel({
    this.result,
  });

  factory ig-publicLoginWithNaverAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return ig-publicLoginWithNaverAPIResponseModel(
      result: data,
    );
  }
}