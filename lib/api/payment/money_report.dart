import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class MoneyReportAPI {
  Future<MoneyReportAPIResponseModel> report(
      {required String? accessToken}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/my/report_money');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return MoneyReportAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return MoneyReportAPI().report(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'));
    } else {
      throw Exception(response.body);
    }
  }
}

class MoneyReportAPIResponseModel {
  dynamic result;

  MoneyReportAPIResponseModel({
    this.result,
  });

  factory MoneyReportAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return MoneyReportAPIResponseModel(
      result: data,
    );
  }
}
