import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class SendBeforeGiftTicketAPI {
  Future<SendGiftTicketAPIResponseModel> giftSend(
      {required String? accessToken,
      required String ticketGroup,
      required List ticketPrintIndex,
      required int isRefund,
      String? message}) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/gift/send_gift');

    final response = await InterceptorHelper().client.post(
          baseUri,
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $accessToken",
          },
          body: json.encode({
            'ticket_group': ticketGroup,
            'ticket_print_index': ticketPrintIndex,
            'is_refund': isRefund,
            'message': message,
          }),
        );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return SendGiftTicketAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return SendBeforeGiftTicketAPI().giftSend(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          ticketGroup: ticketGroup,
          ticketPrintIndex: ticketPrintIndex,
          isRefund: isRefund,
          message: message);
    } else {
      throw Exception(response.body);
    }
  }
}

class SendGiftTicketAPIResponseModel {
  dynamic result;

  SendGiftTicketAPIResponseModel({
    this.result,
  });

  factory SendGiftTicketAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return SendGiftTicketAPIResponseModel(
      result: data,
    );
  }
}
