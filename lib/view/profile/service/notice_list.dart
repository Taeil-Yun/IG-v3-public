import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/api/bbs/notice.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';

class NoticeListScreen extends StatefulWidget {
  const NoticeListScreen({super.key});

  @override
  State<NoticeListScreen> createState() => _NoticeListScreenState();
}

class _NoticeListScreenState extends State<NoticeListScreen> {
  List noticeList = [];

  @override
  void initState() {
    super.initState();

    initializeAPI();
  }

  Future<void> initializeAPI() async {
    GetNoticeAPI().notice(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
      setState(() {
        noticeList = value.result['data'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ig-publicAppBar(
        leading: ig-publicAppBarLeading(
          press: () => Navigator.pop(context),
        ),
        title: const ig-publicAppBarTitle(
          title: TextConstant.notice,
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: ColorConfig().gray1(),
        child: SafeArea(
          child: ListView(
            children: List.generate(noticeList.length, (index) {
              return InkWell(
                onTap: () {
                  Navigator.pushNamed(context, 'noticeDetail', arguments: {
                    'notice_index': noticeList[index]['bbs_index'],
                  });
                },
                child: Container(
                  color: ColorConfig().white(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 타이틀
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // index == 0 || index == 1 ? Container(
                          //   margin: const EdgeInsets.only(right: 4.0),
                          //   child: SVGStringBuilder(
                          //     image: 'assets/icon/New-rnd.svg',
                          //     width: 16.0.w,
                          //     height: 16.0.w,
                          //   ),
                          // ) : Container(),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: CustomTextBuilder(
                                text: '${noticeList[index]['question']}',
                                fontColor: ColorConfig().dark(),
                                fontSize: 14.0.sp,
                                fontWeight: FontWeight.w800,
                                maxLines: 1,
                                textOverflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // 날짜
                      CustomTextBuilder(
                        text: DateTime.parse(noticeList[index]['create_dt']).toLocal().millisecondsSinceEpoch < DateTime.parse(noticeList[index]['modify_dt']).toLocal().millisecondsSinceEpoch ? '${DateFormat('yyyy.MM.dd').format(DateTime.parse(noticeList[index]['create_dt']).toLocal())} (수정됨)' : DateFormat('yyyy.MM.dd').format(DateTime.parse(noticeList[index]['create_dt']).toLocal()),
                        fontColor: ColorConfig().gray3(),
                        fontSize: 11.0.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}