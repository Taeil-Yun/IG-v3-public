import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class TicketDetailDataAPI {
  Future<TicketDetailDataAPIResponseModel> ticketDetail(
      {required String? accessToken, required int showIndex}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/ticket/detail?show_detail_index=$showIndex');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return TicketDetailDataAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return TicketDetailDataAPI().ticketDetail(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          showIndex: showIndex);
    } else {
      throw Exception(response.body);
    }
  }
}

class TicketDetailDataAPIResponseModel {
  dynamic result;

  TicketDetailDataAPIResponseModel({
    this.result,
  });

  factory TicketDetailDataAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return TicketDetailDataAPIResponseModel(
      result: data,
    );
  }
}
