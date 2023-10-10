import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class WithDrawalAPI {
  Future<WithDrawalAPIResponseModel> withdrawal(
      {required String? accessToken}) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/my/out');

    final response = await InterceptorHelper().client.delete(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return WithDrawalAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return WithDrawalAPI().withdrawal(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'));
    } else {
      throw Exception(response.body);
    }
  }
}

class WithDrawalAPIResponseModel {
  dynamic result;

  WithDrawalAPIResponseModel({
    this.result,
  });

  factory WithDrawalAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return WithDrawalAPIResponseModel(
      result: data,
    );
  }
}
