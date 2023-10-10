import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class CommunityHotPostListAPI {
  Future<CommunityHotPostListAPIResponseModel> hot(
      {required String? accessToken}) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/community/hot');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return CommunityHotPostListAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return CommunityHotPostListAPI().hot(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'));
    } else {
      throw Exception(response.body);
    }
  }
}

class CommunityHotPostListAPIResponseModel {
  dynamic result;

  CommunityHotPostListAPIResponseModel({
    this.result,
  });

  factory CommunityHotPostListAPIResponseModel.fromJson(
      Map<String, dynamic> data) {
    return CommunityHotPostListAPIResponseModel(
      result: data,
    );
  }
}
