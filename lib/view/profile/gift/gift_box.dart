import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/api/gift/cancel_gift.dart';
import 'package:ig-public_v3/api/gift/gift_list.dart';
import 'package:ig-public_v3/component/popup/popup.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/costant/build_config.dart';

import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/util/toast.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:ig-public_v3/widget/sliver_tabbar_widget.dart';
import 'package:intl/intl.dart';

class GiftBoxScreen extends StatefulWidget {
  const GiftBoxScreen({super.key});

  @override
  State<GiftBoxScreen> createState() => _GiftBoxScreenState();
}

class _GiftBoxScreenState extends State<GiftBoxScreen> with SingleTickerProviderStateMixin {
  late TabController tabController;

  Map<String, dynamic> giftDatas = {};

  @override
  void initState() {
    super.initState();

    tabController = TabController(
      length: 2,
      vsync: this
    );

    initializeAPI();
  }

  @override
  void dispose() {
    super.dispose();

    tabController.dispose();
  }

  Future<void> initializeAPI() async {
    GiftListAPI().giftList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
      setState(() {
        giftDatas = value.result['data'];
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
          title: TextConstant.giftBox,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(46.0),
          child: TabBar(
            controller: tabController,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            isScrollable: false,
            labelColor: ColorConfig().dark(),
            labelStyle: TextStyle(
              fontSize: 14.0.sp,
              fontWeight: FontWeight.w800,
            ),
            unselectedLabelColor: ColorConfig().gray3(),
            unselectedLabelStyle: TextStyle(
              fontSize: 14.0.sp,
              fontWeight: FontWeight.w800,
            ),
            indicator: CustomTabIndicator(
              color: ColorConfig().dark(),
              height: 4.0,
              tabPosition: TabPosition.bottom,
              horizontalPadding: 12.0,
            ),
            tabs: const [
              Tab(
                text: TextConstant.receiveGift,
              ),
              Tab(
                text: TextConstant.sendGift,
              ),
            ],
          ),
        ),
      ),
      body: giftDatas.isNotEmpty ? Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: ColorConfig().gray1(),
        child: SafeArea(
          child: TabBarView(
            controller: tabController,
            children: [
              receiveGiftListWidget(),
              sendGiftListWidget(),
            ],
          ),
        ),
      ) : Container(),
    );
  }

  // 받은 선물 리스트 위젯
  Widget receiveGiftListWidget() {
    if (giftDatas['receive'].isEmpty) {
      return Column(
        children: [
          Container(
            width: 150.0.w,
            height: 190.0.w,
            margin: const EdgeInsets.only(top: 140.0, bottom: 24.0),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/no-data-gift.png'),
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          CustomTextBuilder(
            text: '받은 선물이 없습니다.',
            fontColor: ColorConfig().gray4(),
            fontSize: 14.0.sp,
            fontWeight: FontWeight.w400,
            height: 1.2,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: giftDatas['receive'].length,
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 16.0, bottom: 40.0),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
          margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: ColorConfig().white(),
            borderRadius: BorderRadius.circular(4.0.r),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 80.0.w,
                      height: 114.0.w,
                      margin: const EdgeInsets.only(right: 16.0),
                      decoration: BoxDecoration(
                        color: giftDatas['receive'][index]['image'] == null ? ColorConfig().gray2() : null,
                        borderRadius: BorderRadius.circular(4.0.r),
                        image: giftDatas['receive'][index]['image'] != null ? DecorationImage(
                          image: NetworkImage(giftDatas['receive'][index]['image']),
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        ) : null,
                      ),
                      child: giftDatas['receive'][index]['image'] == null ? Center(
                        child: SVGBuilder(
                          image: 'assets/icon/album.svg',
                          width: 24.0.w,
                          height: 24.0.w,
                          color: ColorConfig().white(),
                        ),
                      ) : Container(),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 공연 제목 영역
                          CustomTextBuilder(
                            text: '${giftDatas['receive'][index]['name']}',
                            fontColor: ColorConfig().dark(),
                            fontSize: 14.0.sp,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                          // 날짜 영역
                          Container(
                            margin: const EdgeInsets.only(top: 5.0, bottom: 18.0),
                            child: Text.rich(
                              TextSpan(
                                children: <TextSpan> [
                                  TextSpan(
                                    text: DateFormat('yyyy. MM. dd.').format(DateTime.parse(giftDatas['receive'][index]['open_date']).toLocal()),
                                    style: TextStyle(
                                      color: ColorConfig().gray5(),
                                      fontSize: 12.0.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '  |  ',
                                    style: TextStyle(
                                      color: ColorConfig().gray2(),
                                      fontSize: 12.0.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text: DateFormat('aa HH시 mm분', 'ko').format(DateTime.parse(giftDatas['receive'][index]['open_date']).toLocal()),
                                    style: TextStyle(
                                      color: ColorConfig().gray5(),
                                      fontSize: 12.0.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // 보낸 사람 영역
                          Row(
                            children: [
                              SizedBox(
                                width: 60.0.w,
                                child: CustomTextBuilder(
                                  text: TextConstant.sendGiftUsername,
                                  fontColor: ColorConfig().gray4(),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Expanded(
                                child: CustomTextBuilder(
                                  text: '${giftDatas['receive'][index]['user_name']}',
                                  fontColor: ColorConfig().dark(),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          // 수량 영역
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 60.0.w,
                                  child: CustomTextBuilder(
                                    text: TextConstant.sendGiftAmount,
                                    fontColor: ColorConfig().gray4(),
                                    fontSize: 12.0.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Expanded(
                                  child: CustomTextBuilder(
                                    text: '${giftDatas['receive'][index]['ticket_detail'].length}매',
                                    fontColor: ColorConfig().dark(),
                                    fontSize: 12.0.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 좌석번호 영역
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 60.0.w,
                                child: CustomTextBuilder(
                                  text: TextConstant.sendGiftSeatNumber,
                                  fontColor: ColorConfig().gray4(),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(giftDatas['receive'][index]['ticket_detail'].length, (ticketName) {
                                    return CustomTextBuilder(
                                      text: '${giftDatas['receive'][index]['ticket_detail'][ticketName]['seat_name']}',
                                      fontColor: ColorConfig().dark(),
                                      fontSize: 12.0.sp,
                                      fontWeight: FontWeight.w700,
                                      height: 1.2,
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 예매내역 보기 버튼 영역
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, 'ticketHistory', arguments: {
                    'tabIndex': 0,
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 13.0),
                  margin: const EdgeInsets.only(top: 8.0),
                  decoration: BoxDecoration(
                    color: ColorConfig().primary(),
                    borderRadius: BorderRadius.circular(4.0.r),
                  ),
                  child: Center(
                    child: CustomTextBuilder(
                      text: TextConstant.showTicketReservation,
                      fontColor: ColorConfig().white(),
                      fontSize: 13.0.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 보낸선물 리스트 위젯
  Widget sendGiftListWidget() {
    if (giftDatas['give_gift'].isEmpty) {
      return Column(
        children: [
          Container(
            width: 150.0.w,
            height: 190.0.w,
            margin: const EdgeInsets.only(top: 140.0, bottom: 24.0),
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/no-data-gift.png'),
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          CustomTextBuilder(
            text: '보낸 선물이 없습니다.',
            fontColor: ColorConfig().gray4(),
            fontSize: 14.0.sp,
            fontWeight: FontWeight.w400,
            height: 1.2,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: giftDatas['give_gift'].length,
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 16.0, bottom: 40.0),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
          margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: ColorConfig().white(),
            borderRadius: BorderRadius.circular(4.0.r),
            boxShadow: [
              BoxShadow(
                offset: const Offset(0.0, 1.0),
                color: ColorConfig().overlay(opacity: 0.06),
                blurRadius: 4.0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntrinsicWidth(
                child: Container(
                  margin: const EdgeInsets.only(top: 8.0),
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: giftDatas['give_gift'][index]['is_receive'] == 0
                      ? ColorConfig().gray5()
                      : giftDatas['give_gift'][index]['is_receive'] == 1
                        ? ColorConfig().primary()
                        : giftDatas['give_gift'][index]['is_receive'] == 2
                          ? ColorConfig().accent()
                          : giftDatas['give_gift'][index]['is_receive'] == 3
                            ? ColorConfig().gray3(opacity: 0.2)
                            : ColorConfig.transparent,
                    borderRadius: BorderRadius.circular(2.0.r),
                  ),
                  child: Center(
                    child: CustomTextBuilder(
                      text: giftDatas['give_gift'][index]['is_receive'] == 0
                        ? TextConstant.waitAccept
                        : giftDatas['give_gift'][index]['is_receive'] == 1
                          ? TextConstant.completeAccept
                          : giftDatas['give_gift'][index]['is_receive'] == 2
                            ? TextConstant.rejectAccept
                            : giftDatas['give_gift'][index]['is_receive'] == 3
                              ? TextConstant.cancelGift
                              : '',
                      fontColor: ColorConfig().white(),
                      fontSize: 12.0.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 80.0.w,
                      height: 114.0.w,
                      margin: const EdgeInsets.only(right: 16.0),
                      decoration: BoxDecoration(
                        color: giftDatas['give_gift'][index]['image'] == null ? ColorConfig().gray2(opacity: giftDatas['give_gift'][index]['is_receive'] == 3 ? 0.1 : 1) : null,
                        borderRadius: BorderRadius.circular(4.0.r),
                        image: giftDatas['give_gift'][index]['image'] != null ? DecorationImage(
                          image: NetworkImage(giftDatas['give_gift'][index]['image']),
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                          opacity: giftDatas['give_gift'][index]['is_receive'] == 3 ? 0.1 : 1,
                        ) : null,
                      ),
                      child: giftDatas['give_gift'][index]['image'] == null ? Center(
                        child: SVGBuilder(
                          image: 'assets/icon/album.svg',
                          width: 24.0.w,
                          height: 24.0.w,
                          color: ColorConfig().white(opacity: giftDatas['give_gift'][index]['is_receive'] == 3 ? 0.1 : 1),
                        ),
                      ) : Container(),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 공연 제목 영역
                          CustomTextBuilder(
                            text: '${giftDatas['give_gift'][index]['name']}',
                            fontColor: ColorConfig().dark(opacity: giftDatas['give_gift'][index]['is_receive'] == 3 ? 0.1 : 1),
                            fontSize: 14.0.sp,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                          // 날짜 영역
                          Container(
                            margin: const EdgeInsets.only(top: 5.0, bottom: 18.0),
                            child: Text.rich(
                              TextSpan(
                                children: <TextSpan> [
                                  TextSpan(
                                    text: DateFormat('yyyy. MM. dd.').format(DateTime.parse(giftDatas['give_gift'][index]['open_date']).toLocal()),
                                    style: TextStyle(
                                      color: ColorConfig().gray5(opacity: giftDatas['give_gift'][index]['is_receive'] == 3 ? 0.1 : 1),
                                      fontSize: 12.0.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '  |  ',
                                    style: TextStyle(
                                      color: ColorConfig().gray2(opacity: giftDatas['give_gift'][index]['is_receive'] == 3 ? 0.1 : 1),
                                      fontSize: 12.0.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text: DateFormat('aa HH시 mm분', 'ko').format(DateTime.parse(giftDatas['give_gift'][index]['open_date']).toLocal()),
                                    style: TextStyle(
                                      color: ColorConfig().gray5(opacity: giftDatas['give_gift'][index]['is_receive'] == 3 ? 0.1 : 1),
                                      fontSize: 12.0.sp,
                                      fontWeight: FontWeight.w700,
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // 받는 사람 영역
                          giftDatas['give_gift'][index]['user_name'] != null ? Row(
                            children: [
                              SizedBox(
                                width: 60.0.w,
                                child: CustomTextBuilder(
                                  text: TextConstant.receiver,
                                  fontColor: ColorConfig().gray4(opacity: giftDatas['give_gift'][index]['is_receive'] == 3 ? 0.1 : 1),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Expanded(
                                child: CustomTextBuilder(
                                  text: '${giftDatas['give_gift'][index]['user_name']}',
                                  fontColor: ColorConfig().dark(opacity: giftDatas['give_gift'][index]['is_receive'] == 3 ? 0.1 : 1),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ) : Container(),
                          // 수량 영역
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 60.0.w,
                                  child: CustomTextBuilder(
                                    text: TextConstant.sendGiftAmount,
                                    fontColor: ColorConfig().gray4(opacity: giftDatas['give_gift'][index]['is_receive'] == 3 ? 0.1 : 1),
                                    fontSize: 12.0.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Expanded(
                                  child: CustomTextBuilder(
                                    text: '${giftDatas['give_gift'][index]['ticket_detail'].length}매',
                                    fontColor: ColorConfig().dark(opacity: giftDatas['give_gift'][index]['is_receive'] == 3 ? 0.1 : 1),
                                    fontSize: 12.0.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 좌석번호 영역
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 60.0.w,
                                child: CustomTextBuilder(
                                  text: TextConstant.sendGiftSeatNumber,
                                  fontColor: ColorConfig().gray4(opacity: giftDatas['give_gift'][index]['is_receive'] == 3 ? 0.1 : 1),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(giftDatas['give_gift'][index]['ticket_detail'].length, (seatName) {
                                    return CustomTextBuilder(
                                      text: '${giftDatas['give_gift'][index]['ticket_detail'][seatName]['seat_name']}',
                                      fontColor: ColorConfig().dark(opacity: giftDatas['give_gift'][index]['is_receive'] == 3 ? 0.1 : 1),
                                      fontSize: 12.0.sp,
                                      fontWeight: FontWeight.w700,
                                      height: 1.2,
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 버튼 영역
              giftDatas['give_gift'][index]['is_receive'] == 1 || giftDatas['give_gift'][index]['is_receive'] == 3 ? Container() : InkWell(
                onTap: () {
                  switch (giftDatas['give_gift'][index]['is_receive']) {
                    case 0:
                      PopupBuilder(
                        title: TextConstant.cancelGiftTitle,
                        content: TextConstant.cancelGiftContent,
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
                                      text: TextConstant.close,
                                      fontColor: ColorConfig().white(),
                                      fontSize: 14.0.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  CancelGiftDataAPI().cancelGift(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), giftGroup: giftDatas['give_gift'][index]['gift_group']).then((d) {
                                    Navigator.pop(context);

                                    if (d.result['status'] == 1) {
                                      ToastModel().iconToast(d.result['message']);

                                      initializeAPI();
                                    } else {
                                      ToastModel().iconToast(d.result['message'], iconType: 2);
                                    }
                                  });
                                },
                                splashColor: ColorConfig.transparent,
                                child: Container(
                                  width: (MediaQuery.of(context).size.width - 120.0.w) / 2,
                                  padding: const EdgeInsets.symmetric(vertical: 16.5),
                                  decoration: BoxDecoration(
                                    color: ColorConfig().dark(),
                                    borderRadius: BorderRadius.circular(4.0.r),
                                  ),
                                  child: Center(
                                    child: CustomTextBuilder(
                                      text: TextConstant.doCancel,
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
                      break;
                    default:
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  margin: const EdgeInsets.only(top: 8.0),
                  decoration: BoxDecoration(
                  color: ColorConfig().primary(),
                    borderRadius: BorderRadius.circular(4.0.r),
                  ),
                  child: Center(
                    child: CustomTextBuilder(
                      text: giftDatas['give_gift'][index]['is_receive'] != 2 ? TextConstant.cancelGift : TextConstant.ok,
                      fontColor: ColorConfig().white(),
                      fontSize: 13.0.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}