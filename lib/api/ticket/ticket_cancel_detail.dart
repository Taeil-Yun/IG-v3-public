import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class TicketCancelDetailAPI {
  Future<TicketCancelDetailAPIResponseModel> ticketCancelDetail(
      {required String? accessToken, required int ticketGroup}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/ticket/cancel_detail?ticket_group=$ticketGroup');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return TicketCancelDetailAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return TicketCancelDetailAPI().ticketCancelDetail(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          ticketGroup: ticketGroup);
    } else {
      throw Exception(response.body);
    }
  }
}

class TicketCancelDetailAPIResponseModel {
  dynamic result;

  TicketCancelDetailAPIResponseModel({
    this.result,
  });

  factory TicketCancelDetailAPIResponseModel.fromJson(
      Map<String, dynamic> data) {
    return TicketCancelDetailAPIResponseModel(
      result: data,
    );
  }
}
