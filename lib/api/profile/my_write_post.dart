import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class MyWritingPostAPI {
  Future<MyWritingPostAPIResponseModel> post(
      {required String? accessToken}) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/my/community');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return MyWritingPostAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return MyWritingPostAPI().post(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'));
    } else {
      throw Exception(response.body);
    }
  }
}

class MyWritingPostAPIResponseModel {
  dynamic result;

  MyWritingPostAPIResponseModel({
    this.result,
  });

  factory MyWritingPostAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return MyWritingPostAPIResponseModel(
      result: data,
    );
  }
}
