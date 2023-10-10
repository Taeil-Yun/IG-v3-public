import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class AllFollowListAPI {
  Future<AllFollowListAPIResponseModel> allFollows(
      {required String? accessToken}) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/follow');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return AllFollowListAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return AllFollowListAPI().allFollows(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'));
    } else {
      throw Exception(response.body);
    }
  }
}

class AllFollowListAPIResponseModel {
  dynamic result;

  AllFollowListAPIResponseModel({
    this.result,
  });

  factory AllFollowListAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return AllFollowListAPIResponseModel(
      result: data,
    );
  }
}
