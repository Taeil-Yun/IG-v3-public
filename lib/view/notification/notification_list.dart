import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/api/notification/notification_delete_all.dart';
import 'package:ig-public_v3/api/notification/notification_delete_single.dart';
import 'package:ig-public_v3/api/notification/notification_list.dart';
import 'package:ig-public_v3/api/notification/notification_read.dart';
import 'package:ig-public_v3/component/popup/popup.dart';
import 'package:ig-public_v3/costant/build_config.dart';

import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/util/toast.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:intl/intl.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  List notificationList = [];

  @override
  void initState() {
    super.initState();

    initializeAPI();
  }

  Future<void> initializeAPI() async {
    NotificationListAPI().notificationList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
      setState(() {
        notificationList = value.result['data'];
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
          title: TextConstant.notificationList,
        ),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4.0.r),
                    topRight: Radius.circular(4.0.r),
                  ),
                ),
                backgroundColor: ColorConfig().white(),
                builder: (context1) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8.0),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context1);
                            Navigator.pushNamed(context, 'notificationSetting');
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: ColorConfig().white(),
                              border: Border(
                                bottom: BorderSide(
                                  width: 1.0,
                                  color: ColorConfig().gray1(),
                                ),
                              ),
                            ),
                            child: CustomTextBuilder(
                              text: TextConstant.doNotificationSetting,
                              fontColor: ColorConfig().dark(),
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context1);
                            
                            PopupBuilder(
                              title: TextConstant.pushDeleteAllPopupTitle,
                              content: TextConstant.pushDeleteAllPopupDescription,
                              actions: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      splashColor: ColorConfig.transparent,
                                      child: Container(
                                        width: (MediaQuery.of(context).size.width - 120.0.w) / 2,
                                        padding: const EdgeInsets.symmetric(vertical: 16.5),
                                        margin: const EdgeInsets.only(right: 8.0),
                                        decoration: BoxDecoration(
                                          color: ColorConfig().gray3(),
                                          borderRadius: BorderRadius.circular(4.0.r),
                                        ),
                                        child: Center(
                                          child: CustomTextBuilder(
                                            text: TextConstant.cancel,
                                            fontColor: ColorConfig().white(),
                                            fontSize: 14.0.sp,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        DeleteNotificationAllAPI().notificationDeleteAll(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
                                          if (value.result['status'] == 1) {
                                            setState(() {
                                              notificationList.clear();
                                            });
                                          } else {
                                            ToastModel().iconToast(value.result['message'], iconType: 2);
                                          }
                                          Navigator.pop(context);
                                        });
                                      },
                                      splashColor: ColorConfig.transparent,
                                      child: Container(
                                        width: (MediaQuery.of(context).size.width - 120.0.w) / 2,
                                        padding: const EdgeInsets.symmetric(vertical: 16.5),
                                        decoration: BoxDecoration(
                                          color: ColorConfig().accent(),
                                          borderRadius: BorderRadius.circular(4.0.r),
                                        ),
                                        child: Center(
                                          child: CustomTextBuilder(
                                            text: TextConstant.doDelete,
                                            fontColor: ColorConfig().white(),
                                            fontSize: 14.0.sp,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ).ig-publicDialog(context);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: ColorConfig().white(),
                            ),
                            child: CustomTextBuilder(
                              text: TextConstant.notificationDeleteAll,
                              fontColor: ColorConfig().dark(),
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            icon: SVGBuilder(
              image: 'assets/icon/more_vertical.svg'
            ),
          ),
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: ColorConfig().gray1(),
        child: notificationList.isNotEmpty ? ListView(
          children: List.generate(notificationList.length, (index) {
            if (index == notificationList.length - 1) {
              return Column(
                children: [
                  Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      PopupBuilder(
                        title: TextConstant.pushDeletePopupTitle,
                        content: TextConstant.pushDeletePopupDescription,
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                splashColor: ColorConfig.transparent,
                                child: Container(
                                  width: (MediaQuery.of(context).size.width - 120.0.w) / 2,
                                  padding: const EdgeInsets.symmetric(vertical: 16.5),
                                  margin: const EdgeInsets.only(right: 8.0),
                                  decoration: BoxDecoration(
                                    color: ColorConfig().gray3(),
                                    borderRadius: BorderRadius.circular(4.0.r),
                                  ),
                                  child: Center(
                                    child: CustomTextBuilder(
                                      text: TextConstant.cancel,
                                      fontColor: ColorConfig().white(),
                                      fontSize: 14.0.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  DeleteNotificationSingleAPI().notificationDeleteSingle(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), alarmIndex: notificationList[index]['alarm_index']).then((value) {
                                    if (value.result['status'] == 1) {
                                      setState(() {
                                        notificationList.removeAt(index);
                                      });
                                    } else {
                                      ToastModel().iconToast(value.result['message'], iconType: 2);
                                    }
                                    Navigator.pop(context);
                                  });
                                },
                                splashColor: ColorConfig.transparent,
                                child: Container(
                                  width: (MediaQuery.of(context).size.width - 120.0.w) / 2,
                                  padding: const EdgeInsets.symmetric(vertical: 16.5),
                                  decoration: BoxDecoration(
                                    color: ColorConfig().accent(),
                                    borderRadius: BorderRadius.circular(4.0.r),
                                  ),
                                  child: Center(
                                    child: CustomTextBuilder(
                                      text: TextConstant.doDelete,
                                      fontColor: ColorConfig().white(),
                                      fontSize: 14.0.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ).ig-publicDialog(context);
                    },
                    background: Container(
                      width: MediaQuery.of(context).size.width,
                      color: ColorConfig().accent(),
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      alignment: Alignment.centerRight,
                      child: CustomTextBuilder(
                        text: TextConstant.doDelete,
                        fontColor: ColorConfig().white(),
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    child: InkWell(
                      onTap: () async {
                        NotificationReadAPI().notificationRead(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), alarmIndex: notificationList[index]['alarm_index']).then((value) {
                          if (value.result['status'] == 1) {
                            setState(() {
                              notificationList[index]['is_read'] = 1;
                            });
                          }
                        });
                      },
                      child: Container(
                        color: notificationList[index]['is_read'] == 0 ? ColorConfig().white() : ColorConfig().gray1(),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 이미지
                            Container(
                              width: notificationList[index]['kind'] != 'S' ? 48.0.w : 42.0.w,
                              height: 48.0.w,
                              margin: const EdgeInsets.only(right: 10.0),
                              decoration: BoxDecoration(
                                color: notificationList[index]['kind'] == 'S' ? ColorConfig().gray2() : null,
                                borderRadius: notificationList[index]['kind'] != 'S' ? BorderRadius.circular(24.0.r) : BorderRadius.circular(10.0.r),
                                image: notificationList[index]['kind'] != 'S'
                                  ? notificationList[index]['image'] != null
                                    ? DecorationImage(
                                        image: NetworkImage(notificationList[index]['image']),
                                        fit: BoxFit.cover,
                                        filterQuality: FilterQuality.high,
                                      )
                                    : const DecorationImage(
                                        image: AssetImage('assets/img/profile_default.png'),
                                        fit: BoxFit.cover,
                                        filterQuality: FilterQuality.high,
                                      )
                                  : notificationList[index]['image'] != null
                                    ? DecorationImage(
                                        image: NetworkImage(notificationList[index]['image']),
                                        fit: BoxFit.cover,
                                        filterQuality: FilterQuality.high,
                                      )
                                    : null,
                              ),
                              child: notificationList[index]['kind'] == 'S' && notificationList[index]['image'] == null ? Center(
                                child: SVGBuilder(
                                  image: 'assets/icon/album.svg',
                                  width: 20.0.w,
                                  height: 20.0.w,
                                  color: ColorConfig().white()
                                ),
                              ) : Container(),
                            ),
                            // 텍스트
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 알림 타입
                                  CustomTextBuilder(
                                    text: notificationList[index]['category'] == 'C'
                                      ? '커뮤니티'
                                      : notificationList[index]['category'] == 'T'
                                        ? '티켓팅'
                                        : notificationList[index]['category'] == 'E'
                                          ? '이벤트'
                                          : notificationList[index]['category'] == 'N'
                                            ? '공지사항'
                                            : '',
                                    fontColor: notificationList[index]['category'] == 'C'
                                      ? ColorConfig().success()
                                      : notificationList[index]['category'] == 'T'
                                        ? ColorConfig().primary()
                                        : ColorConfig().accent(),
                                    fontSize: 10.0.sp,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                  ),
                                  // 알림 타이틀
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 8.0),
                                    child: CustomTextBuilder(
                                      text: '${notificationList[index]['title']}',
                                      fontColor: ColorConfig().dark(),
                                      fontSize: 14.0.sp,
                                      fontWeight: FontWeight.w800,
                                      height: 1.2,
                                    ),
                                  ),
                                  // 알림 날짜
                                  CustomTextBuilder(
                                    text: DateFormat('yyyy.MM.dd').format(DateTime.parse(notificationList[index]['create_dt']).toLocal()),
                                    fontColor: ColorConfig().gray3(),
                                    fontSize: 11.0.sp,
                                    fontWeight: FontWeight.w400,
                                    height: 1.2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 92.0.w,
                    child: Center(
                      child: CustomTextBuilder(
                        text: TextConstant.notificationListLimit,
                        fontColor: ColorConfig().gray3(),
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              );
            }
            
            return Dismissible(
              key: UniqueKey(),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  PopupBuilder(
                    title: TextConstant.pushDeletePopupTitle,
                    content: TextConstant.pushDeletePopupDescription,
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            splashColor: ColorConfig.transparent,
                            child: Container(
                              width: (MediaQuery.of(context).size.width - 120.0.w) / 2,
                              padding: const EdgeInsets.symmetric(vertical: 16.5),
                              margin: const EdgeInsets.only(right: 8.0),
                              decoration: BoxDecoration(
                                color: ColorConfig().gray3(),
                                borderRadius: BorderRadius.circular(4.0.r),
                              ),
                              child: Center(
                                child: CustomTextBuilder(
                                  text: TextConstant.cancel,
                                  fontColor: ColorConfig().white(),
                                  fontSize: 14.0.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              DeleteNotificationSingleAPI().notificationDeleteSingle(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), alarmIndex: notificationList[index]['alarm_index']).then((value) {
                                if (value.result['status'] == 1) {
                                  setState(() {
                                    notificationList.removeAt(index);
                                  });
                                } else {
                                  ToastModel().iconToast(value.result['message'], iconType: 2);
                                }
                                Navigator.pop(context);
                              });
                            },
                            splashColor: ColorConfig.transparent,
                            child: Container(
                              width: (MediaQuery.of(context).size.width - 120.0.w) / 2,
                              padding: const EdgeInsets.symmetric(vertical: 16.5),
                              decoration: BoxDecoration(
                                color: ColorConfig().accent(),
                                borderRadius: BorderRadius.circular(4.0.r),
                              ),
                              child: Center(
                                child: CustomTextBuilder(
                                  text: TextConstant.doDelete,
                                  fontColor: ColorConfig().white(),
                                  fontSize: 14.0.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).ig-publicDialog(context);
                },
                background: Container(
                  width: MediaQuery.of(context).size.width,
                  color: ColorConfig().accent(),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  alignment: Alignment.centerRight,
                  child: CustomTextBuilder(
                    text: TextConstant.doDelete,
                    fontColor: ColorConfig().white(),
                    fontSize: 14.0.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              child: InkWell(
                onTap: () async {
                  NotificationReadAPI().notificationRead(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), alarmIndex: notificationList[index]['alarm_index']).then((value) {
                    if (value.result['status'] == 1) {
                      setState(() {
                        notificationList[index]['is_read'] = 1;
                      });
                    }
            
                    if (notificationList[index]['type'] == 'F') {
                      Navigator.pushNamed(context, 'otherUserProfile', arguments: {
                        'user_index': notificationList[index]['target_user_index'],
                      });
                    } else if (notificationList[index]['type'] == 'R') {
                      Navigator.pushNamed(context, 'postDetail', arguments: {
                        'community_index': notificationList[index]['community_index'],
                      });
                    } else if (notificationList[index]['type'] == 'AT') {
                      Navigator.pushNamed(context, 'ticketHistory', arguments: {
                        "tabIndex": 0,
                      });
                    } else if (notificationList[index]['type'] == 'AS') {
                      Navigator.pushNamed(context, 'ticketHistory', arguments: {
                        "tabIndex": 0,
                      });
                    } else if (notificationList[index]['type'] == 'AF') {
                      Navigator.pushNamed(context, 'ticketHistory', arguments: {
                        "tabIndex": 1,
                      });
                    } else if (notificationList[index]['type'] == 'AL') {
                      Navigator.pushNamed(context, 'ticketHistory', arguments: {
                        "tabIndex": 1,
                      });
                    } else if (notificationList[index]['type'] == 'L') {
                      Navigator.pushNamed(context, 'postDetail', arguments: {
                        'community_index': notificationList[index]['community_index'],
                      });
                    } else if (notificationList[index]['type'] == 'TY') {
                      Navigator.pushNamed(context, 'ticketHistory', arguments: {
                        "tabIndex": 0,
                      });
                    }
                  });
                },
                child: Container(
                  color: notificationList[index]['is_read'] == 0 ? ColorConfig().white() : ColorConfig().gray1(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이미지
                      Container(
                        width: notificationList[index]['kind'] != 'S' ? 48.0.w : 42.0.w,
                        height: 48.0.w,
                        margin: const EdgeInsets.only(right: 10.0),
                        decoration: BoxDecoration(
                          color: notificationList[index]['kind'] == 'S' ? ColorConfig().gray2() : null,
                          borderRadius: notificationList[index]['kind'] != 'S' ? BorderRadius.circular(24.0.r) : BorderRadius.circular(10.0.r),
                          image: notificationList[index]['kind'] != 'S'
                            ? notificationList[index]['image'] != null
                              ? DecorationImage(
                                  image: NetworkImage(notificationList[index]['image']),
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                )
                              : const DecorationImage(
                                  image: AssetImage('assets/img/profile_default.png'),
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                )
                            : notificationList[index]['image'] != null
                              ? DecorationImage(
                                  image: NetworkImage(notificationList[index]['image']),
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                )
                              : null,
                        ),
                        child: notificationList[index]['kind'] == 'S' && notificationList[index]['image'] == null ? Center(
                          child: SVGBuilder(
                            image: 'assets/icon/album.svg',
                            width: 20.0.w,
                            height: 20.0.w,
                            color: ColorConfig().white()
                          ),
                        ) : Container(),
                      ),
                      // 텍스트
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 알림 타입
                            CustomTextBuilder(
                              text: notificationList[index]['category'] == 'C'
                                ? '커뮤니티'
                                : notificationList[index]['category'] == 'T'
                                  ? '티켓팅'
                                  : notificationList[index]['category'] == 'E'
                                    ? '이벤트'
                                    : notificationList[index]['category'] == 'N'
                                      ? '공지사항'
                                      : '',
                              fontColor: notificationList[index]['category'] == 'C'
                                ? ColorConfig().success()
                                : notificationList[index]['category'] == 'T'
                                  ? ColorConfig().primary()
                                  : ColorConfig().accent(),
                              fontSize: 10.0.sp,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                            // 알림 타이틀
                            Container(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: CustomTextBuilder(
                                text: '${notificationList[index]['title']}',
                                fontColor: ColorConfig().dark(),
                                fontSize: 14.0.sp,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                            // 알림 날짜
                            CustomTextBuilder(
                              text: DateFormat('yyyy.MM.dd').format(DateTime.parse(notificationList[index]['create_dt']).toLocal()),
                              fontColor: ColorConfig().gray3(),
                              fontSize: 11.0.sp,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ) : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60.0.w,
              height: 60.0.w,
              margin: const EdgeInsets.only(bottom: 24.0),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/img/no-data-search.png'),
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            CustomTextBuilder(
              text: '아직 받은 알림이 없습니다.',
              fontColor: ColorConfig().gray4(),
              fontSize: 14.0.sp,
              fontWeight: FontWeight.w400,
              height: 1.2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}