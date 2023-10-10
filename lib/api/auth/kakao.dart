import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import 'package:ig-public_v3/costant/build_config.dart';

class ig-publicLoginWithKakaoAPI {
  Future<ig-publicLoginWithKakaoAPIResponseModel> kakao({String? idToken, required String fcmToken, required Account? profile}) async {
    final baseUri = Uri.parse('${ig-publicBuildConfig.instance?.baseUrl}/auth/kakao/${Platform.isAndroid ? 'android' : 'ios'}');
    
    final response = await http.post(
      baseUri,
      headers: {
        "Content-Type" : "application/json",
      },
      body: json.encode({
        "id_token": idToken,
        "fcm_token": fcmToken,
        "profile": profile.toString(),
      }),
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return ig-publicLoginWithKakaoAPIResponseModel.fromJson(json.decode(utf8.decode(response.bodyBytes.toList())));
    } else {
      throw Exception(response.body);
    }
  }
}

class ig-publicLoginWithKakaoAPIResponseModel {
  dynamic result;

  ig-publicLoginWithKakaoAPIResponseModel({
    this.result,
  });

  factory ig-publicLoginWithKakaoAPIResponseModel.fromJson(Map<dynamic, dynamic> data) {
    return ig-publicLoginWithKakaoAPIResponseModel(
      result: data,
    );
  }
}