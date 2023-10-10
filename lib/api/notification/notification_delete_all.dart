import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class DeleteNotificationAllAPI {
  Future<DeleteNotificationAllAPIResponseModel> notificationDeleteAll(
      {required String? accessToken}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/my/alarm_all_remove');

    final response = await InterceptorHelper().client.delete(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return DeleteNotificationAllAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return DeleteNotificationAllAPI().notificationDeleteAll(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'));
    } else {
      throw Exception(response.body);
    }
  }
}

class DeleteNotificationAllAPIResponseModel {
  dynamic result;

  DeleteNotificationAllAPIResponseModel({
    this.result,
  });

  factory DeleteNotificationAllAPIResponseModel.fromJson(
      Map<String, dynamic> data) {
    return DeleteNotificationAllAPIResponseModel(
      result: data,
    );
  }
}
