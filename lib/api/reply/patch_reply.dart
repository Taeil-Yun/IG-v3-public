import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class PatchReplyAPI {
  Future<PatchReplyAPIResponseModel> replyPatch(
      {required String? accessToken,
      required int replyIndex,
      required String content}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/community/reply');

    final response = await InterceptorHelper().client.patch(
          baseUri,
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $accessToken",
          },
          body: json.encode({
            'reply_index': replyIndex,
            'content': content,
          }),
        );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return PatchReplyAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return PatchReplyAPI().replyPatch(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          replyIndex: replyIndex,
          content: content);
    } else {
      throw Exception(response.body);
    }
  }
}

class PatchReplyAPIResponseModel {
  dynamic result;

  PatchReplyAPIResponseModel({
    this.result,
  });

  factory PatchReplyAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return PatchReplyAPIResponseModel(
      result: data,
    );
  }
}
