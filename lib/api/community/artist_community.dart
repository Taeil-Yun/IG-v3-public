import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class ArtistCommunityAPI {
  Future<ArtistCommunityAPIResponseModel> artistCommunity(
      {required String? accessToken, required int artistIndex}) async {
    final baseUri = Uri.parse(
        '${ig - publicBuildConfig.instance?.baseUrl}/artist?artist_index=$artistIndex');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return ArtistCommunityAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return ArtistCommunityAPI().artistCommunity(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          artistIndex: artistIndex);
    } else {
      throw Exception(response.body);
    }
  }
}

class ArtistCommunityAPIResponseModel {
  dynamic result;

  ArtistCommunityAPIResponseModel({
    this.result,
  });

  factory ArtistCommunityAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return ArtistCommunityAPIResponseModel(
      result: data,
    );
  }
}
