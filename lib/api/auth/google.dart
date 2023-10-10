import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:ig-public_v3/costant/build_config.dart';

class ig-publicLoginWithGoogleAPI {
  Future<ig-publicLoginWithGoogleAPIResponseModel> google({required String idToken, required String fcmToken}) async {
    final baseUri = Uri.parse('${ig-publicBuildConfig.instance?.baseUrl}/auth/google/${Platform.isAndroid ? 'android' : 'ios'}');

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

      return ig-publicLoginWithGoogleAPIResponseModel.fromJson(json.decode(utf8.decode(response.bodyBytes.toList())));
    } else {
      throw Exception(response.body);
    }
  }
}

class ig-publicLoginWithGoogleAPIResponseModel {
  dynamic result;

  ig-publicLoginWithGoogleAPIResponseModel({
    this.result,
  });

  factory ig-publicLoginWithGoogleAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return ig-publicLoginWithGoogleAPIResponseModel(
      result: data,
    );
  }
}
