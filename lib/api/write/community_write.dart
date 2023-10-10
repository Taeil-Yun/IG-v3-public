import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/api/auth/refresh.dart';

class CommunityWritingAPI {
  Future<CommunityWritingAPIResponseModel> writing({
    required String accessToken,
    required int index,
    required String type,
    String title = '',
    String content = '',
    List<dynamic>? images,
    int? star,
    String? watchDate,
    String? location,
    String? casting,
    String? seat,
    int? isHide,
  }) async {
    final baseUri =
        Uri.parse('${ig - publicBuildConfig.instance?.baseUrl}/community');

    final request = http.MultipartRequest('POST', baseUri);

    request.headers.addAll({
      "Content-Type": "multipart/form-data",
      "authorization": "Bearer $accessToken",
    });

    if (type == 'S' || type == 'A') {
      if (images != null) {
        for (int i = 0; i < images.length; i++) {
          request.files
              .add(await http.MultipartFile.fromPath('image', images[i]));
        }
      }
      request.fields['type'] = type;
      request.fields['index'] = '$index';
      if (title.isNotEmpty) {
        request.fields['title'] = title;
      } else {
        throw Exception(
            'If the value of "type" is S or A, the "title" field must be used unconditionally');
      }
      request.fields['content'] = content;
    } else {
      if (images != null) {
        for (int i = 0; i < images.length; i++) {
          request.files
              .add(await http.MultipartFile.fromPath('image', images[i]));
        }
      }
      request.fields['type'] = type;
      request.fields['index'] = '$index';
      request.fields['content'] = content;
      if (casting != null) {
        request.fields['casting'] = casting;
      } else {
        throw Exception(
            'If the value of "type" is R, the "casting" field must be used unconditionally');
      }
      if (star != null) {
        request.fields['star'] = '$star';
      } else {
        throw Exception(
            'If the value of "type" is R, the "star" field must be used unconditionally');
      }
      if (watchDate != null) {
        request.fields['watch_date'] = watchDate;
      }
      if (location != null) {
        request.fields['location'] = location;
      }
      if (seat != null) {
        request.fields['seat'] = seat;
      }
      if (isHide != null) {
        request.fields['is_hide'] = '$isHide';
      }
    }

    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      // print('datas: ${utf8.decode(response.bodyBytes.toList())}');

      return CommunityWritingAPIResponseModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes.toList())));
    } else if (response.statusCode == 402) {
      String currentAccessToken =
          await SecureStorageConfig().storage.read(key: 'access_token') ?? '';
      String currentRefreshToken =
          await SecureStorageConfig().storage.read(key: 'refresh_token') ?? '';

      return RefreshTokenAPI()
          .refresh(
              accesToken: currentAccessToken, refreshToken: currentRefreshToken)
          .then((value) {
        return CommunityWritingAPI().writing(
          accessToken: value.result['data']['access_token'],
          type: type,
          index: index,
          title: title,
          content: content,
          images: images,
          star: star,
          casting: casting,
          isHide: isHide,
          location: location,
          seat: seat,
          watchDate: watchDate,
        );
      });
    } else {
      throw Exception(response.body);
    }
  }
}

class CommunityWritingAPIResponseModel {
  dynamic result;

  CommunityWritingAPIResponseModel({
    this.result,
  });

  factory CommunityWritingAPIResponseModel.fromJson(
      Map<dynamic, dynamic> data) {
    return CommunityWritingAPIResponseModel(
      result: data,
    );
  }
}
