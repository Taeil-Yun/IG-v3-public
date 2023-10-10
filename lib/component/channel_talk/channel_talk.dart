import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:channel_talk_flutter/channel_talk_flutter.dart';
import 'package:crypto/crypto.dart';

import 'package:ig-public_v3/costant/keys.dart';

Future<void> getChannelTalk(
    {required String nickname,
    required String name,
    required String email,
    required String phoneNumber}) async {
  try {
    var sa = Hmac(sha256, utf8.encode(ig - publicKeys.channelTalkAccessKey))
        .convert(utf8.encode(ig - publicKeys.channelTalkPluginKey));
    // 채널톡 사용을 위한 세팅
    await ChannelTalk.boot(
        pluginKey: ig - publicKeys.channelTalkPluginKey,
        memberHash: sa.toString(),
        memberId: nickname,
        name: name,
        email: email,
        mobileNumber: phoneNumber);

    await ChannelTalk.hideChannelButton();
    await ChannelTalk.showMessenger();
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }
}
