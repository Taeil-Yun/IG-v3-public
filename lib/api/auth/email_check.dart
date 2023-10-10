import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ig-public_v3/costant/build_config.dart';

class EmailCheckAPI {
  Future<EmailCheckAPIResponseModel> emailCheck({required String email}) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/sign/email');

    final response = await http.post(
      baseUri,
      headers: {
        // "Content-Type" : "application/json",
      },
      body: {
        'email': email,
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return EmailCheckAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else {
      throw Exception(response.body);
    }
  }
}

class EmailCheckAPIResponseModel {
  dynamic result;

  EmailCheckAPIResponseModel({
    this.result,
  });

  factory EmailCheckAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return EmailCheckAPIResponseModel(
      result: data,
    );
  }
}
