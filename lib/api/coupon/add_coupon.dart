import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class AddCouponAPI {
  Future<AddCouponAPIResponseModel> addCoupon(
      {required String? accessToken, required String couponCode}) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/coupon');

    final response = await InterceptorHelper().client.post(
          baseUri,
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $accessToken",
          },
          body: json.encode({
            'code': couponCode,
          }),
        );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return AddCouponAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return AddCouponAPI().addCoupon(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          couponCode: couponCode);
    } else {
      throw Exception(response.body);
    }
  }
}

class AddCouponAPIResponseModel {
  dynamic result;

  AddCouponAPIResponseModel({
    this.result,
  });

  factory AddCouponAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return AddCouponAPIResponseModel(
      result: data,
    );
  }
}
