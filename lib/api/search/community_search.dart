import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class CommunitySearchAPI {
  Future<CommunitySearchAPIResponseModel> communitySearch(
      {required String? accessToken, required String keyword}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/community/search?keyword=$keyword');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return CommunitySearchAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return CommunitySearchAPI().communitySearch(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          keyword: keyword);
    } else {
      throw Exception(response.body);
    }
  }
}

class CommunitySearchAPIResponseModel {
  dynamic result;

  CommunitySearchAPIResponseModel({
    this.result,
  });

  factory CommunitySearchAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return CommunitySearchAPIResponseModel(
      result: data,
    );
  }
}
