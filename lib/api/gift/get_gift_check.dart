import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class GetGiftCheckAPI {
  Future<GetGiftCheckAPIResponseModel> giftCheck(
      {required String? accessToken, required String giftCode}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/gift/recive_gift');

    final response = await InterceptorHelper().client.post(
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

      return GetGiftCheckAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return GetGiftCheckAPI().giftCheck(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          giftCode: giftCode);
    } else {
      throw Exception(response.body);
    }
  }
}

class GetGiftCheckAPIResponseModel {
  dynamic result;

  GetGiftCheckAPIResponseModel({
    this.result,
  });

  factory GetGiftCheckAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return GetGiftCheckAPIResponseModel(
      result: data,
    );
  }
}
