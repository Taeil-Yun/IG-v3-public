import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class DeleteScrapAPI {
  Future<DeleteScrapAPIResponseModel> scrapDelete(
      {required String? accessToken, required int scrapIndex}) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/scrap');

    final response = await InterceptorHelper().client.delete(
          baseUri,
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $accessToken",
          },
          body: json.encode({
            'scrap_index': scrapIndex,
          }),
        );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return DeleteScrapAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return DeleteScrapAPI().scrapDelete(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          scrapIndex: scrapIndex);
    } else {
      throw Exception(response.body);
    }
  }
}

class DeleteScrapAPIResponseModel {
  dynamic result;

  DeleteScrapAPIResponseModel({
    this.result,
  });

  factory DeleteScrapAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return DeleteScrapAPIResponseModel(
      result: data,
    );
  }
}
