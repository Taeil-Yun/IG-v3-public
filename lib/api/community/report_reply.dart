import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class ReportReply {
  Future<ReportReplyResponseModel> reportReply(
      {required String? accessToken,
      required int replyIndex,
      required int type,
      required String description}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/community/reply_report');

    final response = await InterceptorHelper().client.post(
          baseUri,
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $accessToken",
          },
          body: json.encode({
            'reply_index': replyIndex,
            'type': type,
            'description': description,
          }),
        );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return ReportReplyResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return ReportReply().reportReply(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          replyIndex: replyIndex,
          type: type,
          description: description);
    } else {
      throw Exception(response.body);
    }
  }
}

class ReportReplyResponseModel {
  dynamic result;

  ReportReplyResponseModel({
    this.result,
  });

  factory ReportReplyResponseModel.fromJson(Map<String, dynamic> data) {
    return ReportReplyResponseModel(
      result: data,
    );
  }
}
