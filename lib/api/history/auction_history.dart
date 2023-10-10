import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class AuctionHistoryAPI {
  Future<AuctionHistoryAPIResponseModel> auctionHistory(
      {required String? accessToken}) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/my/auctions');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return AuctionHistoryAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return AuctionHistoryAPI().auctionHistory(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'));
    } else {
      throw Exception(response.body);
    }
  }
}

class AuctionHistoryAPIResponseModel {
  dynamic result;

  AuctionHistoryAPIResponseModel({
    this.result,
  });

  factory AuctionHistoryAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return AuctionHistoryAPIResponseModel(
      result: data,
    );
  }
}
