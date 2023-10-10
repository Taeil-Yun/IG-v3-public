import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class OtherUserProfileAPI {
  Future<OtherUserProfileAPIResponseModel> otherUserProfile(
      {required String? accessToken, required int userIndex}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/user?user_index=$userIndex');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return OtherUserProfileAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return OtherUserProfileAPI().otherUserProfile(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          userIndex: userIndex);
    } else {
      throw Exception(response.body);
    }
  }
}

class OtherUserProfileAPIResponseModel {
  dynamic result;

  OtherUserProfileAPIResponseModel({
    this.result,
  });

  factory OtherUserProfileAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return OtherUserProfileAPIResponseModel(
      result: data,
    );
  }
}
