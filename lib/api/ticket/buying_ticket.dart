import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class TicketBuyingAPI {
  Future<TicketBuyingAPIResponseModel> ticketBuy(
      {required String? accessToken,
      required dynamic ticketIndexDatas,
      dynamic couponIndexDatas}) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/ticket/buy');

    final response = await InterceptorHelper().client.post(
          baseUri,
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $accessToken",
          },
          body: couponIndexDatas == null
              ? json.encode({
                  "ticket_index": ticketIndexDatas,
                })
              : json.encode({
                  "ticket_index": ticketIndexDatas,
                  "coupon_index": couponIndexDatas,
                }),
        );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return TicketBuyingAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return TicketBuyingAPI().ticketBuy(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          ticketIndexDatas: ticketIndexDatas);
    } else {
      throw Exception(response.body);
    }
  }
}

class TicketBuyingAPIResponseModel {
  dynamic result;

  TicketBuyingAPIResponseModel({
    this.result,
  });

  factory TicketBuyingAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return TicketBuyingAPIResponseModel(
      result: data,
    );
  }
}
