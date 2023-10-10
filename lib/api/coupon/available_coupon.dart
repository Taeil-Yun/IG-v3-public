import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class AvailableCouponListAPI {
  Future<AvailableCouponListAPIResponseModel> availableCouponList(
      {required String? accessToken}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/coupon/available_coupon');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return AvailableCouponListAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return AvailableCouponListAPI().availableCouponList(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'));
    } else {
      throw Exception(response.body);
    }
  }
}

class AvailableCouponListAPIResponseModel {
  dynamic result;

  AvailableCouponListAPIResponseModel({
    this.result,
  });

  factory AvailableCouponListAPIResponseModel.fromJson(
      Map<String, dynamic> data) {
    return AvailableCouponListAPIResponseModel(
      result: data,
    );
  }
}
