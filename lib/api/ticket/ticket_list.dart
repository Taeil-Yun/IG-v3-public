import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class TicketListAPI {
  Future<TicketListAPIResponseModel> list(
      {required String? accessToken, required int showIndex}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/ticket/list?show_content_index=$showIndex');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return TicketListAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return TicketListAPI().list(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          showIndex: showIndex);
    } else {
      throw Exception(response.body);
    }
  }
}

class TicketListAPIResponseModel {
  dynamic result;

  TicketListAPIResponseModel({
    this.result,
  });

  factory TicketListAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return TicketListAPIResponseModel(
      result: data,
    );
  }
}
