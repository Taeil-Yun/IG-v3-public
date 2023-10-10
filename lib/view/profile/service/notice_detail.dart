import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/src/route_argument.dart';
import 'package:ig-public_v3/api/bbs/notice_detail.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';

class NoticeDetailScreen extends StatefulWidget {
  const NoticeDetailScreen({
    super.key,
  });

  @override
  State<NoticeDetailScreen> createState() => _NoticeDetailScreenState();
}

class _NoticeDetailScreenState extends State<NoticeDetailScreen> {
  int noticeIndex = 0;

  List noticeDetailData = [];

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      setState(() {
        noticeIndex = RouteGetArguments().getArgs(context)['notice_index'];
      });
    });

    initializeAPI();
  }

  Future<void> initializeAPI() async {
    GetNoticeDetailAPI()
        .noticeDetail(
            accessToken:
                await SecureStorageConfig().storage.read(key: 'access_token'),
            bbsIndex: noticeIndex)
        .then((value) {
      setState(() {
        noticeDetailData = value.result['data'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ig -
          publicAppBar(
            leading: ig -
                publicAppBarLeading(
                  press: () {
                    Navigator.pop(context);
                  },
                ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: SVGBuilder(
                  image: 'assets/icon/share.svg',
                  width: 22.0.w,
                  height: 22.0.w,
                  color: ColorConfig().dark(),
                ),
              ),
            ],
          ),
      body: noticeDetailData.isNotEmpty
          ? SafeArea(
              child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: ColorConfig().white(),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 8.0),
                      child: CustomTextBuilder(
                          text: '${noticeDetailData[0]['question']}'),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 8.0),
                      child: CustomTextBuilder(
                        text: DateTime.parse(noticeDetailData[0]['create_dt'])
                                    .toLocal()
                                    .millisecondsSinceEpoch <
                                DateTime.parse(noticeDetailData[0]['modify_dt'])
                                    .toLocal()
                                    .millisecondsSinceEpoch
                            ? '${DateFormat('yyyy. M. d').format(DateTime.parse(noticeDetailData[0]['modify_dt']).toLocal())} (수정됨)'
                            : DateFormat('yyyy. M. d').format(
                                DateTime.parse(noticeDetailData[0]['modify_dt'])
                                    .toLocal()),
                        fontColor: ColorConfig().gray3(),
                        fontSize: 12.0.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 16.0),
                      child: Html(
                        data: noticeDetailData[0]['answer'],
                        style: {
                          "img": Style(
                            width: Width.auto(),
                          ),
                        },
                        // onLinkTap: (url, _, __, ___) {
                        //           ig-publicUrlLauncher().launchURL(url.toString());
                        //           print("Opening $url...");
                        //         },
                      ),
                    ),
                    const SizedBox(height: 32.0),
                  ],
                ),
              ),
            ))
          : Container(),
    );
  }
}
