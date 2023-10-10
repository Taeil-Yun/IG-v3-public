import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class TicketHoldingAPI {
  Future<TicketHoldingAPIResponseModel> holding(
      {required String? accessToken, required List seatData}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/ticket/hold_ticket');

    final response = await InterceptorHelper().client.post(
          baseUri,
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $accessToken",
          },
          body: json.encode(seatData),
        );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return TicketHoldingAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return TicketHoldingAPI().holding(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          seatData: seatData);
    } else {
      throw Exception(response.body);
    }
  }
}

class TicketHoldingAPIResponseModel {
  dynamic result;

  TicketHoldingAPIResponseModel({
    this.result,
  });

  factory TicketHoldingAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return TicketHoldingAPIResponseModel(
      result: data,
    );
  }
}
