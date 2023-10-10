import 'dart:math';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:ig-public_v3/api/gift/cancel_gift.dart';
import 'package:ig-public_v3/api/history/ticket_history_detail.dart';
import 'package:ig-public_v3/api/ticket/send_gift_ticket.dart';
import 'package:ig-public_v3/api/ticket/send_gift_ticket_detail.dart';
import 'package:ig-public_v3/costant/enumerated.dart';
import 'package:ig-public_v3/costant/keys.dart';
import 'package:ig-public_v3/util/deep_link.dart';
import 'package:intl/intl.dart';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/api/history/ticket_history.dart';
import 'package:ig-public_v3/api/auction/auction_betting_seat.dart';
import 'package:ig-public_v3/api/auction/auction_cancel.dart';
import 'package:ig-public_v3/api/history/auction_history.dart';
import 'package:ig-public_v3/component/date_calculator/date_calculator.dart';
import 'package:ig-public_v3/component/popup/popup.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/util/set_intl.dart';
import 'package:ig-public_v3/src/route_argument.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:ig-public_v3/widget/sliver_tabbar_widget.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:permission_handler/permission_handler.dart';

class TicketHistoryScreen extends StatefulWidget {
  const TicketHistoryScreen({super.key});

  @override
  State<TicketHistoryScreen> createState() => _TicketHistoryScreenState();
}

class _TicketHistoryScreenState extends State<TicketHistoryScreen> with TickerProviderStateMixin {
  late TabController tabController;
  late TextEditingController giftReceiverTextController;
  late TextEditingController giftMessageTextController;
  late FocusNode giftReceiverFocusNode;
  late FocusNode giftMessageFocusNode;
  late ScrollController giftBottomSheetScroller;
  
  List auctionHistoryData = [];

  Map<String, dynamic> ticketHistoryData = {};

  @override
  void initState() {
    super.initState();

    tabController = TabController(
      length: 2,
      vsync: this
    );
    
    giftReceiverTextController = TextEditingController()..addListener(() {
      setState(() {});
    });
    giftMessageTextController = TextEditingController()..addListener(() {
      setState(() {});
    });
    giftReceiverFocusNode = FocusNode();
    giftMessageFocusNode = FocusNode();

    giftBottomSheetScroller = ScrollController();

    Future.delayed(Duration.zero, () {
      if (RouteGetArguments().getArgs(context)['tabIndex'] != null) {
        setState(() {
          tabController.index = RouteGetArguments().getArgs(context)['tabIndex'];
        });
      }
    });

    initializeAPI();
  }

  @override
  void dispose() {
    super.dispose();

    tabController.dispose();
    giftReceiverTextController.dispose();
    giftMessageTextController.dispose();
    giftReceiverFocusNode.dispose();
    giftMessageFocusNode.dispose();
    giftBottomSheetScroller.dispose();
  }

