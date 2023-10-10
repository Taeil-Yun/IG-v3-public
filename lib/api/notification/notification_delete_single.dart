import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class DeleteNotificationSingleAPI {
  Future<DeleteNotificationSingleAPIResponseModel> notificationDeleteSingle(
      {required String? accessToken, required int alarmIndex}) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/my/alarm');

    final response = await InterceptorHelper().client.delete(
          baseUri,
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $accessToken",
          },
          body: json.encode({
            'scrap_index': alarmIndex,
          }),
        );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return DeleteNotificationSingleAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return DeleteNotificationSingleAPI().notificationDeleteSingle(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          alarmIndex: alarmIndex);
    } else {
      throw Exception(response.body);
    }
  }
}

class DeleteNotificationSingleAPIResponseModel {
  dynamic result;

  DeleteNotificationSingleAPIResponseModel({
    this.result,
  });

  factory DeleteNotificationSingleAPIResponseModel.fromJson(
      Map<String, dynamic> data) {
    return DeleteNotificationSingleAPIResponseModel(
      result: data,
    );
  }
}
