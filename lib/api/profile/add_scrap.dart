import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class AddScrapAPI {
  Future<AddScrapAPIResponseModel> addScrap(
      {required String? accessToken, required int communityIndex}) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/scrap');

    final response = await InterceptorHelper().client.post(
          baseUri,
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $accessToken",
          },
          body: json.encode({
            'community_index': communityIndex,
          }),
        );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return AddScrapAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return AddScrapAPI().addScrap(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          communityIndex: communityIndex);
    } else {
      throw Exception(response.body);
    }
  }
}

class AddScrapAPIResponseModel {
  dynamic result;

  AddScrapAPIResponseModel({
    this.result,
  });

  factory AddScrapAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return AddScrapAPIResponseModel(
      result: data,
    );
  }
}
