import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class AddBlackListAPI {
  Future<AddBlackListAPIResponseModel> blacklistAdd(
      {required String? accessToken, required int userIndex}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/user/add_block_user');

    final response = await InterceptorHelper().client.post(
          baseUri,
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $accessToken",
          },
          body: json.encode({
            'user_index': userIndex,
          }),
        );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return AddBlackListAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return AddBlackListAPI().blacklistAdd(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          userIndex: userIndex);
    } else {
      throw Exception(response.body);
    }
  }
}

class AddBlackListAPIResponseModel {
  dynamic result;

  AddBlackListAPIResponseModel({
    this.result,
  });

  factory AddBlackListAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return AddBlackListAPIResponseModel(
      result: data,
    );
  }
}
