import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class EndDrawerDataAPI {
  Future<EndDrawerDataAPIResponseModel> endDrawer(
      {required String? accessToken}) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/my/slide');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return EndDrawerDataAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return EndDrawerDataAPI().endDrawer(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'));
    } else {
      throw Exception(response.body);
    }
  }
}

class EndDrawerDataAPIResponseModel {
  dynamic result;

  EndDrawerDataAPIResponseModel({
    this.result,
  });

  factory EndDrawerDataAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return EndDrawerDataAPIResponseModel(
      result: data,
    );
  }
}
