import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class MainCommunityListAPI {
  Future<MainCommunityListAPIResponseModel> communityList(
      {required String? accessToken,
      required int type,
      int? showIndex,
      int? artistIndex,
      int? userIndex}) async {
    String uri =
        '${ig - publicBuildConfig.instance?.baseUrl}/community?type=$type';

    dynamic baseUri;

    if (showIndex != null) {
      uri += '&show_index=$showIndex';
    }

    if (artistIndex != null) {
      uri += '&artist_index=$artistIndex';
    }

    if (userIndex != null) {
      uri += '&user_index=$userIndex';
    }

    baseUri = Uri.parse(uri);

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type": "application/json",
        "authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return MainCommunityListAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return MainCommunityListAPI().communityList(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          type: type,
          artistIndex: artistIndex,
          showIndex: showIndex,
          userIndex: userIndex);
    } else {
      throw Exception(response.body);
    }
  }
}

class MainCommunityListAPIResponseModel {
  dynamic result;

  MainCommunityListAPIResponseModel({
    this.result,
  });

  factory MainCommunityListAPIResponseModel.fromJson(
      Map<String, dynamic> data) {
    return MainCommunityListAPIResponseModel(
      result: data,
    );
  }
}
