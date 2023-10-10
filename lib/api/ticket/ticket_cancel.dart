import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class TicketCancelAPI {
  Future<TicketCancelAPIResponseModel> ticketCancel(
      {required String? accessToken, required List ticketIndex}) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/ticket/cancel');

    final response = await InterceptorHelper().client.delete(
          baseUri,
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $accessToken",
          },
          body: json.encode({
            "ticket_print_index": ticketIndex,
          }),
        );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return TicketCancelAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return TicketCancelAPI().ticketCancel(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          ticketIndex: ticketIndex);
    } else {
      throw Exception(response.body);
    }
  }
}

class TicketCancelAPIResponseModel {
  dynamic result;

  TicketCancelAPIResponseModel({
    this.result,
  });

  factory TicketCancelAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return TicketCancelAPIResponseModel(
      result: data,
    );
  }
}
