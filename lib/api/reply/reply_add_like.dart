import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class ReplyAddLikeAPI {
  Future<ReplyAddLikeAPIResponseModel> replyAddLike(
      {required String? accessToken, required int replyIndex}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/community/add_reply_like');

    final response = await InterceptorHelper().client.post(
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

      return ReplyAddLikeAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return ReplyAddLikeAPI().replyAddLike(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          replyIndex: replyIndex);
    } else {
      throw Exception(response.body);
    }
  }
}

class ReplyAddLikeAPIResponseModel {
  dynamic result;

  ReplyAddLikeAPIResponseModel({
    this.result,
  });

  factory ReplyAddLikeAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return ReplyAddLikeAPIResponseModel(
      result: data,
    );
  }
}
