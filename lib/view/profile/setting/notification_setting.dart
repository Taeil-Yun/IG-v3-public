import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/costant/enumerated.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/switch/switch_builder.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingScreen extends StatefulWidget {
  const NotificationSettingScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingScreen> createState() => _NotificationSettingScreenState();
}

class _NotificationSettingScreenState extends State<NotificationSettingScreen> {
  bool allNotification = true;
  bool ticketingVacancy = true;
  bool auction = true;
  bool communityPostNews = true;
  bool communityNewPostOrReview = true;
  bool communityNewFollower = true;
  bool communityNewReply = true;
  bool communityNewLike = true;
  bool newQuest = true;

  @override
  void initState() {
    super.initState();

    getNotificationSetting();
  }

  Future<void> getNotificationSetting() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      allNotification = prefs.getBool('allNotification')!;
      ticketingVacancy = prefs.getBool('ticketingViewNotification')!;
      auction = prefs.getBool('auctionNotification')!;
      communityPostNews = prefs.getBool('ticketingNewsNotification')!;
      communityNewPostOrReview = prefs.getBool('newPostOrReviewNotification')!;
      communityNewFollower = prefs.getBool('newFollowerNotification')!;
      communityNewReply = prefs.getBool('newReplyNotification')!;
      communityNewLike = prefs.getBool('newLikeNotification')!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ig-publicAppBar(
        // systemUiOverlayStyle: Theme.of(context).appBarTheme.systemOverlayStyle,
        leading: ig-publicAppBarLeading(
          press: () => Navigator.pop(context),
        ),
        title: const ig-publicAppBarTitle(
          title: TextConstant.notificationSetting,
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: ColorConfig().gray1(),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              settingContent(
                text: TextConstant.allSendNotification,
                sendAll: true,
                subject: TextConstant.allSendNotificationDescription,
                widget: SwitchBuilder(
                  type: SwitchType.cupertino,
                  value: allNotification,
                  onChanged: (value) async {
                    final SharedPreferences prefs = await SharedPreferences.getInstance();

                    prefs.setBool('allNotification', value);
                    
                    setState(() {
                      allNotification = value;
                      ticketingVacancy = value;
                      auction = value;
                      communityPostNews = value;
                      communityNewPostOrReview = value;
                      communityNewFollower = value;
                      communityNewReply = value;
                      communityNewLike = value;
                      newQuest = value;
                    });
                  },
                ),
              ),
              dividerWidget(useBorder: false),
              settingCategories(category: TextConstant.ticketingNotification),
              settingContent(
                text: TextConstant.ticketingViewNotification,
                widget: SwitchBuilder(
                  type: SwitchType.cupertino,
                  value: ticketingVacancy,
                  onChanged: (value) async {
                    final SharedPreferences prefs = await SharedPreferences.getInstance();

                    prefs.setBool('ticketingViewNotification', value);

                    if (value == false) {
                      prefs.setBool('allNotification', false);
                    }

                    setState(() {
                      ticketingVacancy = value;
                    });
                  },
                ),
              ),
              settingContent(
                text: TextConstant.auctionNotification,
                widget: SwitchBuilder(
                  type: SwitchType.cupertino,
                  value: auction,
                  onChanged: (value) async {
                    final SharedPreferences prefs = await SharedPreferences.getInstance();

                    prefs.setBool('auctionNotification', value);

                    if (value == false) {
                      prefs.setBool('allNotification', false);
                    }

                    setState(() {
                      auction = value;
                    });
                  },
                ),
              ),
              dividerWidget(),
              dividerWidget(useBorder: false),
              settingCategories(category: TextConstant.communityNotification),
              settingContent(
                text: TextConstant.communityTicketingNewsNotification,
                widget: SwitchBuilder(
                  type: SwitchType.cupertino,
                  value: communityPostNews,
                  onChanged: (value) async {
                    final SharedPreferences prefs = await SharedPreferences.getInstance();

                    prefs.setBool('ticketingNewsNotification', value);

                    if (value == false) {
                      prefs.setBool('allNotification', false);
                    }

                    setState(() {
                      communityPostNews = value;
                    });
                  },
                ),
              ),
              settingContent(
                text: TextConstant.communityNewPostOrReviewNotification,
                widget: SwitchBuilder(
                  type: SwitchType.cupertino,
                  value: communityNewPostOrReview,
                  onChanged: (value) async {
                    final SharedPreferences prefs = await SharedPreferences.getInstance();

                    prefs.setBool('newPostOrReviewNotification', value);

                    if (value == false) {
                      prefs.setBool('allNotification', false);
                    }

                    setState(() {
                      communityNewPostOrReview = value;
                    });
                  },
                ),
              ),
              settingContent(
                text: TextConstant.communityNewFollowerNotification,
                widget: SwitchBuilder(
                  type: SwitchType.cupertino,
                  value: communityNewFollower,
                  onChanged: (value) async {
                    final SharedPreferences prefs = await SharedPreferences.getInstance();

                    prefs.setBool('newFollowerNotification', value);

                    if (value == false) {
                      prefs.setBool('allNotification', false);
                    }

                    setState(() {
                      communityNewFollower = value;
                    });
                  },
                ),
              ),
              settingContent(
                text: TextConstant.communityNewReplyNotification,
                widget: SwitchBuilder(
                  type: SwitchType.cupertino,
                  value: communityNewReply,
                  onChanged: (value) async {
                    final SharedPreferences prefs = await SharedPreferences.getInstance();

                    prefs.setBool('newReplyNotification', value);

                    if (value == false) {
                      prefs.setBool('allNotification', false);
                    }

                    setState(() {
                      communityNewReply = value;
                    });
                  },
                ),
              ),
              settingContent(
                text: TextConstant.communityNewLikeNotification,
                widget: SwitchBuilder(
                  type: SwitchType.cupertino,
                  value: communityNewLike,
                  onChanged: (value) async {
                    final SharedPreferences prefs = await SharedPreferences.getInstance();

                    prefs.setBool('newLikeNotification', value);

                    if (value == false) {
                      prefs.setBool('allNotification', false);
                    }

                    setState(() {
                      communityNewLike = value;
                    });
                  },
                ),
              ),
              // divider
              dividerWidget(),
              dividerWidget(useBorder: false),
              // // 포인트적립 알림 타이틀
              // settingCategories(category: TextConstant.earnPointNotification),
              // // 새로운 퀘스트 알림
              // settingContent(
              //   text: TextConstant.newQuestNotification,
              //   widget: SwitchBuilder(
              //     type: SwitchType.cupertino,
              //     value: newQuest,
              //     onChanged: (value) async {
              //       newQuest = value;
              //     },
              //   ),
              // ),
              const SizedBox(height: 40.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget settingCategories({required String category}) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: CustomTextBuilder(
        text: category,
        fontColor: ColorConfig().dark(),
        fontSize: 16.0.sp,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget settingContent({required String text, required Widget widget, bool sendAll = false, String? subject}) {
    if (sendAll) {
      return Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(20.0),
        color: ColorConfig().white(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 6.0),
                  child: CustomTextBuilder(
                    text: text,
                    fontColor: ColorConfig().dark(),
                    fontSize: 14.0.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                CustomTextBuilder(
                  text: subject!,
                  fontColor: ColorConfig().gray4(),
                  fontSize: 14.0.sp,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
            widget,
          ],
        ),
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextBuilder(
            text: text,
            fontColor: ColorConfig().dark(),
            fontSize: 14.0.sp,
            fontWeight: FontWeight.w700,
          ),
          widget,
        ],
      ),
    );
  }

  Widget dividerWidget({bool useBorder = true}) {
    return Container(
      height: 16.0,
      decoration: BoxDecoration(
        border: useBorder ? Border(
          bottom: BorderSide(
            width: 1.0,
            color: ColorConfig().gray2(),
          ),
        ) : null,
      ),
    );
  }
}