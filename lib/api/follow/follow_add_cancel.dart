import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class FollowAddOrCancel {
  Future<FollowAddOrCancelAPIResponseModel> followApply(
      {required String? accessToken,
      required String kind,
      required int type,
      required int index}) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/follow');

    final response = await InterceptorHelper().client.post(
          baseUri,
          headers: {
            "Content-Type": "application/json",
            "authorization": "Bearer $accessToken",
          },
          body: json.encode({
            'kind': kind,
            'type': type,
            'index': index,
          }),
        );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return FollowAddOrCancelAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return FollowAddOrCancel().followApply(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          kind: kind,
          type: type,
          index: index);
    } else {
      throw Exception(response.body);
    }
  }
}

class FollowAddOrCancelAPIResponseModel {
  dynamic result;

  FollowAddOrCancelAPIResponseModel({
    this.result,
  });

  factory FollowAddOrCancelAPIResponseModel.fromJson(
      Map<String, dynamic> data) {
    return FollowAddOrCancelAPIResponseModel(
      result: data,
    );
  }
}
