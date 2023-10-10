import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class PaymentCompleteAPI {
  Future<PaymentCompleteAPIResponseModel> complete(
      {required String? accessToken, required String impUid}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/payment/complete');

    final response = await InterceptorHelper().client.post(
          baseUri,
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $accessToken",
          },
          body: json.encode({
            "imp_uid": impUid,
          }),
        );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return PaymentCompleteAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return PaymentCompleteAPI().complete(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          impUid: impUid);
    } else {
      throw Exception(response.body);
    }
  }
}

class PaymentCompleteAPIResponseModel {
  dynamic result;

  PaymentCompleteAPIResponseModel({
    this.result,
  });

  factory PaymentCompleteAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return PaymentCompleteAPIResponseModel(
      result: data,
    );
  }
}
