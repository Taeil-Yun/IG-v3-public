import 'package:flutter/material.dart';
import 'package:ig-public_v3/util/deep_link.dart';
import 'package:share_plus/share_plus.dart';

Future<void> shareBuilder(context,
    {required String type, required int index}) async {
  var shortLink =
      await DeepLinkBuilder().getShortLinkShare('share', '$index', type);

  Share.share(
    shortLink,
    sharePositionOrigin: Rect.fromLTWH(0, 0, MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height / 2),
  );
}
