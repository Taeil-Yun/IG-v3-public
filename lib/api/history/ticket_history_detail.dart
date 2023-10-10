import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class TicketHistoryDetailAPI {
  Future<TicketHistoryDetailAPIResponseModel> detail(
      {required String? accessToken, required String ticketGroupNumber}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/my/ticket?ticket_group=$ticketGroupNumber');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return TicketHistoryDetailAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return TicketHistoryDetailAPI().detail(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          ticketGroupNumber: ticketGroupNumber);
    } else {
      throw Exception(response.body);
    }
  }
}

class TicketHistoryDetailAPIResponseModel {
  dynamic result;

  TicketHistoryDetailAPIResponseModel({
    this.result,
  });

  factory TicketHistoryDetailAPIResponseModel.fromJson(
      Map<String, dynamic> data) {
    return TicketHistoryDetailAPIResponseModel(
      result: data,
    );
  }
}
