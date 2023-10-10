import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class BlackListDataAPI {
  Future<BlackListDataAPIResponseModel> blacklist(
      {required String? accessToken}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/user/block_user_list');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return BlackListDataAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return BlackListDataAPI().blacklist(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'));
    } else {
      throw Exception(response.body);
    }
  }
}

class BlackListDataAPIResponseModel {
  dynamic result;

  BlackListDataAPIResponseModel({
    this.result,
  });

  factory BlackListDataAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return BlackListDataAPIResponseModel(
      result: data,
    );
  }
}
