import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class ReplyCancelLikeAPI {
  Future<ReplyCancelLikeAPIResponseModel> replyCancelLike(
      {required String? accessToken, required int replyIndex}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/community/cancel_reply_like');

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

      return ReplyCancelLikeAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return ReplyCancelLikeAPI().replyCancelLike(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          replyIndex: replyIndex);
    } else {
      throw Exception(response.body);
    }
  }
}

class ReplyCancelLikeAPIResponseModel {
  dynamic result;

  ReplyCancelLikeAPIResponseModel({
    this.result,
  });

  factory ReplyCancelLikeAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return ReplyCancelLikeAPIResponseModel(
      result: data,
    );
  }
}
