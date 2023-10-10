import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class CommunityRecommendListAPI {
  Future<CommunityRecommendListAPIResponseModel> list(
      {required String? accessToken}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/community/follow_recommend_list');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return CommunityRecommendListAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return CommunityRecommendListAPI().list(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'));
    } else {
      throw Exception(response.body);
    }
  }
}

class CommunityRecommendListAPIResponseModel {
  dynamic result;

  CommunityRecommendListAPIResponseModel({
    this.result,
  });

  factory CommunityRecommendListAPIResponseModel.fromJson(
      Map<String, dynamic> data) {
    return CommunityRecommendListAPIResponseModel(
      result: data,
    );
  }
}
