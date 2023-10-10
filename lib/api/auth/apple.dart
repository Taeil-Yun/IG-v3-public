import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:ig-public_v3/costant/build_config.dart';

class ig-publicLoginWithAppleAPI {
  Future<ig-publicLoginWithAppleAPIResponseModel> apple({String? idToken, required String fcmToken}) async {
    final baseUri = Uri.parse('${ig-publicBuildConfig.instance?.baseUrl}/auth/apple/${Platform.isAndroid ? 'android' : 'ios'}');

    final response = await http.post(
      baseUri,
      headers: {
        // "Content-Type" : "application/json",
      },
      body: {
        "id_token": idToken,
        "fcm_token": fcmToken,
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return ig-publicLoginWithAppleAPIResponseModel.fromJson(json.decode(utf8.decode(response.bodyBytes.toList())));
    } else {
      throw Exception(response.body);
    }
  }
}

class ig-publicLoginWithAppleAPIResponseModel {
  dynamic result;

  ig-publicLoginWithAppleAPIResponseModel({
    this.result,
  });

  factory ig-publicLoginWithAppleAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return ig-publicLoginWithAppleAPIResponseModel(
      result: data,
    );
  }
}
