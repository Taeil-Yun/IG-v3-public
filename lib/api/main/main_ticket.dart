import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class MainTicketListAPI {
  Future<MainTicketListAPIResponseModel> ticket(
      {required String? accessToken}) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/ticket');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return MainTicketListAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return MainTicketListAPI().ticket(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'));
    } else {
      throw Exception(response.body);
    }
  }
}

class MainTicketListAPIResponseModel {
  dynamic result;

  MainTicketListAPIResponseModel({
    this.result,
  });

  factory MainTicketListAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return MainTicketListAPIResponseModel(
      result: data,
    );
  }
}
