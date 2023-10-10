import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class WriteReplyAPI {
  Future<WriteReplyAPIResponseModel> writeReply(
      {required String? accessToken,
      required int communityIndex,
      int? parentIndex,
      required String content}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/community/reply');

    final response = await InterceptorHelper().client.post(
          baseUri,
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $accessToken",
          },
          body: parentIndex != null
              ? json.encode({
                  'community_index': communityIndex,
                  'parent_index': parentIndex,
                  'content': content,
                })
              : json.encode({
                  'community_index': communityIndex,
                  'content': content,
                }),
        );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return WriteReplyAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return WriteReplyAPI().writeReply(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          communityIndex: communityIndex,
          parentIndex: parentIndex,
          content: content);
    } else {
      throw Exception(response.body);
    }
  }
}

class WriteReplyAPIResponseModel {
  dynamic result;

  WriteReplyAPIResponseModel({
    this.result,
  });

  factory WriteReplyAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return WriteReplyAPIResponseModel(
      result: data,
    );
  }
}
