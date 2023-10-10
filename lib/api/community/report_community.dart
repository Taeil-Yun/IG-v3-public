import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class ReportCommunity {
  Future<ReportCommunityResponseModel> reportCommunity(
      {required String? accessToken,
      required int communityIndex,
      required int type,
      required String description}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/community/report');

    final response = await InterceptorHelper().client.post(
          baseUri,
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $accessToken",
          },
          body: json.encode({
            'community_index': communityIndex,
            'type': type,
            'description': description,
          }),
        );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return ReportCommunityResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return ReportCommunity().reportCommunity(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          communityIndex: communityIndex,
          type: type,
          description: description);
    } else {
      throw Exception(response.body);
    }
  }
}

class ReportCommunityResponseModel {
  dynamic result;

  ReportCommunityResponseModel({
    this.result,
  });

  factory ReportCommunityResponseModel.fromJson(Map<String, dynamic> data) {
    return ReportCommunityResponseModel(
      result: data,
    );
  }
}
