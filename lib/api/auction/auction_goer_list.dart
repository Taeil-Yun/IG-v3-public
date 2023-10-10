import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class AuctionGoerListAPI {
  Future<AuctionGoerListAPIResponseModel> goerList(
      {required String? accessToken, required int showDetailIndex}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/auction/get_auction_goer_list?show_detail_index=$showDetailIndex');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return AuctionGoerListAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return AuctionGoerListAPI().goerList(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          showDetailIndex: showDetailIndex);
    } else {
      throw Exception(response.body);
    }
  }
}

class AuctionGoerListAPIResponseModel {
  dynamic result;

  AuctionGoerListAPIResponseModel({
    this.result,
  });

  factory AuctionGoerListAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return AuctionGoerListAPIResponseModel(
      result: data,
    );
  }
}
