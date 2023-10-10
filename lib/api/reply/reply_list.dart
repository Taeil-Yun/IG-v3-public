import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class ReplyListAPI {
  Future<ReplyListAPIResponseModel> replyList(
      {required String? accessToken, required int communityIndex}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/community/reply?community_index=$communityIndex');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return ReplyListAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return ReplyListAPI().replyList(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          communityIndex: communityIndex);
    } else {
      throw Exception(response.body);
    }
  }
}

class ReplyListAPIResponseModel {
  dynamic result;

  ReplyListAPIResponseModel({
    this.result,
  });

  factory ReplyListAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return ReplyListAPIResponseModel(
      result: data,
    );
  }
}
