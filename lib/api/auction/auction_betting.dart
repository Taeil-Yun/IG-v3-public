import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class AuctionBettingApplyAPI {
  Future<AuctionBettingApplyAPIResponseModel> betting(
      {required String? accessToken,
      required Map<String, dynamic> seatData}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/auction/betting');

    final response = await InterceptorHelper().client.post(
          baseUri,
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $accessToken",
          },
          body: json.encode(seatData),
        );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return AuctionBettingApplyAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return AuctionBettingApplyAPI().betting(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          seatData: seatData);
    } else {
      throw Exception(response.body);
    }
  }
}

class AuctionBettingApplyAPIResponseModel {
  dynamic result;

  AuctionBettingApplyAPIResponseModel({
    this.result,
  });

  factory AuctionBettingApplyAPIResponseModel.fromJson(
      Map<String, dynamic> data) {
    return AuctionBettingApplyAPIResponseModel(
      result: data,
    );
  }
}
