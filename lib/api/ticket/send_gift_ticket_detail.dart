import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class SendBeforeGiftTicketDetailAPI {
  Future<SendBeforeGiftTicketDetailAPIResponseModel> giftTicket(
      {required String? accessToken, required String ticketGroup}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/gift/ticket?ticket_group=$ticketGroup');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return SendBeforeGiftTicketDetailAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return SendBeforeGiftTicketDetailAPI().giftTicket(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          ticketGroup: ticketGroup);
    } else {
      throw Exception(response.body);
    }
  }
}

class SendBeforeGiftTicketDetailAPIResponseModel {
  dynamic result;

  SendBeforeGiftTicketDetailAPIResponseModel({
    this.result,
  });

  factory SendBeforeGiftTicketDetailAPIResponseModel.fromJson(
      Map<String, dynamic> data) {
    return SendBeforeGiftTicketDetailAPIResponseModel(
      result: data,
    );
  }
}
