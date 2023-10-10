import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class Myig-publicMoneyAPI {
  Future<Myig-publicMoneyAPIResponseModel> ig-publicMoney({required String? accessToken}) async {
    final baseUri = Uri.parse('${ig-publicBuildConfig.instance?.baseUrl}/my/money');

    final response = await InterceptorHelper().client.get(
      baseUri,
      headers: {
        "Content-Type" : "application/json",
        "authorization" : "Bearer $accessToken",
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return Myig-publicMoneyAPIResponseModel.fromJson(json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return Myig-publicMoneyAPI().ig-publicMoney(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'));
    } else {
      throw Exception(response.body);
    }
  }
}

class Myig-publicMoneyAPIResponseModel {
  dynamic result;

  Myig-publicMoneyAPIResponseModel({
    this.result,
  });

  factory Myig-publicMoneyAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return Myig-publicMoneyAPIResponseModel(
      result: data,
    );
  }
}
