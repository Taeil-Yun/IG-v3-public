import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class AddLikeAPI {
  Future<AddLikeAPIResponseModel> addLike(
      {required String? accessToken, required int communityIndex}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/community/addlike');

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

      return AddLikeAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return AddLikeAPI().addLike(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          communityIndex: communityIndex);
    } else {
      throw Exception(response.body);
    }
  }
}

class AddLikeAPIResponseModel {
  dynamic result;

  AddLikeAPIResponseModel({
    this.result,
  });

  factory AddLikeAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return AddLikeAPIResponseModel(
      result: data,
    );
  }
}
