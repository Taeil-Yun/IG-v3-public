import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class AuctionListAPI {
  Future<AuctionListAPIResponseModel> auctionList(
      {required String? accessToken, required int showContentIndex}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/auction?show_content_index=$showContentIndex');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return AuctionListAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return AuctionListAPI().auctionList(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          showContentIndex: showContentIndex);
    } else {
      throw Exception(response.body);
    }
  }
}

class AuctionListAPIResponseModel {
  dynamic result;

  AuctionListAPIResponseModel({
    this.result,
  });

  factory AuctionListAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return AuctionListAPIResponseModel(
      result: data,
    );
  }
}
