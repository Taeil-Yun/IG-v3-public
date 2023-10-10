import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:ig-public_v3/costant/build_config.dart';

class ig-publicLoginWithFacebookAPI {
  Future<ig-publicLoginWithFacebookAPIResponseModel> facebook({required String fbToken, required String fcmToken}) async {
    final baseUri = Uri.parse('${ig-publicBuildConfig.instance?.baseUrl}/auth/facebook/${Platform.isAndroid ? 'android' : 'ios'}');

    final response = await http.post(
      baseUri,
      headers: {
        // "Content-Type" : "application/json",
      },
      body: {
        "id_token": fbToken,
        "fcm_token": fcmToken,
      },
    );

    if (response.statusCode == 200) {
      // print('data: ${response.body}');

      return ig-publicLoginWithFacebookAPIResponseModel.fromJson(json.decode(utf8.decode(response.bodyBytes.toList())));
    } else {
      throw Exception(response.body);
    }
  }
}

class ig-publicLoginWithFacebookAPIResponseModel {
  dynamic result;

  ig-publicLoginWithFacebookAPIResponseModel({
    this.result,
  });

  factory ig-publicLoginWithFacebookAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return ig-publicLoginWithFacebookAPIResponseModel(
      result: data,
    );
  }
}