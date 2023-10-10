import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class CommunityBestReviewListAPI {
  Future<CommunityBestReviewListAPIResponseModel> bestReview(
      {required String? accessToken}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/community/review');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return CommunityBestReviewListAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return CommunityBestReviewListAPI().bestReview(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'));
    } else {
      throw Exception(response.body);
    }
  }
}

class CommunityBestReviewListAPIResponseModel {
  dynamic result;

  CommunityBestReviewListAPIResponseModel({
    this.result,
  });

  factory CommunityBestReviewListAPIResponseModel.fromJson(
      Map<String, dynamic> data) {
    return CommunityBestReviewListAPIResponseModel(
      result: data,
    );
  }
}
