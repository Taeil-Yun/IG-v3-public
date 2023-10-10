import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class PaymentOrderAPI {
  Future<PaymentOrderAPIResponseModel> order(
      {required String? accessToken,
      required String orderId,
      required String payType,
      required int amount}) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/payment/order');

    final response = await InterceptorHelper().client.post(
          baseUri,
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $accessToken",
          },
          body: json.encode({
            "order_id": orderId,
            "pay_type": payType,
            "amount": amount,
          }),
        );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return PaymentOrderAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return PaymentOrderAPI().order(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          orderId: orderId,
          payType: payType,
          amount: amount);
    } else {
      throw Exception(response.body);
    }
  }
}

class PaymentOrderAPIResponseModel {
  dynamic result;

  PaymentOrderAPIResponseModel({
    this.result,
  });

  factory PaymentOrderAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return PaymentOrderAPIResponseModel(
      result: data,
    );
  }
}
