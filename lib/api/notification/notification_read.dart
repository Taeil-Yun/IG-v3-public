import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class NotificationReadAPI {
  Future<NotificationReadAPIResponseModel> notificationRead(
      {required String? accessToken, required int alarmIndex}) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/my/alarm');

    final response = await InterceptorHelper().client.post(
          baseUri,
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $accessToken",
          },
          body: json.encode({
            "alarm_index": alarmIndex,
          }),
        );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return NotificationReadAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return NotificationReadAPI().notificationRead(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          alarmIndex: alarmIndex);
    } else {
      throw Exception(response.body);
    }
  }
}

class NotificationReadAPIResponseModel {
  dynamic result;

  NotificationReadAPIResponseModel({
    this.result,
  });

  factory NotificationReadAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return NotificationReadAPIResponseModel(
      result: data,
    );
  }
}
