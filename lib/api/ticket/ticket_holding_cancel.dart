import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class TicketHoldingCancelAPI {
  Future<TicketHoldingCancelAPIResponseModel> holdCancel(
      {required String? accessToken}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/ticket/hold_cancel');

    final response = await InterceptorHelper().client.post(
      baseUri,
      headers: {
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return TicketHoldingCancelAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return TicketHoldingCancelAPI().holdCancel(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'));
    } else {
      throw Exception(response.body);
    }
  }
}

class TicketHoldingCancelAPIResponseModel {
  dynamic result;

  TicketHoldingCancelAPIResponseModel({
    this.result,
  });

  factory TicketHoldingCancelAPIResponseModel.fromJson(
      Map<String, dynamic> data) {
    return TicketHoldingCancelAPIResponseModel(
      result: data,
    );
  }
}
