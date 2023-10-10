import 'dart:convert';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/component/interceptor/interceptor.dart';

class PhoneCertificateAPI {
  Future<PhoneCertificateAPIResponseModel> certificate(
      {required String? accessToken, required String impUid}) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/auth/redirect');

    final response = await InterceptorHelper().client.put(
      baseUri,
      headers: {
        // "Content-Type" : "application/json",
        "authorization": "Bearer $accessToken",
      },
      body: {
        'imp_uid': impUid,
      },
    );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return PhoneCertificateAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return PhoneCertificateAPI().certificate(
          accessToken:
              await SecureStorageConfig().storage.read(key: 'access_token'),
          impUid: impUid);
    } else {
      throw Exception(response.body);
    }
  }
}

class PhoneCertificateAPIResponseModel {
  dynamic result;

  PhoneCertificateAPIResponseModel({
    this.result,
  });

  factory PhoneCertificateAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return PhoneCertificateAPIResponseModel(
      result: data,
    );
  }
}
