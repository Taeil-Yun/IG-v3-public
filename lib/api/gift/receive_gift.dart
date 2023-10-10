import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class ReceiveGiftAPI {
  Future<ReceiveGiftAPIResponseModel> receiveGift(
      {required String? accessToken, required String giftCode}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/gift/recive_gift');

    final response = await InterceptorHelper().client.patch(
          baseUri,
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $accessToken",
          },
          body: json.encode({
            'code': giftCode,
          }),
        );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return ReceiveGiftAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return ReceiveGiftAPI().receiveGift(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          giftCode: giftCode);
    } else {
      throw Exception(response.body);
    }
  }
}

class ReceiveGiftAPIResponseModel {
  dynamic result;

  ReceiveGiftAPIResponseModel({
    this.result,
  });

  factory ReceiveGiftAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return ReceiveGiftAPIResponseModel(
      result: data,
    );
  }
}
