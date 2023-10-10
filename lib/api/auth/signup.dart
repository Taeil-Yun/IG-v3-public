import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ig-public_v3/costant/build_config.dart';

class SignUpAPI {
  Future<SignUpAPIResponseModel> signup(
      {required String email,
      required String password,
      required String fcmToken,
      required int isMarketing}) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/sign/signup');

    final response = await http.post(
      baseUri,
      headers: {
        // "Content-Type" : "multipart/form-data",
      },
      body: {
        'email': email,
        'password': password,
        'is_marketing': isMarketing.toString(),
        'fcm_token': fcmToken,
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return SignUpAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else {
      throw Exception(response.body);
    }
  }
}

class SignUpAPIResponseModel {
  dynamic result;

  SignUpAPIResponseModel({
    this.result,
  });

  factory SignUpAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return SignUpAPIResponseModel(
      result: data,
    );
  }
}
