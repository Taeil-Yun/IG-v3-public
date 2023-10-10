import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class AuctionBettingAPI {
  Future<AuctionBettingAPIResponseModel> bettingSeat(
      {required String? accessToken,
      required Map<String, dynamic> seatData}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/auction/get_auction_seat_info');

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

      return AuctionBettingAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return AuctionBettingAPI().bettingSeat(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          seatData: seatData);
    } else {
      throw Exception(response.body);
    }
  }

  Future<AuctionBettingAPIResponseModel> getBettingSeat(
      {required String? accessToken, required int showDetailIndex}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/auction/get_auction_seat_info?show_detail_index=$showDetailIndex');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return AuctionBettingAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return AuctionBettingAPI().getBettingSeat(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          showDetailIndex: showDetailIndex);
    } else {
      throw Exception(response.body);
    }
  }
}

class AuctionBettingAPIResponseModel {
  dynamic result;

  AuctionBettingAPIResponseModel({
    this.result,
  });

  factory AuctionBettingAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return AuctionBettingAPIResponseModel(
      result: data,
    );
  }
}
