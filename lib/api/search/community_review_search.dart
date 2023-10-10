import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class CommunityReviewSearchAPI {
  Future<CommunityReviewSearchAPIResponseModel> reviewSearch(
      {required String? accessToken, String? keyword}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/show/search_review_show${keyword != null ? '?keyword=$keyword' : ''}');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return CommunityReviewSearchAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return CommunityReviewSearchAPI().reviewSearch(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          keyword: keyword);
    } else {
      throw Exception(response.body);
    }
  }
}

class CommunityReviewSearchAPIResponseModel {
  dynamic result;

  CommunityReviewSearchAPIResponseModel({
    this.result,
  });

  factory CommunityReviewSearchAPIResponseModel.fromJson(
      Map<String, dynamic> data) {
    return CommunityReviewSearchAPIResponseModel(
      result: data,
    );
  }
}
