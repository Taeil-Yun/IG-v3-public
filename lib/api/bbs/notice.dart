import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class GetNoticeAPI {
  Future<GetNoticeAPIResponseModel> notice(
      {required String? accessToken}) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/bbs/notice');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return GetNoticeAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return GetNoticeAPI().notice(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'));
    } else {
      throw Exception(response.body);
    }
  }
}

class GetNoticeAPIResponseModel {
  dynamic result;

  GetNoticeAPIResponseModel({
    this.result,
  });

  factory GetNoticeAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return GetNoticeAPIResponseModel(
      result: data,
    );
  }
}
