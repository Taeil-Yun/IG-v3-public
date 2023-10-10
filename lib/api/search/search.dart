import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class SearchAPI {
  Future<SearchAPIResponseModel> search(
      {required String? accessToken, required String keyword}) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/search');

    final response = await InterceptorHelper().client.post(
          baseUri,
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $accessToken",
          },
          body: json.encode({
            'keyword': keyword,
          }),
        );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return SearchAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return SearchAPI().search(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          keyword: keyword);
    } else {
      throw Exception(response.body);
    }
  }
}

class SearchAPIResponseModel {
  dynamic result;

  SearchAPIResponseModel({
    this.result,
  });

  factory SearchAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return SearchAPIResponseModel(
      result: data,
    );
  }
}
