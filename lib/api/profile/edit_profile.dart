import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ig-public_v3/costant/build_config.dart';

class EditProfileAPI {
  Future<EditProfileAPIResponseModel> edit({
    required String? accessToken,
    required String nickname,
    String? description,
    int? sms,
    int? email,
    dynamic backgroundImage,
    dynamic profileImage,
  }) async {
    final baseUri = Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/my');

    final request = http.MultipartRequest('POST', baseUri);

    request.headers.addAll({
      "Content-Type": "multipart/form-data",
      "authorization": "Bearer $accessToken",
    });
    if (backgroundImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
          'background_profile', backgroundImage));
    }
    if (profileImage != null) {
      request.files
          .add(await http.MultipartFile.fromPath('profile', profileImage));
    }
    request.fields['nick'] = nickname;
    if (description != null) {
      request.fields['description'] = description;
    }
    if (sms != null) {
      request.fields['sms'] = '$sms';
    }
    if (email != null) {
      request.fields['email'] = '$email';
    }

    final response = await http.Response.fromStream(await request.send());

    // final response = await InterceptorHelper().client.post(
    //   baseUri,
    //   headers: {
    //     "Content-Type" : "multipart/form-data",
    //     "authorization" : "Bearer $accessToken",
    //   },
    //   body: json.encode({
    //     'profile': profileImage,
    //     'background_profile': backgroundImage,
    //     'nick': nickname,
    //     'description': description,
    //     'sms': sms,
    //     'email': email,
    //   }),
    // );

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return EditProfileAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      return EditProfileAPI().edit(
        accessToken:
            await SecureStorageConfig().storage.read(key: 'access_token'),
        nickname: nickname,
        backgroundImage: backgroundImage,
        description: description,
        email: email,
        profileImage: profileImage,
        sms: sms,
      );
    } else {
      throw Exception(response.body);
    }
  }
}

class EditProfileAPIResponseModel {
  dynamic result;

  EditProfileAPIResponseModel({
    this.result,
  });

  factory EditProfileAPIResponseModel.fromJson(Map<String, dynamic> data) {
    return EditProfileAPIResponseModel(
      result: data,
    );
  }
}
