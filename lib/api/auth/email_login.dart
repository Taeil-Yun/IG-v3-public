import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ig-public_v3/costant/build_config.dart';

class EmailLoginAPI {
  Future<EmailLoginAPIResponseModel> login(
      {required String email,
      required String password,
      required String fcmToken}) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/sign/signin');

    final response = await http.post(
      baseUri,
      headers: {
        // "Content-Type" : "multipart/form-data",
      },
      body: {
        'email': email,
        'password': password,
        'fcm_token': fcmToken,
      },
    );

    print(response.statusCode);

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return EmailLoginAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else {
      throw Exception(response.body);
    }
  }
}

class EmailLoginAPIResponseModel {
  dynamic result;

  EmailLoginAPIResponseModel({
    this.result,
  });

  factory EmailLoginAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return EmailLoginAPIResponseModel(
      result: data,
    );
  }
}
