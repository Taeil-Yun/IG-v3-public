import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class GetNoticeDetailAPI {
  Future<GetNoticeDetailAPIResponseModel> noticeDetail(
      {required String? accessToken, required int bbsIndex}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/bbs/detail?bbs_index=$bbsIndex');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return GetNoticeDetailAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return GetNoticeDetailAPI().noticeDetail(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          bbsIndex: bbsIndex);
    } else {
      throw Exception(response.body);
    }
  }
}

class GetNoticeDetailAPIResponseModel {
  dynamic result;

  GetNoticeDetailAPIResponseModel({
    this.result,
  });

  factory GetNoticeDetailAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return GetNoticeDetailAPIResponseModel(
      result: data,
    );
  }
}
