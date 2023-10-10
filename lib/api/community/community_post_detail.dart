import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class CommunityPostDetailAPI {
  Future<CommunityPostDetailAPIResponseModel> postDetail(
      {required String? accessToken, required int communityIndex}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/community/detail?community_index=$communityIndex');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return CommunityPostDetailAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return CommunityPostDetailAPI().postDetail(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          communityIndex: communityIndex);
    } else {
      throw Exception(response.body);
    }
  }
}

class CommunityPostDetailAPIResponseModel {
  dynamic result;

  CommunityPostDetailAPIResponseModel({
    this.result,
  });

  factory CommunityPostDetailAPIResponseModel.fromJson(
      Map<String, dynamic> data) {
    return CommunityPostDetailAPIResponseModel(
      result: data,
    );
  }
}
