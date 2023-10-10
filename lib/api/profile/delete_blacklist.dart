import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class DeleteBlackListAPI {
  Future<DeleteBlackListAPIResponseModel> blacklistDelete(
      {required String? accessToken, required int userIndex}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/user/remove_block_user');

    final response = await InterceptorHelper().client.delete(
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

      return DeleteBlackListAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return DeleteBlackListAPI().blacklistDelete(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          userIndex: userIndex);
    } else {
      throw Exception(response.body);
    }
  }
}

class DeleteBlackListAPIResponseModel {
  dynamic result;

  DeleteBlackListAPIResponseModel({
    this.result,
  });

  factory DeleteBlackListAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return DeleteBlackListAPIResponseModel(
      result: data,
    );
  }
}
