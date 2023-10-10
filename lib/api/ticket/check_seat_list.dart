import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class CheckSeatListAPI {
  Future<CheckSeatListAPIResponseModel> checkList(
      {required String? accessToken,
      required int showContentTicketIndex}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/ticket/check_seat_list?show_content_ticket_index=$showContentTicketIndex');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return CheckSeatListAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return CheckSeatListAPI().checkList(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          showContentTicketIndex: showContentTicketIndex);
    } else {
      throw Exception(response.body);
    }
  }
}

class CheckSeatListAPIResponseModel {
  dynamic result;

  CheckSeatListAPIResponseModel({
    this.result,
  });

  factory CheckSeatListAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return CheckSeatListAPIResponseModel(
      result: data,
    );
  }
}