  Future<void> initializeAPI() async {
    TicketHistoryAPI().ticketHistory(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
      setState(() {
        ticketHistoryData = value.result['data'];
      });
    });
    AuctionHistoryAPI().auctionHistory(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
      setState(() {
        auctionHistoryData = value.result['data'];
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
          title: TextConstant.ticketHistory,
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
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextBuilder(
                      text: TextConstant.ticketHistoryMyTicket,
                    ),
                    CustomTextBuilder(
                      text: ticketHistoryData.isNotEmpty ? ' ${ticketHistoryData['before'].length}' : ' 0',
                      fontColor: ColorConfig().primary(),
                      fontSize: 14.0.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextBuilder(
                      text: TextConstant.ticketHistoryAuctionState,
                    ),
                    CustomTextBuilder(
                      text: ' ${auctionHistoryData.isNotEmpty ? auctionHistoryData.length : 0}',
                      fontColor: ColorConfig().primary(),
                      fontSize: 14.0.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: ticketHistoryData.isNotEmpty ? Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: ColorConfig().gray1(),
        child: SafeArea(
          child: TabBarView(
            controller: tabController,
            children: [
              // 나의티켓 영역
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: ticketHistoryData['before'].isNotEmpty && ticketHistoryData['watched'].isNotEmpty ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // sorting 영역
                    // sortingWidget(),
                    // 관람전 티켓 타이틀 영역
                    myTicketSeparatorWidget(text: TextConstant.beforeSelectShow, count: ticketHistoryData['before'].length),
                    // 관람전 티켓 리스트 영역
                    beforeViewTicketListWidget(),
                    const SizedBox(height: 8.0),
                    // 관람 완료 티켓 타이틀 영역
                    myTicketSeparatorWidget(text: TextConstant.viewFinishTicket, count: ticketHistoryData['watched'].length),
                    // 관람 완료 티켓 리스트 영역
                    viewFinishTicketListWidget(),
                  ],
                ) : SizedBox(
                  height: MediaQuery.of(context).size.height / 1.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60.0.w,
                        height: 60.0.w,
                        margin: const EdgeInsets.only(bottom: 24.0),
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/img/no-data-ticket-history.png'),
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                      CustomTextBuilder(
                        text: '아직 예매한 티켓이 없습니다 없습니다.\n티켓팅 메뉴에서 보고싶은 공연을 예매/경매 해보세요.',
                        fontColor: ColorConfig().gray4(),
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // sorting 영역
                    // sortingWidget(),
                    // 경매현황 리스트 영역
                    auctionStateListWidget(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ) : Container(),
    );
  }

  // sorting 위젯
  Widget sortingWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 8.0),
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.fromLTRB(10.0, 8.0, 8.0, 8.0),
          decoration: BoxDecoration(
            color: ColorConfig().white(),
            border: Border.all(
              width: 1.0,
              color: ColorConfig().gray2(),
            ),
            borderRadius: BorderRadius.circular(4.0.r),
          ),
          child: Row(
            children: [
              CustomTextBuilder(
                text: TextConstant.all,
                fontColor: ColorConfig().gray5(),
                fontSize: 12.0.sp,
                fontWeight: FontWeight.w700,
              ),
              Container(
                margin: const EdgeInsets.only(left: 4.0),
                child: SVGBuilder(
                  image: 'assets/icon/arrow_down_light.svg',
                  width: 16.0.w,
                  height: 16.0.w,
                  color: ColorConfig().gray5(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 나의티켓 구분자 타이틀 위젯
  Widget myTicketSeparatorWidget({required String text, required int count, bool viewFinish = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.5),
      child: Row(
        children: [
          CustomTextBuilder(
            text: text,
            fontColor: ColorConfig().dark(),
            fontSize: 14.0.sp,
            fontWeight: FontWeight.w700,
          ),
          Container(
            margin: const EdgeInsets.only(left: 4.0),
            child: CustomTextBuilder(
              text: '$count',
              fontColor: viewFinish ? ColorConfig().primary() : ColorConfig().gray3(),
              fontSize: 14.0.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // 티켓 리스트 위젯
  Widget beforeViewTicketListWidget() {
    return Column(
      children: List.generate(ticketHistoryData['before'].length, (index) {
        String seatNamesToString = '';

        for (int i=0; i<ticketHistoryData['before'][index]['ticket_detail'].length; i++) {
          seatNamesToString += (ticketHistoryData['before'][index]['ticket_detail'][i]['seat_name'] + ', ');
        }

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    index == 0
                      ? Stack(
                        children: [
                          Container(
                            width: 80.0.w,
                            height: 114.0.w,
                            margin: const EdgeInsets.only(right: 16.0),
                            decoration: BoxDecoration(
                              color: ticketHistoryData['before'][index]['image'] == null ? ColorConfig().gray2() : null,
                              borderRadius: BorderRadius.circular(4.0.r),
                              image: ticketHistoryData['before'][index]['image'] != null ? DecorationImage(
                                image: NetworkImage(ticketHistoryData['before'][index]['image']),
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                              ) : null,
                            ),
                            child: ticketHistoryData['before'][index]['image'] == null ? Center(
                              child: SVGBuilder(
                                image: 'assets/icon/album.svg',
                                width: 22.0.w,
                                height: 22.0.w,
                                color: ColorConfig().white(),
                              ),
                            ) : Container(),
                          ),
                          // Positioned(
                          //   top: 4.0,
                          //   left: 4.0,
                          //   child: Container(
                          //     padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.5),
                          //     decoration: BoxDecoration(
                          //       color: ColorConfig().accent(),
                          //       borderRadius: BorderRadius.circular(2.0.r),
                          //     ),
                          //     child: Center(
                          //       child: CustomTextBuilder(
                          //         text: 'D-3',
                          //         fontColor: ColorConfig().white(),
                          //         fontSize: 12.0.sp,
                          //         fontWeight: FontWeight.w700,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      )
                      : Container(
                          width: 80.0.w,
                          height: 114.0.w,
                          margin: const EdgeInsets.only(right: 16.0),
                          decoration: BoxDecoration(
                            color: ticketHistoryData['before'][index]['image'] == null ? ColorConfig().gray2() : null,
                            borderRadius: BorderRadius.circular(4.0.r),
                            image: ticketHistoryData['before'][index]['image'] != null ? DecorationImage(
                              image: NetworkImage(ticketHistoryData['before'][index]['image']),
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            ) : null,
                          ),
                          child: ticketHistoryData['before'][index]['image'] == null ? Center(
                            child: SVGBuilder(
                              image: 'assets/icon/album.svg',
                              width: 22.0.w,
                              height: 22.0.w,
                              color: ColorConfig().white(),
                            ),
                          ) : Container(),
                        ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 경매성공 label
                          ticketHistoryData['before'][index]['is_auction'] == 1 ? Container(
                            margin: const EdgeInsets.only(top: 2.0),
                            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: ColorConfig().success(),
                              borderRadius: BorderRadius.circular(2.0.r),
                            ),
                            child: CustomTextBuilder(
                              text: TextConstant.auctionInSuccess,
                              fontColor: ColorConfig().white(),
                              fontSize: 12.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ) : Container(),
                          // 티켓발급예정 label
                          ticketHistoryData['before'][index]['is_auction'] == 2 ? Container(
                            margin: const EdgeInsets.only(top: 2.0),
                            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: ColorConfig().gray3(),
                              borderRadius: BorderRadius.circular(2.0.r),
                            ),
                            child: CustomTextBuilder(
                              text: TextConstant.ticketDerivate,
                              fontColor: ColorConfig().white(),
                              fontSize: 12.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ) : Container(),
                          // 선물받은티켓 label
                          ticketHistoryData['before'][index]['is_gift'] == 1 ? Container(
                            margin: const EdgeInsets.only(top: 2.0),
                            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: ColorConfig().primary(),
                              borderRadius: BorderRadius.circular(2.0.r),
                            ),
                            child: CustomTextBuilder(
                              text: TextConstant.receiveTicket,
                              fontColor: ColorConfig().white(),
                              fontSize: 12.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ) : Container(),
                          // 공연 제목 영역
                          Container(
                            margin: ticketHistoryData['before'][index]['is_auction'] == 0 ? const EdgeInsets.only(top: 2.0, bottom: 8.0) : const EdgeInsets.symmetric(vertical: 8.0),
                            child: CustomTextBuilder(
                              text: '${ticketHistoryData['before'][index]['name']}',
                              fontColor: ColorConfig().dark(),
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              maxLines: 2,
                              textOverflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // 날짜 영역
                          Container(
                            margin: const EdgeInsets.only(bottom: 4.0),
                            child: Text.rich(
                              TextSpan(
                                children: <TextSpan> [
                                  TextSpan(
                                    text: DateFormat('yyyy. M. dd').format(DateTime.parse(ticketHistoryData['before'][index]['open_date']).toLocal()),
                                    style: TextStyle(
                                      color: ColorConfig().gray5(),
                                      fontSize: 12.0.sp,
                                      fontWeight: FontWeight.w700,
                                      height: 1.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '   ',
                                    style: TextStyle(
                                      color: ColorConfig().gray2(),
                                      fontSize: 12.0.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(
                                    text: DateFormat('aa hh:mm', 'ko').format(DateTime.parse(ticketHistoryData['before'][index]['open_date']).toLocal()),
                                    style: TextStyle(
                                      color: ColorConfig().gray5(),
                                      fontSize: 12.0.sp,
                                      fontWeight: FontWeight.w700,
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // 좌석 영역
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 25.0.w,
                                margin: const EdgeInsets.only(right: 8.0),
                                child: CustomTextBuilder(
                                  text: TextConstant.seat,
                                  fontColor: ColorConfig().gray4(),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Expanded(
                                child: CustomTextBuilder(
                                  text: seatNamesToString,
                                  fontColor: ColorConfig().gray5(),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                          // 보낸사람 영역
                          ticketHistoryData['before'][index]['is_gift'] == 1 ? Container(
                            margin: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 50.0.w,
                                  margin: const EdgeInsets.only(right: 8.0),
                                  child: CustomTextBuilder(
                                    text: TextConstant.sender,
                                    fontColor: ColorConfig().gray4(),
                                    fontSize: 12.0.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Expanded(
                                  child: CustomTextBuilder(
                                    text: '${ticketHistoryData['before'][index]['sender_user_name']}',
                                    fontColor: ColorConfig().gray5(),
                                    fontSize: 12.0.sp,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ) : Container(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 버튼 영역
              Container(
                margin: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 취소하기 버튼
                    ticketHistoryData['before'][index]['is_auction'] != 2 ? InkWell(
                      onTap: () async {
                        if (ticketHistoryData['before'][index]['is_gift'] == 1 && ticketHistoryData['before'][index]['is_refund'] == 0) {
                          PopupBuilder(
                            title: TextConstant.giftTicketCancelTitle,
                            content: '',
                            onContentWidget: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextBuilder(
                                  text: TextConstant.giftTicketCancelDescriptionForSender,
                                  fontColor: ColorConfig().gray5(),
                                  fontSize: 14.0.sp,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                                Container(
                                  margin: const EdgeInsets.only(top: 12.0),
                                  child: CustomTextBuilder(
                                    text: TextConstant.giftTicketCancelSubDescription,
                                    fontColor: ColorConfig().accent(),
                                    fontSize: 11.0.sp,
                                    fontWeight: FontWeight.w400,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
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
                                      CancelGiftDataAPI().cancelGift(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), giftGroup: ticketHistoryData['before'][index]['ticket_group']).then((value) {
                                        setState(() {
                                          ticketHistoryData['before'].removeAt(index);
                                        });
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
                        } else {
                          TicketHistoryDetailAPI().detail(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), ticketGroupNumber: ticketHistoryData['before'][index]['ticket_group'].toString()).then((detailData) {
                            detailData.result['data']['ticket_detail'] = ticketHistoryData['before'][index]['ticket_detail'];
                            
                            Navigator.pushNamed(context, 'ticketCancel', arguments: {
                              'ticket_data': detailData.result['data'],
                            }).then((returnData) async {
                              if (returnData != null) {
                                TicketHistoryAPI().ticketHistory(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
                                  setState(() {
                                    ticketHistoryData = value.result['data'];
                                  });
                                });
                              }
                            });
                          });
                        }

                      },
                      child: Container(
                        width: ticketHistoryData['before'][index]['is_gift'] != 1 ? (MediaQuery.of(context).size.width - 80.0) / 3 : (MediaQuery.of(context).size.width - 80.0) / 2,
                        height: 40.0.w,
                        decoration: BoxDecoration(
                          color: ColorConfig().white(),
                          border: Border.all(
                            width: 1.0,
                            color: ColorConfig().gray2(),
                          ),
                          borderRadius: BorderRadius.circular(4.0.r),
                        ),
                        child: Center(
                          child: CustomTextBuilder(
                            text: TextConstant.doCancel,
                            fontColor: ColorConfig().gray5(),
                            fontSize: 13.0.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ) : Container(),
                    // 선물하기 버튼
                    ticketHistoryData['before'][index]['is_gift'] != 1 && ticketHistoryData['before'][index]['is_auction'] != 2 ? InkWell(
                      onTap: () async {
                        SendBeforeGiftTicketDetailAPI().giftTicket(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), ticketGroup: ticketHistoryData['before'][index]['ticket_group']).then((giftTicket) {
                          giftTicket.result['data']['ticket_group'] = ticketHistoryData['before'][index]['ticket_group'];

                          sendGiftBottomSheet(data: giftTicket.result['data']);
                        });
                      },
                      child: Container(
                        width: (MediaQuery.of(context).size.width - 80.0) / 3,
                        height: 40.0.w,
                        decoration: BoxDecoration(
                          color: ColorConfig().white(),
                          border: Border.all(
                            width: 1.0,
                            color: ColorConfig().gray2(),
                          ),
                          borderRadius: BorderRadius.circular(4.0.r),
                        ),
                        child: Center(
                          child: CustomTextBuilder(
                            text: TextConstant.doGift,
                            fontColor: ColorConfig().gray5(),
                            fontSize: 13.0.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ) : Container(),
                    // 티켓보기 버튼
                    ticketHistoryData['before'][index]['is_auction'] != 2 ? InkWell(
                      onTap: () async {
                        TicketHistoryDetailAPI().detail(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), ticketGroupNumber: ticketHistoryData['before'][index]['ticket_group'].toString()).then((detailData) {
                          detailData.result['data']['ticket_detail'] = ticketHistoryData['before'][index]['ticket_detail'];

                          ticketViewBottomSheet(detailData.result['data']);
                        });
                      },
                      child: Container(
                        width: ticketHistoryData['before'][index]['is_gift'] != 1 ? (MediaQuery.of(context).size.width - 80.0) / 3 : (MediaQuery.of(context).size.width - 80.0) / 2,
                        height: 40.0.w,
                        decoration: BoxDecoration(
                          color: ColorConfig().white(),
                          border: Border.all(
                            width: 1.0,
                            color: ColorConfig().gray2(),
                          ),
                          borderRadius: BorderRadius.circular(4.0.r),
                        ),
                        child: Center(
                          child: CustomTextBuilder(
                            text: TextConstant.viewTicket,
                            fontColor: ColorConfig().gray5(),
                            fontSize: 13.0.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ) : Container(),
                    // 티켓발급 예정 버튼 영역
                    ticketHistoryData['before'][index]['is_auction'] == 2 ? Container(
                      width: (MediaQuery.of(context).size.width - 80.0),
                      height: 40.0.w,
                      decoration: BoxDecoration(
                        color: ColorConfig().gray2(),
                        border: Border.all(
                          width: 1.0,
                          color: ColorConfig().gray2(),
                        ),
                        borderRadius: BorderRadius.circular(4.0.r),
                      ),
                      child: Center(
                        child: CustomTextBuilder(
                          text: TextConstant.ticketDerivateSpace,
                          fontColor: ColorConfig().gray3(),
                          fontSize: 13.0.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ) : Container(),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // 관람 완료 티켓 리스트 위젯
  Widget viewFinishTicketListWidget() {
    return Column(
      children: List.generate(ticketHistoryData['watched'].length, (index) {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80.0.w,
                      height: 114.0.w,
                      margin: const EdgeInsets.only(right: 16.0),
                      decoration: BoxDecoration(
                        color: ticketHistoryData['watched'][index]['image'] == null ? ColorConfig().gray2() : null,
                        borderRadius: BorderRadius.circular(4.0.r),
                        image: ticketHistoryData['watched'][index]['image'] != null ? DecorationImage(
                          image: NetworkImage(ticketHistoryData['watched'][index]['image']),
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        ) : null,
                      ),
                      child: ticketHistoryData['watched'][index]['image'] == null ? Center(
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
                          Container(
                            margin: const EdgeInsets.only(top: 2.0, bottom: 8.0),
                            child: CustomTextBuilder(
                              text: '${ticketHistoryData['watched'][index]['name']}',
                              fontColor: ColorConfig().dark(),
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              maxLines: 2,
                              textOverflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // 날짜 영역
                          CustomTextBuilder(
                            text: DateFormat('yyyy. M. d. · a h:m', 'ko').format(DateTime.parse(ticketHistoryData['watched'][index]['open_date']).toLocal()),
                            fontColor: ColorConfig().gray5(),
                            fontSize: 12.0.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          // 좌석 영역
                          Container(
                            margin: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 25.0.w,
                                  margin: const EdgeInsets.only(right: 8.0),
                                  child: CustomTextBuilder(
                                    text: TextConstant.seat,
                                    fontColor: ColorConfig().gray4(),
                                    fontSize: 12.0.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Expanded(
                                  child: CustomTextBuilder(
                                    text: '${ticketHistoryData['watched'][index]['seat']}',
                                    fontColor: ColorConfig().gray5(),
                                    fontSize: 12.0.sp,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // 버튼 영역
              Container(
                margin: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 티켓보기 버튼
                    InkWell(
                      onTap: () async {
                        ticketViewBottomSheet(ticketHistoryData['watched'][index], watched: true);
                      },
                      child: Container(
                        // width: (MediaQuery.of(context).size.width - 80.0) / 3,
                        width: (MediaQuery.of(context).size.width - 72.0),
                        height: 40.0.w,
                        decoration: BoxDecoration(
                          color: ColorConfig().white(),
                          border: Border.all(
                            width: 1.0,
                            color: ColorConfig().gray2(),
                          ),
                          borderRadius: BorderRadius.circular(4.0.r),
                        ),
                        child: Center(
                          child: CustomTextBuilder(
                            text: TextConstant.viewTicket,
                            fontColor: ColorConfig().gray5(),
                            fontSize: 13.0.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    // // 리뷰쓰고 포인트받기 버튼
                    // Container(
                    //   width: (MediaQuery.of(context).size.width - 76.0) / 1.5,
                    //   height: 40.0.w,
                    //   decoration: BoxDecoration(
                    //     color: ColorConfig().white(),
                    //     border: Border.all(
                    //       width: 1.0,
                    //       color: ColorConfig().gray2(),
                    //     ),
                    //     borderRadius: BorderRadius.circular(4.0.r),
                    //   ),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     children: [
                    //       CustomTextBuilder(
                    //         text: TextConstant.writeAReview,
                    //         fontColor: ColorConfig().gray5(),
                    //         fontSize: 13.0.sp,
                    //         fontWeight: FontWeight.w700,
                    //       ),
                    //       CustomTextBuilder(
                    //         text: ' 50',
                    //         fontColor: ColorConfig().gray5(),
                    //         fontSize: 13.0.sp,
                    //         fontWeight: FontWeight.w700,
                    //       ),
                    //       SVGStringBuilder(
                    //         image: 'assets/icon/money_point.svg',
                    //         width: 14.0.w,
                    //         height: 14.0.w,
                    //       ),
                    //       CustomTextBuilder(
                    //         text: ' ${TextConstant.send}',
                    //         fontColor: ColorConfig().gray5(),
                    //         fontSize: 13.0.sp,
                    //         fontWeight: FontWeight.w700,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // 경매현환 리스트 위젯
  Widget auctionStateListWidget() {
    return auctionHistoryData.isNotEmpty ? Column(
      children: List.generate(auctionHistoryData.length, (index) {
        if (auctionHistoryData[index]['status'] != -1) {
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80.0.w,
                        height: 114.0.w,
                        margin: const EdgeInsets.only(right: 16.0),
                        decoration: BoxDecoration(
                          color: ColorConfig().gray2(),
                          borderRadius: BorderRadius.circular(4.0.r),
                          image: auctionHistoryData[index]['image'] != null
                            ? DecorationImage(
                              image: NetworkImage(auctionHistoryData[index]['image']),
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            ) : null,
                        ),
                        child: auctionHistoryData[index]['image'] == null ? Center(
                          child: SVGBuilder(
                            image: 'assets/icon/album.svg',
                            width: 22.0.w,
                            height: 22.0.w,
                            color: ColorConfig().white(),
                          ),
                        ) : Container(),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 경매성공 label
                            Container(
                              margin: const EdgeInsets.only(top: 2.0),
                              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: auctionHistoryData[index]['status'] == 2
                                  ? ColorConfig().success()
                                  : auctionHistoryData[index]['status'] == 1
                                    ? ColorConfig().gray3()
                                    : auctionHistoryData[index]['status'] == 0
                                      ? ColorConfig().accent()
                                      : null,
                                borderRadius: BorderRadius.circular(2.0.r),
                              ),
                              child: CustomTextBuilder(
                                text: auctionHistoryData[index]['status'] == 2
                                  ? TextConstant.auctionInSuccess
                                  : auctionHistoryData[index]['status'] == 1
                                    ? TextConstant.auctionInProgress
                                      : auctionHistoryData[index]['status'] == 0
                                        ? TextConstant.auctionInFail
                                        : '',
                                fontColor: ColorConfig().white(),
                                fontSize: 12.0.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            // 공연 제목 영역
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: CustomTextBuilder(
                                text: '${auctionHistoryData[index]['name']}',
                                fontColor: ColorConfig().dark(),
                                fontSize: 14.0.sp,
                                fontWeight: FontWeight.w700,
                                maxLines: 1,
                                textOverflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // 날짜 영역
                            Container(
                              margin: const EdgeInsets.only(bottom: 4.0),
                              child: Text.rich(
                                TextSpan(
                                  children: <TextSpan> [
                                    TextSpan(
                                      text: DateFormat('yyyy. M. d.').format(DateTime.parse(auctionHistoryData[index]['open_date'])),
                                      style: TextStyle(
                                        color: ColorConfig().gray5(),
                                        fontSize: 12.0.sp,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' | ',
                                      style: TextStyle(
                                        color: ColorConfig().gray2(),
                                        fontSize: 12.0.sp,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    TextSpan(
                                      text: DateFormat('a H시 m분', 'ko').format(DateTime.parse(auctionHistoryData[index]['open_date']).toLocal()),
                                      style: TextStyle(
                                        color: ColorConfig().gray5(),
                                        fontSize: 12.0.sp,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // 좌석 영역
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 25.0.w,
                                  margin: const EdgeInsets.only(right: 8.0),
                                  child: CustomTextBuilder(
                                    text: TextConstant.seat,
                                    fontColor: ColorConfig().gray4(),
                                    fontSize: 12.0.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Expanded(
                                  child: CustomTextBuilder(
                                    text: '${auctionHistoryData[index]['seat_name']}',
                                    fontColor: ColorConfig().dark(),
                                    fontSize: 12.0.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            // 나의 경매가 영역
                            Container(
                              margin: const EdgeInsets.only(top: 16.0, bottom: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 60.0.w,
                                    margin: const EdgeInsets.only(right: 12.0),
                                    child: CustomTextBuilder(
                                      text: TextConstant.myAuctionPrice,
                                      fontColor: ColorConfig().gray4(),
                                      fontSize: 12.0.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Expanded(
                                    child: CustomTextBuilder(
                                      text: '${SetIntl().numberFormat(auctionHistoryData[index]['price'])}',
                                      fontColor: ColorConfig().dark(),
                                      fontSize: 12.0.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 경매 종료 영역
                            auctionHistoryData[index]['status'] == 1 ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 60.0.w,
                                  margin: const EdgeInsets.only(right: 12.0),
                                  child: CustomTextBuilder(
                                    text: TextConstant.auctionFinish,
                                    fontColor: ColorConfig().gray4(),
                                    fontSize: 12.0.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Expanded(
                                  child: CustomTextBuilder(
                                    text: DateCalculatorWrapper().endTimeCalculator(auctionHistoryData[index]['end_date']),
                                    fontColor: ColorConfig().dark(),
                                    fontSize: 12.0.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ) : Container(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // 경매 참여 인원 영역
                auctionHistoryData[index]['status'] == 1 ? InkWell(
                  onTap: () async {
                    dynamic localSeatData = auctionHistoryData[index];
                    localSeatData['seat_index'] = auctionHistoryData[index]['show_content_ticket_seat_index'];

                    AuctionBettingAPI().bettingSeat(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), seatData: localSeatData).then((vvalue) {
                      PopupBuilder(
                        title: '',
                        content: '',
                        onTitleWidget: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(bottom: 4.0),
                              child: Text.rich(
                                TextSpan(
                                  children: <TextSpan> [
                                    TextSpan(
                                      text: '해당 좌석 경매에 참여한 회원',
                                      style: TextStyle(
                                        color: ColorConfig().dark(),
                                        fontSize: 16.0.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' ${vvalue.result['data']['list'].length}',
                                      style: TextStyle(
                                        color: ColorConfig().primary(),
                                        fontSize: 16.0.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 12.0),
                              child: CustomTextBuilder(
                                text: '입찰가 높은순',
                                fontColor: ColorConfig().gray5(),
                                fontSize: 12.0.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        onContentWidget: SingleChildScrollView(
                          child: Column(
                            children: List.generate(vvalue.result['data']['list'].length, (joinedIndex) {
                              return Container(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36.0.w,
                                      height: 36.0.w,
                                      margin: const EdgeInsets.only(right: 8.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18.0.r),
                                        image: vvalue.result['data']['list'][joinedIndex]['image'] != null
                                          ? DecorationImage(
                                              image: NetworkImage(vvalue.result['data']['list'][joinedIndex]['image']),
                                              fit: BoxFit.cover,
                                              filterQuality: FilterQuality.high
                                            )
                                          : const DecorationImage(
                                              image: AssetImage('assets/img/profile_default.png'),
                                              fit: BoxFit.cover,
                                              filterQuality: FilterQuality.high,
                                            ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(right: 2.0),
                                      child: Image(
                                        image: vvalue.result['data']['list'][joinedIndex]['rank'] == 7
                                          ? const AssetImage('assets/img/rank-m.png')
                                          : vvalue.result['data']['list'][joinedIndex]['rank'] == 6
                                            ? const AssetImage('assets/img/rank-d.png')
                                            : vvalue.result['data']['list'][joinedIndex]['rank'] == 5
                                              ? const AssetImage('assets/img/rank-pl.png')
                                              : vvalue.result['data']['list'][joinedIndex]['rank'] == 4
                                                ? const AssetImage('assets/img/rank-r.png')
                                                : vvalue.result['data']['list'][joinedIndex]['rank'] == 3
                                                  ? const AssetImage('assets/img/rank-g.png')
                                                  : vvalue.result['data']['list'][joinedIndex]['rank'] == 2
                                                    ? const AssetImage('assets/img/rank-s.png')
                                                    : const AssetImage('assets/img/rank-w.png'),
                                        filterQuality: FilterQuality.high,
                                        width: 16.0.w,
                                        height: 16.0.w,
                                      ),
                                    ),
                                    CustomTextBuilder(
                                      text: '${vvalue.result['data']['list'][joinedIndex]['nick']}',
                                      fontColor: ColorConfig().dark(),
                                      fontSize: 12.0.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                        actions: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              decoration: BoxDecoration(
                                color: ColorConfig().dark(),
                                borderRadius: BorderRadius.circular(4.0.r),
                              ),
                              child: Center(
                                child: CustomTextBuilder(
                                  text: TextConstant.ok,
                                  fontColor: ColorConfig().white(),
                                  fontSize: 14.0.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ).ig-publicDialog(context);
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 16.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: ColorConfig().primary(),
                      borderRadius: BorderRadius.circular(100.0.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 4.0),
                              child: SVGBuilder(
                                image: 'assets/icon/cast.svg',
                                width: 16.0.w,
                                height: 16.0.w,
                                color: ColorConfig().white(),
                              ),
                            ),
                            CustomTextBuilder(
                              text: '${auctionHistoryData[index]['participant_count']}명 경매중',
                              fontColor: ColorConfig().white(),
                              fontSize: 12.0.sp,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ],
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 12.0, right: 8.0),
                                child: CustomTextBuilder(
                                  text: '내 입찰가 순위를 확인하세요!',
                                  fontColor: ColorConfig().white(),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                  maxLines: 1,
                                  textOverflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                child: SVGBuilder(
                                  image: 'assets/icon/arrow_right_bold.svg',
                                  width: 16.0.w,
                                  height: 16.0.w,
                                  color: ColorConfig().white(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ) : Container(),
                // 버튼 영역
                Container(
                  margin: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 경매 취소하기 버튼
                      auctionHistoryData[index]['status'] == 1 ? InkWell(
                        onTap: () {
                          PopupBuilder(
                            title: TextConstant.ticketing,
                            content: TextConstant.howDoTicketing,
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
                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                                      AuctionCancelAPI().auctionCancel(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), auctionIndex: auctionHistoryData[index]['auction_index']).then((cancel) {
                                        setState(() {
                                          Navigator.pop(context);
                                          auctionHistoryData.removeAt(index);
                                        });
                                      });
                                    },
                                    splashColor: ColorConfig.transparent,
                                    child: Container(
                                      width: (MediaQuery.of(context).size.width - 120.0.w) / 2,
                                      padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                        },
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 76.0) / 2,
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          margin: const EdgeInsets.only(right: 4.0),
                          decoration: BoxDecoration(
                            color: ColorConfig().white(),
                            border: Border.all(
                              width: 1.0,
                              color: ColorConfig().gray2(),
                            ),
                            borderRadius: BorderRadius.circular(4.0.r),
                          ),
                          child: Center(
                            child: CustomTextBuilder(
                              text: TextConstant.auctionCancel,
                              fontColor: ColorConfig().gray5(),
                              fontSize: 13.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ) : Container(),
                      // 경매가 올리기 버튼
                      auctionHistoryData[index]['status'] == 1 ? InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, 'auctionPriceChange', arguments: {
                            'show_index': auctionHistoryData[index]['show_index'],
                            'show_content_index': auctionHistoryData[index]['show_content_index'],
                            'show_content_ticket_index': auctionHistoryData[index]['show_content_ticket_index'],
                            'show_content_ticket_seat_index': auctionHistoryData[index]['show_content_ticket_seat_index'],
                            'ticket_index': auctionHistoryData[index]['ticket_index'],
                            'price': auctionHistoryData[index]['price'],
                            'seat_name': auctionHistoryData[index]['seat_name'],
                            'participant_count': auctionHistoryData[index]['participant_count'],
                            'floor': auctionHistoryData[index]['floor'],
                            'x': auctionHistoryData[index]['x'],
                            'y': auctionHistoryData[index]['y'],
                          }).then((getData) async {
                            if (getData != null) {
                              AuctionHistoryAPI().auctionHistory(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
                                setState(() {
                                  auctionHistoryData = value.result['data'];
                                });
                              });
                            }
                          });
                        },
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 76.0) / 2,
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          decoration: BoxDecoration(
                            color: ColorConfig().accent(),
                            borderRadius: BorderRadius.circular(4.0.r),
                          ),
                          child: Center(
                            child: CustomTextBuilder(
                              text: TextConstant.raiseAuctionPrice1,
                              fontColor: ColorConfig().white(),
                              fontSize: 13.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ) : Container(),
                      // ig-public머니 반환영수증 버튼
                      auctionHistoryData[index]['status'] == 0 ? InkWell(
                        onTap: () {
                          
                        },
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 76.0),
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          decoration: BoxDecoration(
                            color: ColorConfig().dark(),
                            borderRadius: BorderRadius.circular(4.0.r),
                          ),
                          child: Center(
                            child: CustomTextBuilder(
                              text: TextConstant.viewig-publicmoneyReturnReceipt,
                              fontColor: ColorConfig().white(),
                              fontSize: 13.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ) : Container(),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container();
        }

        // return Container(
        //   padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
        //   margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
        //   decoration: BoxDecoration(
        //     color: ColorConfig().white(),
        //     borderRadius: BorderRadius.circular(4.0.r),
        //   ),
        //   child: Column(
        //     children: [
        //       Padding(
        //         padding: const EdgeInsets.symmetric(vertical: 8.0),
        //         child: Row(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: [
        //             Container(
        //               width: 80.0.w,
        //               height: 114.0.w,
        //               margin: const EdgeInsets.only(right: 16.0),
        //               decoration: BoxDecoration(
        //                 borderRadius: BorderRadius.circular(4.0.r),
        //                 image: const DecorationImage(
        //                   image: AssetImage('assets/img/d_main_bg_poster.jpeg'),
        //                   fit: BoxFit.cover,
        //                   filterQuality: FilterQuality.high,
        //                 ),
        //               ),
        //             ),
        //             Expanded(
        //               child: Column(
        //                 crossAxisAlignment: CrossAxisAlignment.start,
        //                 children: [
        //                   // 경매 상태 label
        //                   Container(
        //                     margin: const EdgeInsets.only(top: 2.0),
        //                     padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.5),
        //                     decoration: BoxDecoration(
        //                       color: index == 1 ? ColorConfig().success() : ColorConfig().accent(),
        //                       borderRadius: BorderRadius.circular(2.0.r),
        //                     ),
        //                     child: CustomTextBuilder(
        //                       text: index == 1 ? '경매성공' : '경매실패',
        //                       fontColor: ColorConfig().white(),
        //                       fontSize: 12.0.sp,
        //                       fontWeight: FontWeight.w700,
        //                     ),
        //                   ),
        //                   // 공연 제목 영역
        //                   Container(
        //                     margin: const EdgeInsets.symmetric(vertical: 8.0),
        //                     child: CustomTextBuilder(
        //                       text: '공연명공연명공연명공연명공연명공연명공연명공연공연공연명공연명공연명공연명공연명공연명공연명공연공연..',
        //                       fontColor: ColorConfig().dark(),
        //                       fontSize: 14.0.sp,
        //                       fontWeight: FontWeight.w800,
        //                       height: 1.1,
        //                       maxLines: 2,
        //                       textOverflow: TextOverflow.ellipsis,
        //                     ),
        //                   ),
        //                   // 날짜 영역
        //                   Text.rich(
        //                     TextSpan(
        //                       children: <TextSpan> [
        //                         TextSpan(
        //                           text: '2023. 2. 24',
        //                           style: TextStyle(
        //                             color: ColorConfig().gray5(),
        //                             fontSize: 12.0.sp,
        //                             fontWeight: FontWeight.w700,
        //                             height: 1.0,
        //                           ),
        //                         ),
        //                         TextSpan(
        //                           text: '  |  ',
        //                           style: TextStyle(
        //                             color: ColorConfig().gray2(),
        //                             fontSize: 12.0.sp,
        //                             fontWeight: FontWeight.w700,
        //                           ),
        //                         ),
        //                         TextSpan(
        //                           text: '오후 12시',
        //                           style: TextStyle(
        //                             color: ColorConfig().gray5(),
        //                             fontSize: 12.0.sp,
        //                             fontWeight: FontWeight.w700,
        //                             height: 1.0,
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                   ),
        //                   // 좌석 영역
        //                   Row(
        //                     crossAxisAlignment: CrossAxisAlignment.start,
        //                     children: [
        //                       Container(
        //                         width: 25.0.w,
        //                         margin: const EdgeInsets.only(right: 8.0),
        //                         child: CustomTextBuilder(
        //                           text: TextConstant.seat,
        //                           fontColor: ColorConfig().gray4(),
        //                           fontSize: 12.0.sp,
        //                           fontWeight: FontWeight.w700,
        //                         ),
        //                       ),
        //                       Expanded(
        //                         child: CustomTextBuilder(
        //                           text: 'R6',
        //                           fontColor: ColorConfig().gray5(),
        //                           fontSize: 12.0.sp,
        //                           fontWeight: FontWeight.w700,
        //                         ),
        //                       ),
        //                     ],
        //                   ),
        //                   // 나의 경매가 영역
        //                   Container(
        //                     margin: const EdgeInsets.only(top: 16.0),
        //                     child: Row(
        //                       crossAxisAlignment: CrossAxisAlignment.start,
        //                       children: [
        //                         Container(
        //                           width: 60.0.w,
        //                           margin: const EdgeInsets.only(right: 12.0),
        //                           child: CustomTextBuilder(
        //                             text: TextConstant.myAuctionPrice,
        //                             fontColor: ColorConfig().gray4(),
        //                             fontSize: 12.0.sp,
        //                             fontWeight: FontWeight.w700,
        //                           ),
        //                         ),
        //                         Expanded(
        //                           child: CustomTextBuilder(
        //                             text: '30,000',
        //                             fontColor: ColorConfig().dark(),
        //                             fontSize: 12.0.sp,
        //                             fontWeight: FontWeight.w700,
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ],
        //   ),
        // );
      }),
    ) : SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 1.5,
      child: Column(
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
            text: '아직 참여한 경매 현황이 없습니다.\n티켓팅 메뉴에서 보고싶은 공연 경매에 참여해보세요.',
            fontColor: ColorConfig().gray4(),
            fontSize: 14.0.sp,
            fontWeight: FontWeight.w400,
            height: 1.2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Future sendGiftBottomSheet({dynamic data}) {
    GiftMethodType? giftType = GiftMethodType.sms;
    List<bool> giftCheckedList = [];
    List<Map<String, dynamic>> sendGiftDatas = [];
    List<String> dropdownList = ['나에게', '받는분께'];
    String selectedDropdown = '나에게';

    for (int i=0; i<data['tickets'].length; i++) {
      giftCheckedList.add(false);
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4.0.r),
          topRight: Radius.circular(4.0.r),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, state) {
            return GestureDetector(
              onTap: () {
                if (giftReceiverFocusNode.hasFocus) {
                  giftReceiverFocusNode.unfocus();
                }

                if (giftMessageFocusNode.hasFocus) {
                  giftMessageFocusNode.unfocus();
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 상단 영역
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 17.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomTextBuilder(
                          text: TextConstant.doGift,
                          fontColor: ColorConfig().dark(),
                          fontSize: 16.0.sp,
                          fontWeight: FontWeight.w800,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: SVGBuilder(
                            image: 'assets/icon/close_normal.svg',
                            width: 24.0.w,
                            height: 24.0.w,
                            color: ColorConfig().gray3(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 콘텐츠 영역
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height / 1.3,
                    ),
                    decoration: BoxDecoration(
                      color: ColorConfig().white(),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4.0.r),
                        topRight: Radius.circular(4.0.r),
                      ),
                    ),
                    child: SingleChildScrollView(
                      controller: giftBottomSheetScroller,
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 티켓정보 영역
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: 80.0.w,
                                        height: 114.0.w,
                                        decoration: BoxDecoration(
                                          color: data['show_info']['image'] == null ? ColorConfig().gray2() : null,
                                          borderRadius: BorderRadius.circular(4.0.r),
                                          image: data['show_info']['image'] != null ? DecorationImage(
                                            image: NetworkImage(data['show_info']['image']),
                                            fit: BoxFit.cover,
                                            filterQuality: FilterQuality.high,
                                          ) : null,
                                        ),
                                        child: data['show_info']['image'] == null ? Center(
                                          child: SVGBuilder(
                                            image: 'assets/icon/album.svg',
                                            width: 24.0.w,
                                            height: 24.0.w,
                                            color: ColorConfig().white(),
                                          ),
                                        ) : Container(),
                                      ),
                                      // Positioned(
                                      //   top: 4.0,
                                      //   left: 4.0,
                                      //   child: Container(
                                      //     padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.5),
                                      //     decoration: BoxDecoration(
                                      //       color: ColorConfig().accent(),
                                      //       borderRadius: BorderRadius.circular(2.0.r),
                                      //     ),
                                      //     child: Center(
                                      //       child: CustomTextBuilder(
                                      //         text: 'D-3',
                                      //         fontColor: ColorConfig().white(),
                                      //         fontSize: 12.0.sp,
                                      //         fontWeight: FontWeight.w700,
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 16.0),
                                      padding: const EdgeInsets.only(top: 2.0, bottom: 7.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // 경매 여부
                                          // IntrinsicWidth(
                                          //   child: Container(
                                          //     padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.5),
                                          //     decoration: BoxDecoration(
                                          //       color: ColorConfig().success(),
                                          //       borderRadius: BorderRadius.circular(2.0.r),
                                          //     ),
                                          //     child: Center(
                                          //       child: CustomTextBuilder(
                                          //         text: TextConstant.auctionFinish,
                                          //         fontColor: ColorConfig().white(),
                                          //         fontSize: 12.0.sp,
                                          //       ),
                                          //     ),
                                          //   ),
                                          // ),
                                          // 타이틀 영역
                                          Container(
                                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                                            child: CustomTextBuilder(
                                              text: '${data['show_info']['name']}',
                                              fontColor: ColorConfig().dark(),
                                              fontSize: 14.0.sp,
                                              fontWeight: FontWeight.w800,
                                              height: 1.2,
                                              maxLines: 2,
                                              textOverflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          // 날짜 영역
                                          Container(
                                            margin: const EdgeInsets.only(bottom: 2.0),
                                            child: Text.rich(
                                              TextSpan(
                                                children: <TextSpan> [
                                                  TextSpan(
                                                    text: DateFormat('yyyy. MM. dd.').format(DateTime.parse(data['show_info']['open_date']).toLocal()),
                                                    style: TextStyle(
                                                      color: ColorConfig().gray5(),
                                                      fontSize: 12.0.sp,
                                                      fontWeight: FontWeight.w700,
                                                      height: 1.0,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: '  |  ',
                                                    style: TextStyle(
                                                      color: ColorConfig().gray2(),
                                                      fontSize: 12.0.sp,
                                                      fontWeight: FontWeight.w700,
                                                      height: 1.0,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: DateFormat('aa HH시 mm분', 'ko').format(DateTime.parse(data['show_info']['open_date']).toLocal()),
                                                    style: TextStyle(
                                                      color: ColorConfig().gray5(),
                                                      fontSize: 12.0.sp,
                                                      fontWeight: FontWeight.w700,
                                                      height: 1.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // 좌석 영역
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 25.0.w,
                                                margin: const EdgeInsets.only(right: 8.0),
                                                child: CustomTextBuilder(
                                                  text: TextConstant.seat,
                                                  fontColor: ColorConfig().gray4(),
                                                  fontSize: 12.0.sp,
                                                  fontWeight: FontWeight.w700,
                                                  height: 1.2,
                                                ),
                                              ),
                                              Column(
                                                children: List.generate(data['tickets'].length, (seats) {
                                                  return CustomTextBuilder(
                                                    text: '${data['tickets'][seats]['name']}',
                                                    fontColor: ColorConfig().gray5(),
                                                    fontSize: 12.0.sp,
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.2,
                                                  );
                                                }),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // divider 영역
                          Container(
                            height: 8.0,
                            color: ColorConfig().gray1(),
                          ),
                          // 선물할 좌석 선택 영역
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              children: [
                                // 선물할 좌석 선택 타이틀 영역
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(right: 4.0),
                                        child: CustomTextBuilder(
                                          text: TextConstant.selectGiftSeat,
                                          fontColor: ColorConfig().dark(),
                                          fontSize: 14.0.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      CustomTextBuilder(
                                        text: '${giftCheckedList.where((element) => element == true).toList().length}장',
                                        fontColor: ColorConfig().primary(),
                                        fontSize: 14.0.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ],
                                  ),
                                ),
                                // 선물할 좌석 영역
                                Column(
                                  children: List.generate(data['tickets'].length, (index) {
                                    return InkWell(
                                      onTap: () async {
                                        state(() {
                                          if (giftCheckedList[index] == false) {
                                            giftCheckedList[index] = true;
                                            sendGiftDatas.add(data['tickets'][index]);
                                          } else {
                                            giftCheckedList[index] = false;
                                            sendGiftDatas.removeAt(index);
                                          }
                                        });
                                      },
                                      child: Container(
                                        width: MediaQuery.of(context).size.width,
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                        child: Row(
                                          children: [
                                            // 체크박스
                                            SizedBox(
                                              width: 24.0.w,
                                              height: 24.0.w,
                                              child: Checkbox(
                                                activeColor: ColorConfig().primary(),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(100.0.r),
                                                ),
                                                value: giftCheckedList[index],
                                                onChanged: (checked) {
                                                  giftCheckedList[index] = checked!;
                                                },
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(left: 16.0),
                                              child: CustomTextBuilder(
                                                text: '${data['tickets'][index]['seat_name']}석 ${data['tickets'][index]['name']}',
                                                fontColor: ColorConfig().dark(),
                                                fontSize: 12.0.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                // divider 영역
                                Container(
                                  height: 8.0,
                                  color: ColorConfig().gray1(),
                                ),
                                // 선물방법 영역
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Column(
                                    children: [
                                      // 선물방법 타이틀 영역
                                      Container(
                                        width: MediaQuery.of(context).size.width,
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                                        child: CustomTextBuilder(
                                          text: TextConstant.chooseGiftMethod,
                                          fontColor: ColorConfig().dark(),
                                          fontSize: 14.0.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      // 선물방법 선택 영역
                                      Row(
                                        children: List.generate(2, (types) {
                                          return InkWell(
                                            onTap: () {
                                              state(() {
                                                if (types == 0) {
                                                  giftType = GiftMethodType.sms;
                                                } else {
                                                  giftType = GiftMethodType.kakaoTalk;
                                                }
                                              });
                                            },
                                            child: Container(
                                              width: MediaQuery.of(context).size.width / 2,
                                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                              child: Row(
                                                children: [
                                                  // 체크박스 영역
                                                  SizedBox(
                                                    width: 24.0.w,
                                                    height: 24.0.w,
                                                    child: Radio(
                                                      activeColor: ColorConfig().primary(),
                                                      value: types == 0 ? GiftMethodType.sms : GiftMethodType.kakaoTalk,
                                                      groupValue: giftType,
                                                      onChanged: (GiftMethodType? mtype) {
                                                        state(() {
                                                          giftType = mtype;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  // 카카오톡 선물 영역
                                                  Container(
                                                    margin: const EdgeInsets.only(left: 16.0),
                                                    child: CustomTextBuilder(
                                                      text: types == 0 ? TextConstant.giftMethodFromSMS : TextConstant.giftMethodFromKakaoTalk,
                                                      fontColor: ColorConfig().dark(),
                                                      fontSize: 12.0.sp,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                      // divider 영역
                                      Container(
                                        height: 1.0,
                                        color: ColorConfig().gray1(),
                                      ),
                                      // 받는사람, 전하고싶은 메시지 영역
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Column(
                                          children: [
                                            // 받는사람 영역
                                            giftType == GiftMethodType.sms ? Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                                              child: TextFormField(
                                                controller: giftReceiverTextController,
                                                focusNode: giftReceiverFocusNode,
                                                scrollPadding: EdgeInsets.only(bottom: WidgetsBinding.instance.window.viewInsets.bottom),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                                                ],
                                                decoration: InputDecoration(
                                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
                                                  hintText: TextConstant.giftReceiverPhoneNumber,
                                                  hintStyle: TextStyle(
                                                    color: ColorConfig().gray3(),
                                                    fontSize: 14.0.sp,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  focusedBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      width: 1.0,
                                                      color: ColorConfig().primary(),
                                                    ),
                                                  ),
                                                  enabledBorder: UnderlineInputBorder(
                                                    borderSide: BorderSide(
                                                      width: 1.0,
                                                      color: ColorConfig().gray3(),
                                                    ),
                                                  ),
                                                  suffixIcon: InkWell(
                                                    onTap: () async {
                                                      var status = await Permission.contacts.status;
                                                      if(status.isGranted){
                                                        await ContactsService.openDeviceContactPicker().then((contactData) {
                                                          state(() {
                                                            giftReceiverTextController.text = contactData?.phones?.first.value?.replaceAll('-', '') ?? '';
                                                          });
                                                        });
                                                      } else if (status.isDenied){
                                                        await Permission.contacts.request();
                                                      } else {
                                                        openAppSettings();
                                                      }
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.all(10.0),
                                                      margin: const EdgeInsets.only(bottom: 10.0),
                                                      decoration: BoxDecoration(
                                                        color: ColorConfig().white(),
                                                        border: Border.all(
                                                          width: 1.0,
                                                          color: ColorConfig().gray2(),
                                                        ),
                                                      ),
                                                      child: CustomTextBuilder(
                                                        text: TextConstant.importContact,
                                                        fontColor: ColorConfig().gray5(),
                                                        fontSize: 12.0.sp,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                style: TextStyle(
                                                  color: ColorConfig().dark(),
                                                  fontSize: 14.0.sp,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                cursorColor: ColorConfig().primary(),
                                                keyboardType: TextInputType.number,
                                              ),
                                            ) : Container(),
                                            // 전하고싶은 메시지 작성 영역
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(4.0.r),
                                                ),
                                                child: TextFormField(
                                                  controller: giftMessageTextController,
                                                  focusNode: giftMessageFocusNode,
                                                  scrollPadding: EdgeInsets.only(bottom: WidgetsBinding.instance.window.viewInsets.bottom),
                                                  minLines: 1,
                                                  maxLines: 10,
                                                  maxLength: 200,
                                                  decoration: InputDecoration(
                                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.5),
                                                    filled: true,
                                                    fillColor: ColorConfig().gray1(),
                                                    counterText: '',
                                                    hintText: TextConstant.wantGiftSendMessage,
                                                    hintStyle: TextStyle(
                                                      color: ColorConfig().gray3(),
                                                      fontSize: 14.0.sp,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                    focusedBorder: const UnderlineInputBorder(
                                                      borderSide: BorderSide.none,
                                                    ),
                                                    enabledBorder: const UnderlineInputBorder(
                                                      borderSide: BorderSide.none,
                                                    ),
                                                  ),
                                                  style: TextStyle(
                                                    color: ColorConfig().dark(),
                                                    fontSize: 14.0.sp,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  cursorColor: ColorConfig().primary(),
                                                  keyboardType: TextInputType.multiline,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // divider 영역
                                      Container(
                                        height: 8.0,
                                        color: ColorConfig().gray1(),
                                      ),
                                      // 환불받을 사람 영역
                                      Container(
                                        width: MediaQuery.of(context).size.width,
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                        color: ColorConfig().white(),
                                        child: Row(
                                          children: [
                                            CustomTextBuilder(
                                              text: '예매 취소시',
                                              fontColor: ColorConfig().gray5(),
                                              fontSize: 12.0.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            data['is_use_coupon'] == false ? Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 8.0),
                                              padding: const EdgeInsets.fromLTRB(10.0, 8.0, 8.0, 8.0),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  width: 1.0,
                                                  color: ColorConfig().gray2(),
                                                ),
                                                borderRadius: BorderRadius.circular(4.0.r),
                                              ),
                                              child: DropdownButton(
                                                isDense: true,
                                                iconSize: 16.0.w,
                                                icon: SVGBuilder(
                                                  image: 'assets/icon/arrow_down_light.svg',
                                                  width: 16.0.w,
                                                  height: 16.0.w,
                                                  color: ColorConfig().gray5(),
                                                ),
                                                underline: Container(),
                                                value: selectedDropdown,
                                                items: dropdownList.map((item) {
                                                  return DropdownMenuItem(
                                                    value: item,
                                                    child: CustomTextBuilder(
                                                      text: item,
                                                      fontColor: ColorConfig().gray5(),
                                                      fontSize: 12.0.sp,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (itemValue) {
                                                  state(() {
                                                    selectedDropdown = itemValue!;
                                                  });
                                                },
                                              ),
                                            ) : Container(),
                                            CustomTextBuilder(
                                              text: '환불해주세요.',
                                              fontColor: ColorConfig().gray5(),
                                              fontSize: 12.0.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // divider 영역
                                      Container(
                                        height: 8.0,
                                        color: ColorConfig().gray1(),
                                      ),
                                      // 선물하기 버튼 영역
                                      InkWell(
                                        onTap: () async {
                                          SendBeforeGiftTicketAPI().giftSend(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), ticketGroup: data['ticket_group'], ticketPrintIndex: sendGiftDatas.where((element) => element['ticket_print_index'] != null).map((e) => e['ticket_print_index']).toList(), isRefund: selectedDropdown == '나에게' ? 0 : 1, message: giftMessageTextController.text).then((send) async {
                                            if (send.result['status'] == 1) {
                                              var shortLink = await DeepLinkBuilder().getShortLink('gift', send.result['data']['coupon_code']);

                                              if (giftType == GiftMethodType.kakaoTalk) {
                                                if (ig-publicBuildConfig.instance?.buildType == 'dev') {
                                                  KakaoSdk.init(
                                                    nativeAppKey: ig-publicKeys.kakaoDevNativeKey,
                                                    javaScriptAppKey: ig-publicKeys.kakaoDevJavaScriptKey,
                                                    loggingEnabled: false,
                                                  );
                                                } else {
                                                  KakaoSdk.init(
                                                    nativeAppKey: ig-publicKeys.kakaoProductNativeKey,
                                                    javaScriptAppKey: ig-publicKeys.kakaoProductJavaScriptKey,
                                                    loggingEnabled: true,
                                                  );
                                                }

                                                var kakaoSend = await ShareClient.instance.shareDefault(
                                                  template: FeedTemplate(
                                                    content: Content(
                                                      title: '${sendGiftDatas[0]['owner_user_name']}님이 공연 선물을 보냈습니다.',
                                                      description: '선물받기 누르고 앱에서 티켓을 확인하세요.',
                                                      imageUrl: Uri.parse(data['show_info']['image']),
                                                      link: Link(
                                                        // webUrl: Uri.parse(shortLink),
                                                        // mobileWebUrl: Uri.parse(shortLink),
                                                        androidExecutionParams: {
                                                          'params': shortLink,
                                                        },
                                                        iosExecutionParams: {
                                                          'params': shortLink,
                                                        },
                                                      ),
                                                    ),
                                                    buttons: [
                                                      Button(
                                                        title: '선물받기',
                                                        link: Link(
                                                          // webUrl: Uri.parse(shortLink),
                                                          // mobileWebUrl: Uri.parse(shortLink),
                                                          androidExecutionParams: {
                                                            'params': shortLink,
                                                          },
                                                          iosExecutionParams: {
                                                            'params': shortLink,
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                await ShareClient.instance.launchKakaoTalk(kakaoSend).then((_) {
                                                  Navigator.pop(context);
                                                });
                                              } else {
                                                await sendSMS(
                                                  message: '${sendGiftDatas[0]['owner_user_name']}님이 공연 선물을 보냈습니다.\n링크를 클릭해 티켓을 확인해보세요.\n$shortLink',
                                                  recipients: [giftReceiverTextController.text],
                                                  sendDirect: true
                                                ).catchError((onError) {
                                                  log(onError);
                                                }).then((_) {
                                                  Navigator.pop(context);
                                                });
                                              }
                                            }
                                          });
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(top: 8.0),
                                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                                            decoration: BoxDecoration(
                                              color: ColorConfig().primary(),
                                              borderRadius: BorderRadius.circular(4.0.r),
                                            ),
                                            child: Center(
                                              child: CustomTextBuilder(
                                                text: TextConstant.doGift,
                                                fontColor: ColorConfig().white(),
                                                fontSize: 14.0.sp,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      giftReceiverFocusNode.hasFocus || giftMessageFocusNode.hasFocus ? SizedBox(height: MediaQuery.of(context).viewInsets.bottom) : Container(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    ).then((_) {
      giftReceiverTextController.clear();
      giftMessageTextController.clear();
    });
  }

  Future ticketViewBottomSheet(dynamic data, {bool watched = false}) {
    List tmpSeats = [];
    if (watched == false) {
      for (int i=0; i<data['tickets'].length; i++) {
        tmpSeats.add(data['tickets'][i]['name']);
      }
    }

    // 관람완료 티켓
    if (watched == true) {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height / 1.2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(4.0.r),
            topRight: Radius.circular(4.0.r),
          ),
        ),
        builder: (context) {
          return Column(
            children: [
              ig-publicAppBar(
                elevation: 0.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(6.0.r),
                  ),
                ),
                center: false,
                leadingWidth: 0.0,
                title: ig-publicAppBarTitle(
                  title: '${data['name']} (관람완료)',
                ),
                actions: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: SVGBuilder(
                      image: 'assets/icon/close_normal.svg',
                      color: ColorConfig().gray3(),
                    ),
                  ),
                ],
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: (MediaQuery.of(context).size.height / 1.2) - const ig-publicAppBar().preferredSize.height,
                color: ColorConfig().white(),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      // 포스터 이미지 영역
                      SizedBox(
                        height: 341.0,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: data['image'] == null ? ColorConfig().gray2() : null,
                                image: data['image'] != null ? DecorationImage(
                                  image: NetworkImage(data['image']),
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                ) : null,
                              ),
                            ),
                            Container(
                              color: ColorConfig().overlay(),
                            ),
                            Center(
                              child: Container(
                                width: 200.0,
                                height: 285.0,
                                margin: const EdgeInsets.symmetric(vertical: 28.0),
                                decoration: BoxDecoration(
                                  color: data['image'] == null ? ColorConfig().gray2() : null,
                                  borderRadius: BorderRadius.circular(4.0.r),
                                  image: data['image'] != null ? DecorationImage(
                                    image: NetworkImage(data['image']),
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.high,
                                  ) : null,
                                ),
                                child: data['image'] == null ? Center(
                                  child: SVGBuilder(
                                    image: 'assets/icon/album.svg',
                                    width: 24.0.w,
                                    height: 24.0.w,
                                    color: ColorConfig().white(),
                                  ),
                                ) : Container(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 공백 영역
                      const SizedBox(height: 8.0),
                      ticketViewBottomSheetTextLayoutWidget(categoryText: TextConstant.showSchedule, categoryDataText: DateFormat('M. d. (E) a h:m', 'ko').format(DateTime.parse(data['open_date']).toLocal())),
                      ticketViewBottomSheetTextLayoutWidget(categoryText: TextConstant.location, categoryDataText: data['location']),
                      ticketViewBottomSheetTextLayoutWidget(categoryText: TextConstant.seat, categoryDataText: data['seat']),
                      ticketViewBottomSheetTextLayoutWidget(categoryText: TextConstant.amount, categoryDataText: '총 ${data['count']}매'),
                      // 공백 영역
                      const SizedBox(height: 44.0),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
    
    // 관람전 티켓
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height / 1.2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(4.0.r),
          topRight: Radius.circular(4.0.r),
        ),
      ),
      builder: (context) {
        return Column(
          children: [
            ig-publicAppBar(
              elevation: 0.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(6.0.r),
                ),
              ),
              center: false,
              leadingWidth: 0.0,
              title: ig-publicAppBarTitle(
                title: '${data['show']['name']}',
              ),
              actions: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: SVGBuilder(
                    image: 'assets/icon/close_normal.svg',
                    color: ColorConfig().gray3(),
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: (MediaQuery.of(context).size.height / 1.2) - const ig-publicAppBar().preferredSize.height,
              color: ColorConfig().white(),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    // 포스터 이미지 영역
                    SizedBox(
                      height: 341.0,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: data['show']['image'] == null ? ColorConfig().gray2() : null,
                              image: data['show']['image'] != null ? DecorationImage(
                                image: NetworkImage(data['show']['image']),
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                              ) : null,
                            ),
                          ),
                          Container(
                            color: ColorConfig().overlay(),
                          ),
                          Center(
                            child: Container(
                              width: 200.0,
                              height: 285.0,
                              margin: const EdgeInsets.symmetric(vertical: 28.0),
                              decoration: BoxDecoration(
                                color: data['show']['image'] == null ? ColorConfig().gray2() : null,
                                borderRadius: BorderRadius.circular(4.0.r),
                                image: data['show']['image'] != null ? DecorationImage(
                                  image: NetworkImage(data['show']['image']),
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                ) : null,
                              ),
                              child: data['show']['image'] == null ? Center(
                                child: SVGBuilder(
                                  image: 'assets/icon/album.svg',
                                  width: 24.0.w,
                                  height: 24.0.w,
                                  color: ColorConfig().white(),
                                ),
                              ) : Container(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 공백 영역
                    const SizedBox(height: 8.0),
                    ticketViewBottomSheetTextLayoutWidget(categoryText: TextConstant.ticketNumber, categoryDataText: '${data['ticket_detail'].first['ticket_number']}${data['ticket_detail'].length > 1 ? '~${data['ticket_detail'].last['ticket_number']}' : ''}${data['ticket_detail'].length > 1 ? '\n' : ' '}(총 ${data['ticket_detail'].length}장)', textColor: ColorConfig().dark()),
                    ticketViewBottomSheetTextLayoutWidget(categoryText: TextConstant.ticketBuyer, categoryDataText: '${data['tickets'].first['owner_user_name']}', textColor: ColorConfig().primary()),
                    ticketViewBottomSheetTextLayoutWidget(categoryText: TextConstant.ticketBuyDate, categoryDataText: DateFormat('yyyy. M. d. (E) a H:m', 'ko').format(DateTime.parse(data['tickets'].first['buy_dt']).toLocal())),
                    ticketViewBottomSheetTextLayoutWidget(categoryText: TextConstant.showSchedule, categoryDataText: DateFormat('yyyy. M. d. (E) a H:m', 'ko').format(DateTime.parse(data['show']['open_date']).toLocal())),
                    ticketViewBottomSheetTextLayoutWidget(categoryText: TextConstant.location, categoryDataText: data['show']['location']),
                    ticketViewBottomSheetTextLayoutWidget(categoryText: TextConstant.seat, categoryDataText: tmpSeats.toString().replaceAll('[', '').replaceAll(']', '')),
                    ticketViewBottomSheetTextLayoutWidget(categoryText: TextConstant.amount, categoryDataText: '총 ${data['tickets'].length}매'),
                    // 공백 영역
                    const SizedBox(height: 44.0),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  Widget ticketViewBottomSheetTextLayoutWidget({required String categoryText, required String categoryDataText, Color? textColor}) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 3,
            child: CustomTextBuilder(
              text: categoryText,
              fontColor: ColorConfig().dark(),
              fontSize: 14.0.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          Flexible(
            flex: 7,
            child: CustomTextBuilder(
              text: categoryDataText,
              fontColor: textColor ?? ColorConfig().gray5(),
              fontSize: 14.0.sp,
              fontWeight: textColor == null ? FontWeight.w400 : FontWeight.w800,
              height: 1.3,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}