import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class AuctionCancelAPI {
  Future<AuctionCancelAPIResponseModel> auctionCancel(
      {required String? accessToken, required int auctionIndex}) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/auction/cancel');

    final response = await InterceptorHelper().client.delete(
          baseUri,
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $accessToken",
          },
          body: json.encode({
            'auction_index': auctionIndex,
          }),
        );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return AuctionCancelAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return AuctionCancelAPI().auctionCancel(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          auctionIndex: auctionIndex);
    } else {
      throw Exception(response.body);
    }
  }
}

class AuctionCancelAPIResponseModel {
  dynamic result;

  AuctionCancelAPIResponseModel({
    this.result,
  });

  factory AuctionCancelAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return AuctionCancelAPIResponseModel(
      result: data,
    );
  }
}
