import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class NotificationListAPI {
  Future<NotificationListAPIResponseModel> notificationList(
      {required String? accessToken}) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/my/alarm');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return NotificationListAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return NotificationListAPI().notificationList(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'));
    } else {
      throw Exception(response.body);
    }
  }
}

class NotificationListAPIResponseModel {
  dynamic result;

  NotificationListAPIResponseModel({
    this.result,
  });

  factory NotificationListAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return NotificationListAPIResponseModel(
      result: data,
    );
  }
}
