import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class CancelGiftDataAPI {
  Future<CancelGIftDataAPIResponseModel> cancelGift(
      {required String? accessToken, required String giftGroup}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/gift/cancel_gift');

    final response = await InterceptorHelper().client.delete(
          baseUri,
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $accessToken",
          },
          body: json.encode({
            "gift_group": giftGroup,
          }),
        );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return CancelGIftDataAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return CancelGiftDataAPI().cancelGift(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          giftGroup: giftGroup);
    } else {
      throw Exception(response.body);
    }
  }
}

class CancelGIftDataAPIResponseModel {
  dynamic result;

  CancelGIftDataAPIResponseModel({
    this.result,
  });

  factory CancelGIftDataAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return CancelGIftDataAPIResponseModel(
      result: data,
    );
  }
}
