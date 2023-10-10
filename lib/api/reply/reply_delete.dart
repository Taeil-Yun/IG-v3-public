import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class ReplyDeleteAPI {
  Future<ReplyDeleteAPIResponseModel> replyDelete(
      {required String? accessToken, required int replyIndex}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/community/reply');

    final response = await InterceptorHelper().client.delete(
          baseUri,
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $accessToken",
          },
          body: json.encode({
            'reply_index': replyIndex,
          }),
        );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return ReplyDeleteAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return ReplyDeleteAPI().replyDelete(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          replyIndex: replyIndex);
    } else {
      throw Exception(response.body);
    }
  }
}

class ReplyDeleteAPIResponseModel {
  dynamic result;

  ReplyDeleteAPIResponseModel({
    this.result,
  });

  factory ReplyDeleteAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return ReplyDeleteAPIResponseModel(
      result: data,
    );
  }
}
