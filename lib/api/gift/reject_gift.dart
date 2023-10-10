import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class RejectGiftAPI {
  Future<RejectGiftAPIResponseModel> rejectGift(
      {required String? accessToken, required String giftCode}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/gift/reject_gift');

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

      return RejectGiftAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return RejectGiftAPI().rejectGift(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          giftCode: giftCode);
    } else {
      throw Exception(response.body);
    }
  }
}

class RejectGiftAPIResponseModel {
  dynamic result;

  RejectGiftAPIResponseModel({
    this.result,
  });

  factory RejectGiftAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return RejectGiftAPIResponseModel(
      result: data,
    );
  }
}
