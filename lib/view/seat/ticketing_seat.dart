import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ig-public_v3/util/toast.dart';

import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ig-public_v3/main.dart';
import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/api/coupon/available_coupon.dart';
import 'package:ig-public_v3/api/profile/my_money.dart';
import 'package:ig-public_v3/api/ticket/buying_ticket.dart';
import 'package:ig-public_v3/api/ticket/check_seat_list.dart';
import 'package:ig-public_v3/api/ticket/ticket_holding.dart';
import 'package:ig-public_v3/api/ticket/ticket_holding_cancel.dart';
import 'package:ig-public_v3/component/border/dashed_border.dart';
import 'package:ig-public_v3/component/date_calculator/date_calculator.dart';
import 'package:ig-public_v3/component/popup/popup.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/util/set_intl.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:ig-public_v3/widget/ticket_cliper.dart';

// ignore: must_be_immutable
class TicketingSeatScreen extends StatefulWidget {
  TicketingSeatScreen({
    super.key,
    this.seat,
    required this.showTicketIndex,
    required this.showContentIndex,
  });

  dynamic seat;
  int showTicketIndex;
  int showContentIndex;

  @override
  State<TicketingSeatScreen> createState() => _TicketingSeatScreenState();
}

class _TicketingSeatScreenState extends State<TicketingSeatScreen> with TickerProviderStateMixin {
  final TransformationController transformationController = TransformationController();
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  late TextEditingController purchaseTextController;
  late FocusNode purchaseFocusNode;
  late List catalogdata;
  Timer? holdingTimer;

  GlobalKey positionKey = GlobalKey();
  GlobalKey seatAllKey = GlobalKey();

  final Set<SeatMultiSelectRenderBox> trackTaped = <SeatMultiSelectRenderBox>{};

  List<bool> selectFloorList = [];
  List<String> selectSeatName = [];
  List<String> artistsName = [];
  List selectSeatsIndex = [];
  List selectSeats = [];
  List checkSeatListData = [];
  List holdSeatData = [];
  List selectedCouponList = [];
  List selectedCouponIndex = [];

  int pointersCount = 0;
  int holdingMinute = 3;
  int holdingSecond = 0;
  int ig-publicMoney = 0;
  int couponTotalPrice = 0;
  int showCouponTotalPrice = 0;
  int existingAmount = 0;

  double scalePadding = 40.0;
  // double currentScale = 0.7;
  // double previousScale = 0.7;

  bool isSwipeUp = false;
  bool holdingStatus = false;

  String selectSeatRank = TextConstant.all;

  @override
  void initState() {
    super.initState();

    // 좌석 scale 초기값 세팅
    transformationController.value.setEntry(0, 0, 0.6);
    transformationController.value.setEntry(1, 1, 0.6);
    transformationController.value.setEntry(2, 2, 0.6);

    Future.delayed(Duration.zero, () {
      setState(() {
        // transformationController.value.setEntry(0, 3, -((positionKey.currentContext?.findRenderObject() as RenderBox).size.width / 4));
        dynamic firstSeatPosition;
        firstSeatPosition = widget.seat['seat'][selectFloorList.indexOf(true)]['seats'].firstWhere((e) => e['status'] == 2, orElse: () => null);

        transformationController.value = Matrix4.identity()..translate(-(firstSeatPosition['x'] * (30.0.w * 0.6)), 0.0)..scale(0.6);
      });
    });

    loadData();
    initializeAPI();

    purchaseTextController = TextEditingController()..addListener(() {
      setState(() {});
    });
    purchaseFocusNode = FocusNode();
  }

  @override
  void dispose() {
    holdingTimer?.cancel();

    super.dispose();
    
    _verticalController.dispose();
    _horizontalController.dispose();
    transformationController.dispose();
    purchaseTextController.dispose();
    purchaseFocusNode.dispose();
  }

  Future<String> loadData() async {
    dynamic data = widget.seat['seat']; //await rootBundle.loadString("assets/img/seat-json.json");
    setState(() {
      catalogdata = data;

      for (int i=0; i<catalogdata.length; i++) {
        if (i == 0) {
          selectFloorList.add(true);
        } else {
          selectFloorList.add(false);
        }
      }

      for (int i=0; i<widget.seat['artists'].length; i++) {
        artistsName.add(widget.seat['artists'][i]['name']);
      }
    });
    return "success";
  }

  Future<void> initializeAPI() async {
    CheckSeatListAPI().checkList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), showContentTicketIndex: widget.showTicketIndex).then((value) {
      setState(() {
        checkSeatListData = value.result['data'];
      });
    });
    Myig-publicMoneyAPI().ig-publicMoney(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
      setState(() {
        ig-publicMoney = value.result['data'][0]['point'];
      });
    });
  }

  void holdingScheduler() {
    holdingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          holdingSecond--;

          if (holdingMinute == 0 && holdingSecond == 0) {
            PopupBuilder(
              title: TextConstant.overTicketingPurchaseTitle,
              content: TextConstant.overTicketingPurchaseDescription,
              barrierDismissible: false,
              actions: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      isSwipeUp = false;
                      purchaseTextController.text = '';
                      selectedCouponList.clear();
                      holdingTimer?.cancel();
                      holdingMinute = 3;
                      holdingSecond = 0;
                      holdSeatData.clear();
                    });
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
                        text: TextConstant.close,
                        fontColor: ColorConfig().white(),
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ).ig-publicDialog(context);
          }

          if (holdingSecond < 0) {
            holdingMinute--;
            holdingSecond = 59;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: ig-publicAppBar(
          leading: isSwipeUp == true ? ig-publicAppBarLeading(
            press: () async {
              PopupBuilder(
                title: TextConstant.notification,
                content: '',
                onContentWidget: Text.rich(
                  TextSpan(
                    children: <TextSpan> [
                      TextSpan(
                        text: TextConstant.seatNoSelectAndExitDescription[0],
                        style: TextStyle(
                          color: ColorConfig().dark(),
                          fontSize: 14.0.sp,
                          fontWeight: FontWeight.w700
                        ),
                      ),
                      TextSpan(
                        text: TextConstant.seatNoSelectAndExitDescription[1],
                        style: TextStyle(
                          color: ColorConfig().accent(),
                          fontSize: 14.0.sp,
                          fontWeight: FontWeight.w700
                        ),
                      ),
                      TextSpan(
                        text: TextConstant.seatNoSelectAndExitDescription[2],
                        style: TextStyle(
                          color: ColorConfig().dark(),
                          fontSize: 14.0.sp,
                          fontWeight: FontWeight.w700
                        ),
                      ),
                    ],
                  ),
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
                            color: ColorConfig().white(),
                            border: Border.all(
                              width: 1.0,
                              color: ColorConfig().gray3(),
                            ),
                            borderRadius: BorderRadius.circular(4.0.r),
                          ),
                          child: Center(
                            child: CustomTextBuilder(
                              text: TextConstant.stay,
                              fontColor: ColorConfig().dark(),
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          
                          setState(() {
                            isSwipeUp = false;
                            purchaseTextController.text = '';
                            selectedCouponList.clear();
                            holdingTimer?.cancel();
                            holdingMinute = 3;
                            holdingSecond = 0;
                            holdSeatData.clear();
                          });
                
                          TicketHoldingCancelAPI().holdCancel(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'));
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
                              text: TextConstant.exit,
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
            iconColor: ColorConfig().gray3(),
          ) : ig-publicAppBarLeading(
            press: () {},
            using: false,
          ),
          backgroundColor: isSwipeUp == true ? ColorConfig().gray1() : null,
          title: ig-publicAppBarTitle(
            title: isSwipeUp != true ? TextConstant.selectSeat : TextConstant.payingOffOn,
          ),
          actions: isSwipeUp != true ? [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: SVGBuilder(
                image: 'assets/icon/close_normal.svg',
                width: 24.0.w,
                height: 24.0.w,
                color: ColorConfig().gray3(),
              ),
            ),
          ] : null,
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: ColorConfig().gray5(),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 좌석 표시 색상 영역
                  seatMarkingColorWidget(),
                  // 층 선택 토글 영역
                  floorSelectToggleButtonWidget(),
                  // 좌석 레이어 영역
                  seatWrapperWidget(),
                  // 좌석 등급 영역
                  seatSelectRankWidget(),
                  // 하단 요소 크기값
                  SizedBox(
                    height: (12.0 + 24.0.w) + (30.0 + 20.0.w * 3) + (36.0 + 36.0 + 16.0.sp),
                  ),
                ],
              ),
              // 결제하기 bottom sheet 및 선택완료 버튼
              Positioned(
                bottom: 0.0,
                child: Column(
                  children: [
                    // 결제하기 bottom sheet 영역
                    GestureDetector(
                      onTap: selectSeatName.isNotEmpty
                        ? () async {
                          if (isSwipeUp == false) {
                            setState(() {
                              List ticketPrice = [];
                              List selectSeatInfo = [];
                              int totalPrice = 0;

                              for (int i=0; i<selectSeatName.length; i++) {
                                selectSeatInfo.add(selectSeats.firstWhere((e) => e['name'] == selectSeatName[i], orElse: () => null));

                                for (int j=0; j<widget.seat['seats'].length; j++) {
                                  if (selectSeatInfo[i]['rank'] == widget.seat['seats'][j]['seat_name']) {
                                    ticketPrice.add(widget.seat['seats'][j]['discount']);
                                    totalPrice += int.parse(ticketPrice[i].toString());
                                  }
                                }
                              }

                              isSwipeUp = true;
                              purchaseTextController.text = SetIntl().numberFormat(totalPrice);
                              existingAmount = int.parse(purchaseTextController.text.replaceAll(',', ''));
                            });
    
                            TicketHoldingAPI().holding(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), seatData: selectSeats).then((value) {
                              setState(() {
                                holdSeatData = value.result['data'];
                              });
                            });
    
                            holdingScheduler();
                          }
                        }
                        : () {
                          PopupBuilder(
                            title: TextConstant.hasNoSelectSeat,
                            content: TextConstant.selectSeatPlease,
                            actions: [
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    splashColor: ColorConfig.transparent,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width - 112.0.w,
                                      padding: const EdgeInsets.symmetric(vertical: 16.5),
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
                              ),
                            ],
                          ).ig-publicDialog(context);
                        },
                      child: AnimatedContainer(
                        width: MediaQuery.of(context).size.width,
                        height: isSwipeUp != true ? (12.0 + 24.0.w) + (30.0 + 20.0.w * 3) : MediaQuery.of(context).size.height - (const ig-publicAppBar().preferredSize.height + MediaQuery.of(context).padding.top + (36.0 + 36.0 + 16.0.sp)),
                        curve: Curves.easeIn,
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: ColorConfig().white(),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(6.0.r),
                            topRight: Radius.circular(6.0.r),
                          ),
                        ),
                        child: isSwipeUp != true
                          ? Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomTextBuilder(
                                      text: TextConstant.selectedSeat,
                                      fontColor: ColorConfig().dark(),
                                      fontSize: 18.0.sp,
                                      fontWeight: FontWeight.w800,
                                      height: 1.0,
                                    ),
                                  ],
                                ),
                              ),
                              // 좌석정보
                              Column(
                                children: List.generate(selectSeatName.length >= 3 ? 3 : selectSeatName.length, (index) {
                                  dynamic ticketPrice;
                                  dynamic selectSeatInfo = selectSeats.firstWhere((e) => e['name'] == selectSeatName[index], orElse: () => null);
    
                                  for (int i=0; i<widget.seat['seats'].length; i++) {
                                    if (selectSeatInfo['rank'] == widget.seat['seats'][i]['seat_name']) {
                                      ticketPrice = widget.seat['seats'][i];
                                    }
                                  }
    
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomTextBuilder(
                                          text: selectSeatName[index],
                                          fontColor: ColorConfig().primary(),
                                          fontSize: 14.0.sp,
                                          fontWeight: FontWeight.w800,
                                          height: 1.0,
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(right: 8.0),
                                              child: CustomTextBuilder(
                                                text: '${SetIntl().numberFormat(ticketPrice['discount'])}원',
                                                fontColor: ColorConfig().dark(),
                                                fontSize: 12.0.sp,
                                                fontWeight: FontWeight.w400,
                                                height: 1.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ],
                          )
                        : SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 공연일정 영역
                                Container(
                                  color: ColorConfig().gray1(),
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomTextBuilder(
                                        text: TextConstant.showSchedule,
                                        fontColor: ColorConfig().dark(),
                                        fontSize: 14.0.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(right: 4.0),
                                            child: CustomTextBuilder(
                                              text: DateFormat('yyyy. M. dd (E)', 'ko').format(DateTime.parse(widget.seat['open_date']).toLocal()),
                                              fontColor: ColorConfig().dark(),
                                              fontSize: 14.0.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          CustomTextBuilder(
                                            text: DateFormat('aa hh:mm', 'ko').format(DateTime.parse(widget.seat['open_date']).toLocal()),
                                            fontColor: ColorConfig().gray5(),
                                            fontSize: 14.0.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // 캐스팅 영역
                                Container(
                                  color: ColorConfig().gray1(),
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 1.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomTextBuilder(
                                        text: TextConstant.casting,
                                        fontColor: ColorConfig().dark(),
                                        fontSize: 14.0.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      Container(
                                        constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context).size.width / 2,
                                        ),
                                        child: CustomTextBuilder(
                                          text: '${artistsName.toString().replaceAll('[', '').replaceAll(']', '')} 외',
                                          fontColor: ColorConfig().gray5(),
                                          fontSize: 14.0.sp,
                                          fontWeight: FontWeight.w400,
                                          textAlign: TextAlign.end,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // empty space
                                Container(
                                  height: 8.0,
                                  color: ColorConfig().gray1(),
                                ),
                                // 좌석정보 타이틀 영역
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: CustomTextBuilder(
                                    text: TextConstant.seatInformation,
                                    fontColor: ColorConfig().dark(),
                                    fontSize: 14.0.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                // 좌석정보 영역
                                Column(
                                  children: List.generate(selectSeatName.length, (index) {
                                    dynamic ticketPrice;
                                    dynamic selectSeatInfo = selectSeats.firstWhere((e) => e['name'] == selectSeatName[index], orElse: () => null);
    
                                    for (int i=0; i<widget.seat['seats'].length; i++) {
                                      if (selectSeatInfo['rank'] == widget.seat['seats'][i]['seat_name']) {
                                        ticketPrice = widget.seat['seats'][i];
                                      }
                                    }
    
                                    return Container(
                                      width: MediaQuery.of(context).size.width,
                                      // margin: const EdgeInsets.symmetric(vertical: 8.0),
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
                                      decoration: BoxDecoration(
                                        border: index != 0 ? Border(
                                          top: BorderSide(
                                            width: 1.0,
                                            color: ColorConfig().divider1(),
                                          ),
                                        ) : null,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(bottom: 4.0),
                                            child: CustomTextBuilder(
                                              text: selectSeatName[index],
                                              fontColor: ColorConfig().dark(),
                                              fontSize: 14.0.sp,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          CustomTextBuilder(
                                            text: '${SetIntl().numberFormat(ticketPrice['discount'])}원',
                                            fontColor: ColorConfig().dark(),
                                            fontSize: 12.0.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                                Divider(
                                  color: ColorConfig().divider1(),
                                  thickness: 8.0,
                                ),
                                // 쿠폰 타이틀 영역
                                Container(
                                  margin: const EdgeInsets.only(top: 8.0),
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                  child: CustomTextBuilder(
                                    text: TextConstant.showCouponOrCoupon,
                                    fontColor: ColorConfig().dark(),
                                    fontSize: 14.0.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                // 쿠폰 선택 영역
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                                  child: InkWell(
                                    onTap: () async {
                                      AvailableCouponListAPI().availableCouponList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((couponData) {
                                        couponBottomSheetWidget(couponData.result['data']);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15.0),
                                      decoration: BoxDecoration(
                                        color: ColorConfig().gray1(),
                                        border: Border.all(
                                          width: 1.0,
                                          color: ColorConfig().gray4(),
                                        ),
                                        borderRadius: BorderRadius.circular(4.0.r),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(left:  8.0),
                                            child: CustomTextBuilder(
                                              text: TextConstant.pleaseSelectShowCouponOrCoupon,
                                              fontColor: ColorConfig().gray4(),
                                              fontSize: 14.0.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          SVGBuilder(
                                            image: 'assets/icon/triangle-down.svg',
                                            width: 24.0.w,
                                            height: 24.0.w,
                                            color: ColorConfig().gray5(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // 선택한 쿠폰 영역
                                Column(
                                  children: List.generate(selectedCouponList.length, (index) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
                                      decoration: BoxDecoration(
                                        border: index != 0 ? Border(
                                          top: BorderSide(
                                            width: 1.0,
                                            color: ColorConfig().divider1(),
                                          ),
                                        ) : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(bottom: 4.0),
                                                child: CustomTextBuilder(
                                                  text: '${selectedCouponList[index]['name']}',
                                                  fontColor: ColorConfig().dark(),
                                                  fontSize: 14.0.sp,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              CustomTextBuilder(
                                                text: '${selectedCouponList[index]['type'] == 1 ? '잔여금액' : '금액'}: ${SetIntl().numberFormat(selectedCouponList[index]['available_point'])}원',
                                                fontColor: ColorConfig().accent(),
                                                fontSize: 12.0.sp,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ],
                                          ),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                // if (selectedCouponList[index]['type'] == 1) {
                                                //   purchaseTextController.text = '${SetIntl().numberFormat(int.parse(purchaseTextController.text.replaceAll(',', '')) + existingAmount < int.parse(purchaseTextController.text.replaceAll(',', '')) ? 0 : int.parse(selectedCouponList[index]['available_point'].toString()))}';
                                                //   showCouponTotalPrice -= int.parse(selectedCouponList[index]['available_point'].toString());
                                                // } else if (selectedCouponList[index]['type'] == 2) {
                                                  couponTotalPrice -= int.parse(selectedCouponList[index]['available_point'].toString());
                                                  purchaseTextController.text = '${SetIntl().numberFormat(existingAmount - couponTotalPrice)}';
                                                // }

                                                selectedCouponList.removeAt(index);
                                                selectedCouponIndex.removeAt(index);
                                              });
                                            },
                                            child: SVGStringBuilder(
                                              image: 'assets/icon/del-list.svg',
                                              width: 16.0.w,
                                              height: 16.0.w,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ),
                                Divider(
                                  color: ColorConfig().divider1(),
                                  thickness: 8.0,
                                ),
                                // 결제금액 타이틀, 보유 ig-public머니 영역
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 11.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          CustomTextBuilder(
                                            text: '총 ',
                                            fontColor: ColorConfig().dark(),
                                            fontSize: 14.0.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          CustomTextBuilder(
                                            text: '${SetIntl().numberFormat(selectSeatName.length)}장',
                                            fontColor: ColorConfig().primary(),
                                            fontSize: 14.0.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          CustomTextBuilder(
                                            text: ' 결제금액',
                                            fontColor: ColorConfig().dark(),
                                            fontSize: 14.0.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          SVGStringBuilder(
                                            image: 'assets/icon/money_won.svg',
                                            width: 16.0.w,
                                            height: 16.0.w,
                                          ),
                                          Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                            child: CustomTextBuilder(
                                              text: '${ig-publicMoney != 0 ? SetIntl().numberFormat(ig-publicMoney) : 0} 원',
                                              fontColor: ColorConfig().dark(),
                                              fontSize: 14.0.sp,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          CustomTextBuilder(
                                            text: '보유',
                                            fontColor: ColorConfig().gray5(),
                                            fontSize: 14.0.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // 결제금액 표시 영역
                                // 충전금액 입력 위젯                                                                                                                                                                                     
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 16.0),
                                  child: TextFormField(
                                    controller: purchaseTextController,
                                    focusNode: purchaseFocusNode,
                                    enabled: false,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 17.0),
                                      filled: true,
                                      fillColor: ColorConfig().primaryLight3(),
                                      disabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 2.0,
                                          color: ColorConfig().primary(),
                                        ),
                                      ),
                                      prefixIcon: Container(
                                        margin: const EdgeInsets.only(left: 16.0, right: 8.0),
                                        child: SVGStringBuilder(
                                          image: 'assets/icon/money_won.svg',
                                          width: 22.0.w,
                                          height: 22.0.w,                                                                
                                        ),
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: ColorConfig().gray5(),
                                      fontSize: 18.0.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Divider(
                                  color: ColorConfig().divider1(),
                                  thickness: 8.0,
                                ),
                                // 주의사항 타이틀 영역
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                  margin: const EdgeInsets.only(top: 8.0),
                                  child: CustomTextBuilder(
                                    text: TextConstant.caution,
                                    fontColor: ColorConfig().dark(),
                                    fontSize: 14.0.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                // 주의사항 영역
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: List.generate(TextConstant.ticketingCaution.length, (index) {
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 8.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 4.0.w,
                                              height: 4.0.w,
                                              margin: const EdgeInsets.only(top: 3.0, right: 10.0),
                                              decoration: BoxDecoration(
                                                color: ColorConfig().gray5(),
                                                borderRadius: BorderRadius.circular(2.0.r),
                                              ),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context).size.width - (50.0 + 4.0.w),
                                              child: CustomTextBuilder(
                                                text: TextConstant.ticketingCaution[index],
                                                fontColor: ColorConfig().gray5(),
                                                fontSize: 12.0.sp,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                const SizedBox(height: 40.0),
                              ],
                            ),
                          ),
                      ),
                    ),
                    // 선택완료 버튼 영역
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 24.0),
                      decoration: BoxDecoration(
                        color: ColorConfig().white(),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 8.0,
                            color: ColorConfig.defaultBlack.withOpacity(0.12),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: selectSeatName.isNotEmpty
                          ? isSwipeUp != true
                            ? () async {
                                setState(() {
                                  List ticketPrice = [];
                                  List selectSeatInfo = [];
                                  int totalPrice = 0;

                                  for (int i=0; i<selectSeatName.length; i++) {
                                    selectSeatInfo.add(selectSeats.firstWhere((e) => e['name'] == selectSeatName[i], orElse: () => null));

                                    for (int j=0; j<widget.seat['seats'].length; j++) {
                                      if (selectSeatInfo[i]['rank'] == widget.seat['seats'][j]['seat_name']) {
                                        ticketPrice.add(widget.seat['seats'][j]['discount']);
                                        totalPrice += int.parse(ticketPrice[i].toString());
                                      }
                                    }
                                  }

                                  isSwipeUp = true;
                                  purchaseTextController.text = SetIntl().numberFormat(totalPrice);
                                  existingAmount = int.parse(purchaseTextController.text.replaceAll(',', ''));
                                });
    
                                TicketHoldingAPI().holding(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), seatData: selectSeats).then((value) {
                                  setState(() {
                                    holdSeatData = value.result['data'];
                                  });
                                });
                                
                                holdingScheduler();
                              }
                            : () async {
                              List holdSeatIndex = [];
    
                              for (int i=0; i<holdSeatData.length; i++) {
                                holdSeatIndex.add(holdSeatData[i]['ticket_index']);
                              }

                              if (int.parse(purchaseTextController.text.replaceAll(',', '')) > ig-publicMoney) {
                                Navigator.pushNamed(context, 'ig-publicMoneyPurchase');
                              } else {
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
                                            padding: const EdgeInsets.symmetric(vertical: 16.5),
                                            margin: const EdgeInsets.only(right: 8.0),
                                            decoration: BoxDecoration(
                                              color: ColorConfig().white(),
                                              border: Border.all(
                                                width: 1.0,
                                                color: ColorConfig().gray3(),
                                              ),
                                              borderRadius: BorderRadius.circular(4.0.r),
                                            ),
                                            child: Center(
                                              child: CustomTextBuilder(
                                                text: TextConstant.close,
                                                fontColor: ColorConfig().dark(),
                                                fontSize: 14.0.sp,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            TicketBuyingAPI().ticketBuy(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), ticketIndexDatas: holdSeatIndex, couponIndexDatas: selectedCouponIndex.isNotEmpty ? selectedCouponIndex : null).then((value) {
                                              Navigator.pop(context);
      
                                              // 성공
                                              if (value.result['status'] == 1) {
                                                PopupBuilder(
                                                  title: TextConstant.purchaseSuccess,
                                                  content: TextConstant.purchaseSuccessDescription,
                                                  actions: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            Navigator.pop(context);
                                                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainBuilder(crnIndex: 2)), (route) => false);
                                                            Navigator.pushNamed(context, 'ticketHistory', arguments: {
                                                              "tabIndex": null,
                                                            });
                                                          },
                                                          splashColor: ColorConfig.transparent,
                                                          child: Container(
                                                            width: (MediaQuery.of(context).size.width - 112.0.w),
                                                            padding: const EdgeInsets.symmetric(vertical: 16.5),
                                                            decoration: BoxDecoration(
                                                              color: ColorConfig().dark(),
                                                              borderRadius: BorderRadius.circular(4.0.r),
                                                            ),
                                                            child: Center(
                                                              child: CustomTextBuilder(
                                                                text: TextConstant.viewTicketHistory,
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
                                              }
                                              // ig-public머니 부족
                                              else if (value.result['status'] == 0) {
                                                ToastModel().iconToast(value.result['message'], iconType: 2);
                                              }
                                              // 홀딩 된 좌석이 없음
                                              else if (value.result['status'] == -1) {
                                                ToastModel().iconToast(value.result['message'], iconType: 2);
                                              }
                                              // 구매 요청 수와 홀딩 된 좌석 수가 다름
                                              else if (value.result['status'] == -2) {
                                                ToastModel().iconToast(value.result['message'], iconType: 2);
                                              }
                                              // 홀딩 시간이 지났거나 이미 팔린 좌석
                                              else if (value.result['status'] == -3) {
                                                ToastModel().iconToast(value.result['message'], iconType: 2);
                                              }
                                              // 쿠폰 사용 수와 사용 가능 쿠폰 사용수가 다름
                                              else if (value.result['status'] == -3) {
                                                ToastModel().iconToast(value.result['message'], iconType: 2);
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
                                                text: TextConstant.ok,
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
                              }
                            }
                          : () {
                            PopupBuilder(
                              title: TextConstant.hasNoSelectSeat,
                              content: TextConstant.selectSeatPlease,
                              actions: [
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      splashColor: ColorConfig.transparent,
                                      child: Container(
                                        width: MediaQuery.of(context).size.width - 112.0.w,
                                        padding: const EdgeInsets.symmetric(vertical: 16.5),
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
                                ),
                              ],
                            ).ig-publicDialog(context);
                          },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: isSwipeUp == true ? 20.0 : 0.0, vertical: 18.0),
                          decoration: BoxDecoration(
                            color: selectSeatName.isNotEmpty
                              ? purchaseTextController.text.isNotEmpty && int.parse(purchaseTextController.text.replaceAll(',', '')) > ig-publicMoney
                                ? ColorConfig().accent()
                                : ColorConfig().primary()
                              : ColorConfig().gray2(),
                            borderRadius: BorderRadius.circular(4.0.r),
                          ),
                          child: isSwipeUp != true
                            ? Center(
                              child: CustomTextBuilder(
                                text: selectSeatName.isNotEmpty ? TextConstant.selectComplete : TextConstant.selectSeatPlease,
                                fontColor: selectSeatName.isNotEmpty ? ColorConfig().white() : ColorConfig().gray3(),
                                fontSize: 16.0.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomTextBuilder(
                                  text: purchaseTextController.text.isNotEmpty && int.parse(purchaseTextController.text.replaceAll(',', '')) > ig-publicMoney ? TextConstant.fillig-publicMoneyAfterPurchase : TextConstant.payingOffOn,
                                  fontColor: ColorConfig().white(),
                                  fontSize: 16.0.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                                CustomTextBuilder(
                                  text: '0$holdingMinute:${holdingSecond < 10 ? '0$holdingSecond' : holdingSecond}',
                                  fontColor: ColorConfig().white(),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ],
                            ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 좌석 표시 색상 위젯
  Widget seatMarkingColorWidget() {
    return Container(
      color: ColorConfig().gray1(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 15.0.w,
              height: 15.0.w,
              margin: const EdgeInsets.only(right: 4.0),
              decoration: BoxDecoration(
                color: ColorConfig().primary(),
                borderRadius: BorderRadius.circular(4.0.r),
              ),
            ),
            CustomTextBuilder(
              text: TextConstant.selectedSeat,
              fontColor: ColorConfig().gray4(),
              fontSize: 12.0.sp,
              fontWeight: FontWeight.w400,
            ),
            Container(
              width: 15.0.w,
              height: 15.0.w,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                color: ColorConfig().primaryLight(),
                borderRadius: BorderRadius.circular(4.0.r),
              ),
            ),
            CustomTextBuilder(
              text: TextConstant.ableSelectSeat,
              fontColor: ColorConfig().gray4(),
              fontSize: 12.0.sp,
              fontWeight: FontWeight.w400,
            ),
            Container(
              width: 15.0.w,
              height: 15.0.w,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                color: ColorConfig().gray5(opacity: 0.5),
                borderRadius: BorderRadius.circular(4.0.r),
              ),
            ),
            CustomTextBuilder(
              text: TextConstant.unableSelectSeat,
              fontColor: ColorConfig().gray4(),
              fontSize: 12.0.sp,
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
      ),
    );
  }

  // 층 선택 토글 버튼 위젯
  Widget floorSelectToggleButtonWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22.0, 0.0, 14.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          selectFloorList.isNotEmpty ? Container(
            decoration: BoxDecoration(
              color: ColorConfig().gray2(),
              borderRadius: BorderRadius.circular(4.0.r),
            ),
            child: ToggleButtons(
              constraints: const BoxConstraints(
                minWidth: 10.0,
                minHeight: 10.0,
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              borderRadius: BorderRadius.circular(4.0.r),
              borderWidth: 0.0,
              borderColor: ColorConfig.transparent,
              selectedBorderColor: ColorConfig.transparent,
              color: ColorConfig.defaultBlack,
              selectedColor: ColorConfig.defaultBlack,
              fillColor: ColorConfig().white(),
              splashColor: ColorConfig.transparent,
              highlightColor: ColorConfig.transparent,
              isSelected: selectFloorList,
              onPressed: (index) {
                for (int i=0; i<selectFloorList.length; i++) {
                  if (i == index) {
                    setState(() {
                      selectFloorList[i] = true;
                      selectSeatRank = TextConstant.all;
                    });
                  } else {
                    setState(() {
                      selectFloorList[i] = false;
                    });
                  }
                }
              },
              children: List.generate(selectFloorList.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                  child: Center(
                    child: CustomTextBuilder(
                      text: '${index + 1}층',
                      fontColor: ColorConfig.defaultBlack,
                      fontSize: 14.0.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                );
              }),
            ),
          ) : Container(),
          // refresh 버튼 영역
          IconButton(
            onPressed: () async {
              CheckSeatListAPI().checkList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), showContentTicketIndex: widget.showTicketIndex).then((value) {
                setState(() {
                  checkSeatListData = value.result['data'];
                });
              });
            },
            icon: SVGStringBuilder(
              image: 'assets/icon/btn-refresh.svg',
              width: 24.0.w,
              height: 24.0.w,
            ),
          ),
        ],
      ),
    );
  }

  // 좌석 레이어 위젯
  Widget seatWrapperWidget() {
    return Expanded(
      child: Listener(
        onPointerDown: (event) {
          setState(() {
            pointersCount++;
          });
        },
        onPointerUp: (event) {
          setState(() {
            pointersCount--;
          });
        },
        child: InteractiveViewer(
          minScale: 0.6,
          maxScale: 3.0,
          constrained: false,
          transformationController: transformationController,
          // onInteractionStart: (details) {
          //   previousScale = currentScale;
          //   setState(() {});
          // },
          // onInteractionUpdate: (details) {
          //   currentScale = previousScale * details.scale;
                  
          //   if (currentScale > 3) {
          //     currentScale = 3.0;
          //   } else if (currentScale < 0.7) {
          //     currentScale = 0.7;
          //   }
    
          //   // indicatorOffset = Offset(((transformationController.value.row0.a).abs() / (((positionKey.currentContext?.findRenderObject() as RenderBox).size.width - 390.0) * currentScale) * 100).clamp(0.0, 150.0 - indicatorWidth), ((transformationController.value.row1.a).abs() / (((positionKey.currentContext?.findRenderObject() as RenderBox).size.height - 741.0) * currentScale) * 100).clamp(0.0, 150.0 - indicatorHeight));
                  
          //   setState(() {});
          // },
          // onInteractionEnd: (details) {
          //   // double _initIndicatorWidth = 51.0;
          //   // double _initIndicatorHeight = 66.0;
                  
          //   // if (currentScale > 1.0) {
          //   //   indicatorWidth = _initIndicatorWidth / (currentScale / 1.5);
          //   //   indicatorHeight = _initIndicatorHeight / (currentScale / 1.5);
          //   // } else {
          //   //   indicatorWidth = _initIndicatorWidth;
          //   //   indicatorHeight = _initIndicatorHeight;
          //   // }
                  
          //   setState(() {});
          // },
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            controller: _verticalController,
            physics: pointersCount == 2 ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: _horizontalController,
              physics: pointersCount == 2 ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
              child: Column(
                key: positionKey,
                children: [
                  Padding(
                    padding: EdgeInsets.all(scalePadding),
                    child: showSeats(),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 좌석 등급 선택 위젯
  Widget seatSelectRankWidget() {
    List toSetSeatNames = [TextConstant.all];

    for (int i=0; i<widget.seat['seat'][selectFloorList.indexOf(true)]['seats'].length; i++) {
      if (!toSetSeatNames.contains(widget.seat['seat'][selectFloorList.indexOf(true)]['seats'][i]['rank']) && widget.seat['seat'][selectFloorList.indexOf(true)]['seats'][i]['rank'] != '' && widget.seat['seat'][selectFloorList.indexOf(true)]['seats'][i]['status'] == 2) {
        toSetSeatNames.add(widget.seat['seat'][selectFloorList.indexOf(true)]['seats'][i]['rank']);
      }
    }

    return Container(
      height: 28.0 + 16.0 + 2.0 + 14.0.sp,
      padding: const EdgeInsets.only(top: 12.0, bottom: 16.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: toSetSeatNames.length,
        padding: const EdgeInsets.only(left: 20.0, right: 12.0),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              setState(() {
                selectSeatRank = '${toSetSeatNames[index]}';

                // 선택한 좌석 등급 위치로 이동
                if (selectSeatRank != TextConstant.all) {
                  dynamic firstSeatPosition;
                  firstSeatPosition = widget.seat['seat'][selectFloorList.indexOf(true)]['seats'].firstWhere((e) => e['rank'] == selectSeatRank && e['status'] == 2, orElse: () => null);

                  transformationController.value = Matrix4.identity()..translate(-(firstSeatPosition['x'] * (30.0.w * 0.6)), -(firstSeatPosition['y'] * (30.0.w * 0.6)))..scale(0.6);
                } else {
                  dynamic firstSeatPosition;
                  firstSeatPosition = widget.seat['seat'][selectFloorList.indexOf(true)]['seats'].firstWhere((e) => e['status'] == 2, orElse: () => null);

                  transformationController.value = Matrix4.identity()..translate(-(firstSeatPosition['x'] * (30.0.w * 0.6)), 0.0)..scale(0.6);
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: selectSeatRank == '${toSetSeatNames[index]}' ? ColorConfig().primary() : ColorConfig().white(),
                border: Border.all(
                  width: 1.0,
                  color: selectSeatRank != '${toSetSeatNames[index]}' ? ColorConfig().gray3() : ColorConfig.transparent,
                ),
                borderRadius: BorderRadius.circular(4.0.r),
              ),
              child: Center(
                child: CustomTextBuilder(
                  text: '${toSetSeatNames[index]}${toSetSeatNames[index] != TextConstant.all ? '석' : ''}',
                  fontColor: selectSeatRank == '${toSetSeatNames[index]}' ? ColorConfig().white() : ColorConfig().dark(),
                  fontSize: 14.0.sp,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 좌석 리스트 위젯
  Widget showSeats() {
    int seatRowCount_ = 0;
    List<Widget> listX_ = [];
    List<Widget> returnListRow_ = [];
    List allSeatCount_ = [];
    List maxRowCount_ = [];

    // 모든 좌석 리스트에 담아줌
    if (selectFloorList.isNotEmpty) {
      allSeatCount_ = catalogdata[selectFloorList.indexOf(true)]['seats'];

      for (int i = 0; i < allSeatCount_.length; i++) {
        listX_.add(seatsWidget(i));
        // 최대 x값 추출
        if (!maxRowCount_.contains(catalogdata[selectFloorList.indexOf(true)]['seats'][i]['x'])) {
          maxRowCount_.add(catalogdata[selectFloorList.indexOf(true)]['seats'][i]['x']);
        }
      }

      seatRowCount_ = maxRowCount_.length;
    }

    // 층별 좌석 갯수를 구한후 나눠준다
    List seatsArr(List<Widget> list, int listSize) {
      int len = list.length;
      for (var i = 0; i < len; i += listSize) {
        int size = i + listSize;
        returnListRow_.add(Row(
          children: list.sublist(i, size > len ? len : size),
        ));
      }
      return returnListRow_;
    }

    seatsArr(listX_, seatRowCount_);

    return GestureDetector(
      // 좌석 여러개 선택
      onLongPressMoveUpdate: (details) {
        final RenderBox box = seatAllKey.currentContext!.findAncestorRenderObjectOfType<RenderBox>()!;
        final result = BoxHitTestResult();
        // Offset local = seatAllKey.currentContext!.findAncestorRenderObjectOfType<RenderBox>()!.globalToLocal(event.position);
        if (box.hitTest(result, position: details.localPosition)) {
          for (final hit in result.path) {
            final target = hit.target;
            if (target is SeatMultiSelectRenderBox && !trackTaped.contains(target)) {
              if (catalogdata[selectFloorList.indexOf(true)]['seats'][target.index]['name'].contains(catalogdata[selectFloorList.indexOf(true)]['seats'][target.index]['name'])) {
                if (catalogdata[selectFloorList.indexOf(true)]['seats'][target.index]['status'] == 2) {
                  if (7 > selectSeatsIndex.length) {
                    trackTaped.add(target);

                    setState(() {
                      if (!selectSeatsIndex.contains(target.index)) {
                        selectSeats.add(widget.seat['seat'][selectFloorList.indexOf(true)]['seats'][target.index]);
                        selectSeatsIndex.add(target.index);
                        selectSeatName.add(catalogdata[selectFloorList.indexOf(true)]['seats'][target.index]['name']);
                      }
                    });
                  }
                }
              }
            }
          }
        }
      },
      child: Column(
        key: seatAllKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: returnListRow_,
      ),
    );
  }
  
  // 각각의 좌석 데이터 위젯
  Widget seatsWidget(int ia) {
    return SeatMultiSelectRenderModel(
      index: ia,
      child: Container(
        width: 30.0.w,
        height: 30.0.w,
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: selectSeatsIndex.contains(ia) && selectSeats[selectSeatsIndex.indexOf(ia)]['name'] == selectSeatName[(selectSeatsIndex.indexOf(ia))] && selectSeatName[selectSeatsIndex.indexOf(ia)] == widget.seat['seat'][selectFloorList.indexOf(true)]['seats'][ia]['name']
            ? ColorConfig().primary()
            : catalogdata[selectFloorList.indexOf(true)]['seats'][ia]['status'] == 0
              ? ColorConfig.transparent
              : catalogdata[selectFloorList.indexOf(true)]['seats'][ia]['status'] == 1 || (checkSeatListData.isNotEmpty && checkSeatListData.firstWhere((e) => e['name'] == catalogdata[selectFloorList.indexOf(true)]['seats'][ia]['name'], orElse: () => null)['status'] == true && checkSeatListData.contains(checkSeatListData.firstWhere((e) => e['name'] == catalogdata[selectFloorList.indexOf(true)]['seats'][ia]['name'], orElse: () => null)))
                ? ColorConfig().primaryLight3(opacity: 0.5)
                : selectSeatRank == TextConstant.all || selectSeatRank == catalogdata[selectFloorList.indexOf(true)]['seats'][ia]['rank']
                  ? ColorConfig().primaryLight()
                  : ColorConfig().primaryLight3(opacity: 0.5),
          borderRadius: BorderRadius.circular(4.0.r),
        ),
        child: catalogdata.isNotEmpty
          ? catalogdata[selectFloorList.indexOf(true)]['seats'][ia]['status'] == 2 && (checkSeatListData.isNotEmpty && checkSeatListData.firstWhere((e) => e['name'] == catalogdata[selectFloorList.indexOf(true)]['seats'][ia]['name'], orElse: () => null)['status'] == true && checkSeatListData.contains(checkSeatListData.firstWhere((e) => e['name'] == catalogdata[selectFloorList.indexOf(true)]['seats'][ia]['name'], orElse: () => null))) == false
            ? TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                onPressed: () {
                  setState(() {
                    if (!selectSeatsIndex.contains(ia)) {
                      if (7 > selectSeatsIndex.length) {
                        int selectFloor = selectFloorList.indexOf(true) + 1;
                        dynamic lseat = widget.seat['seat'][selectFloor - 1]['seats'][ia];
                        lseat['floor'] = selectFloor;

                        for (int i=0; i<widget.seat['seats'].length; i++) {
                          if (lseat['rank'] == widget.seat['seats'][i]['seat_name']) {
                            lseat['seat_index'] = widget.seat['seats'][i]['seat_index'];
                          }
                        }

                        selectSeats.add(lseat);
                        selectSeatsIndex.add(ia);
                        selectSeatName.add(catalogdata[selectFloorList.indexOf(true)]['seats'][ia]['name']);
                      }
                    } else {
                      selectSeats.remove(widget.seat['seat'][selectFloorList.indexOf(true)]['seats'][ia]);
                      selectSeatsIndex.remove(ia);
                      selectSeatName.remove(catalogdata[selectFloorList.indexOf(true)]['seats'][ia]['name']);
                      
                      // 다수 선택 데이터 지우기
                      for (int i=0; i<trackTaped.length; i++) {
                        if (trackTaped.toList()[i].index == ia) {
                          final trackTapedData = trackTaped.elementAt(i);
                          trackTaped.remove(trackTapedData);
                        }
                      }
                    }
                  });
                },
                child: Container(),
              )
            : Container()
          : Container(),
      ),
    );
  }
  
  // 쿠폰 Bottom Sheet 위젯
  Future couponBottomSheetWidget(dynamic couponData) {
    return showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height / 1.2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(6.0.r),
        ),
      ),
      builder: (context) {
        int selectedCoupon = -1;
        bool isChecked = false;
        Map<String, dynamic> selectCouponData = {};

        return Container(
          color: ColorConfig().white(),
          child: StatefulBuilder(
            builder: (context, state) {
              return Column(
                children: [
                  // 상단 영역
                  ig-publicAppBar(
                    elevation: 0.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(6.0.r),
                      )
                    ),
                    leadingWidth: 0.0,
                    center: false,
                    title: ig-publicAppBarTitle(
                      title: TextConstant.selectedCoupon,
                      size: 16.0.sp,
                      fontWeight: FontWeight.w800,
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
                    color: ColorConfig().gray1(),
                    child: Stack(
                      children: [
                        // 쿠폰 영역
                        SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                            child: Column(
                              children: [
                                Column(
                                  children: List.generate(couponData.length + 1, (index) {
                                    if (index == 0) {
                                      return InkWell(
                                        onTap: () {
                                          state(() {
                                            selectedCoupon = index - 1;
                                            selectCouponData = {};
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(12.0),
                                          margin: const EdgeInsets.only(bottom: 8.0),
                                          decoration: BoxDecoration(
                                            color: ColorConfig().white(),
                                            border: Border.all(
                                              width: 1.0,
                                              color: ColorConfig().gray2(),
                                            ),
                                            borderRadius: BorderRadius.circular(6.0.r),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 24.0.w,
                                                height: 24.0.w,
                                                margin: const EdgeInsets.only(right: 12.0),
                                                decoration: BoxDecoration(
                                                  color: selectedCoupon == index - 1 ? ColorConfig().dark() : ColorConfig().gray1(),
                                                  border: Border.all(
                                                    width: 1.0,
                                                    color: selectedCoupon == index - 1 ? ColorConfig.transparent : ColorConfig().gray2(),
                                                  ),
                                                  borderRadius: BorderRadius.circular(12.0.r),
                                                ),
                                                child: selectedCoupon == index - 1 ? Center(
                                                  child: SVGBuilder(
                                                    image: 'assets/icon/check.svg',
                                                    width: 20.0.w,
                                                    height: 20.0.w,
                                                    color: ColorConfig().white(),
                                                  ),
                                                ) : Container(),
                                              ),
                                              Expanded(
                                                child: CustomTextBuilder(
                                                  text: TextConstant.noApplyCoupon,
                                                  fontColor: ColorConfig().dark(),
                                                  fontSize: 14.0.sp,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                    
                                    dynamic tmpData = selectSeats.firstWhere((e) => e['seat_index'] == couponData[index - 1]['show_content_ticket_seat_index'], orElse: () => null);
                                    bool avaliableCouponStatus = (couponData[index - 1]['show_content_index'] == 0 || widget.showContentIndex == couponData[index - 1]['show_content_index'])&& 
                                                                 (couponData[index - 1]['show_content_ticket_index'] == 0 || widget.showTicketIndex == couponData[index - 1]['show_content_ticket_index']) &&
                                                                 (couponData[index - 1]['show_content_ticket_seat_index'] == 0 || (tmpData != null && tmpData['seat_index'] == couponData[index - 1]['show_content_ticket_seat_index']))
                                      ? true : false;

                                    return InkWell(
                                      onTap: avaliableCouponStatus == true && selectedCouponList.indexWhere((e) => e['coupon_index'] == couponData[index - 1]['coupon_index']) == -1 ? () {
                                        state(() {
                                          selectedCoupon = index - 1;
                                          selectCouponData = couponData[index - 1];
                                        });
                                      } : null,
                                      child: Container(
                                        margin: index - 1 != couponData.length ? const EdgeInsets.only(top: 8.0) : index - 1 == couponData.length - 1 ? const EdgeInsets.only(bottom: 40.0) : null,
                                        child: ClipPath(
                                          clipper: TicketClipper(),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: couponData[index - 1]['type'] == 1 && avaliableCouponStatus == true && selectedCouponList.indexWhere((e) => e['coupon_index'] == couponData[index - 1]['coupon_index']) == -1 ? ColorConfig().white() : ColorConfig().white(opacity: 0.6),
                                              borderRadius: BorderRadius.circular(8.0.r),
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // 쿠폰 이미지 영역
                                                Container(
                                                  padding: couponData[index - 1]['type'] == 1 ? EdgeInsets.symmetric(horizontal: 28.0.w, vertical: 44.0.w) : EdgeInsets.all(20.0.w),
                                                  decoration: BoxDecoration(
                                                    color: couponData[index - 1]['type'] == 1
                                                      ? avaliableCouponStatus == true && selectedCouponList.indexWhere((e) => e['coupon_index'] == couponData[index - 1]['coupon_index']) == -1
                                                        ? ColorConfig().primary()
                                                        : ColorConfig().primary(opacity: 0.6)
                                                      : null,
                                                    borderRadius: couponData[index - 1]['type'] == 1 ? BorderRadius.only(
                                                      topLeft: Radius.circular(8.0.r),
                                                      bottomLeft: Radius.circular(8.0.r),
                                                    ) : null,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      // 체크박스 영역
                                                      Container(
                                                        width: 24.0.w,
                                                        height: 24.0.w,
                                                        margin: const EdgeInsets.only(right: 12.0),
                                                        decoration: BoxDecoration(
                                                          color: selectedCoupon == index - 1 ? ColorConfig().dark() : ColorConfig().gray1(),
                                                          border: Border.all(
                                                            width: 1.0,
                                                            color: selectedCoupon == index - 1 ? ColorConfig.transparent : ColorConfig().gray2(),
                                                          ),
                                                          borderRadius: BorderRadius.circular(12.0.r),
                                                        ),
                                                        child: selectedCoupon == index - 1 ? Center(
                                                          child: SVGBuilder(
                                                            image: 'assets/icon/check.svg',
                                                            width: 20.0.w,
                                                            height: 20.0.w,
                                                            color: ColorConfig().white(),
                                                          ),
                                                        ) : Container(),
                                                      ),
                                                      // 쿠폰 이미지
                                                      Container(
                                                        width: couponData[index - 1]['type'] == 1 ? 65.0.w : 80.0.w,
                                                        height: couponData[index - 1]['type'] == 1 ? 65.0.w : 114.0.w,
                                                        decoration: BoxDecoration(
                                                          color: couponData[index - 1]['image'] == null
                                                            ? avaliableCouponStatus == true && selectedCouponList.indexWhere((e) => e['coupon_index'] == couponData[index - 1]['coupon_index']) == -1
                                                              ? ColorConfig().gray2()
                                                              : ColorConfig().gray2(opacity: 0.6)
                                                            : null,
                                                          borderRadius: BorderRadius.circular(8.0.r),
                                                          image: couponData[index - 1]['image'] != null ? DecorationImage(
                                                            image: NetworkImage(couponData[index - 1]['image']),
                                                            fit: BoxFit.cover,
                                                            filterQuality: FilterQuality.high,
                                                            opacity: couponData[index - 1]['type'] == 1 || avaliableCouponStatus == true && selectedCouponList.indexWhere((e) => e['coupon_index'] == couponData[index - 1]['coupon_index']) == -1 ? 1.0 : 0.6,
                                                          ) : null,
                                                        ),
                                                        child: couponData[index - 1]['image'] == null ? Center(
                                                          child: SVGBuilder(
                                                            image: 'assets/icon/album.svg',
                                                            width: 22.0.w,
                                                            height: 22.0.w,
                                                            color: couponData[index - 1]['type'] == 1 ? ColorConfig().white() : ColorConfig().white(),
                                                          ),
                                                        ) : Container(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // 점선 라인 영역
                                                couponData[index - 1]['type'] == 2 ? CustomDottedBorderBuilder(
                                                  pattern: const [4.0,8.0],
                                                  color: couponData[index - 1]['type'] == 1 || avaliableCouponStatus == true && selectedCouponList.indexWhere((e) => e['coupon_index'] == couponData[index - 1]['coupon_index']) == -1 ? ColorConfig().gray2() : ColorConfig().gray2(opacity: 0.6),
                                                  child: SizedBox(height: 114.0.w + 40.0),
                                                ) : Container(),
                                                Expanded(
                                                  child: Container(
                                                    padding: EdgeInsets.all(16.0.w),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        // 쿠폰 이름 영역
                                                        Container(
                                                          margin: EdgeInsets.only(bottom: 8.0.w),
                                                          child: CustomTextBuilder(
                                                            text: '${couponData[index - 1]['name']}',
                                                            fontColor: couponData[index - 1]['type'] == 1 || avaliableCouponStatus == true && selectedCouponList.indexWhere((e) => e['coupon_index'] == couponData[index - 1]['coupon_index']) == -1 ? ColorConfig().primary() : ColorConfig().primary(opacity: 0.6),
                                                            fontSize: 14.0.sp,
                                                            fontWeight: FontWeight.w800,
                                                          ),
                                                        ),
                                                        // 발행처, 공연명 영역
                                                        Container(
                                                          margin: EdgeInsets.only(top: 8.0.w),
                                                          child: CustomTextBuilder(
                                                            text: '${couponData[index - 1]['type'] == 1 ? '발행' : '공연'} : ${couponData[index - 1]['item_name']}',
                                                            fontColor: couponData[index - 1]['type'] == 1 || avaliableCouponStatus == true && selectedCouponList.indexWhere((e) => e['coupon_index'] == couponData[index - 1]['coupon_index']) == -1 ? ColorConfig().dark() : ColorConfig().dark(opacity: 0.6),
                                                            fontSize: 12.0.sp,
                                                            fontWeight: FontWeight.w700,
                                                          ),
                                                        ),
                                                        // 잔여금액, 좌석 영역
                                                        Container(
                                                          margin: EdgeInsets.only(top: 4.0.w),
                                                          child: CustomTextBuilder(
                                                            text: '${couponData[index - 1]['type'] == 1 ? '잔여금액' : '좌석'} : ${couponData[index - 1]['type'] == 1 ? '${SetIntl().numberFormat(couponData[index - 1]['available_point'])}원' : couponData[index - 1]['seat_name']}',
                                                            fontColor: couponData[index - 1]['type'] == 1 || avaliableCouponStatus == true && selectedCouponList.indexWhere((e) => e['coupon_index'] == couponData[index - 1]['coupon_index']) == -1 ? ColorConfig().dark() : ColorConfig().dark(opacity: 0.6),
                                                            fontSize: 12.0.sp,
                                                            fontWeight: FontWeight.w700,
                                                          ),
                                                        ),
                                                        // 회차 영역
                                                        couponData[index - 1]['type'] == 2 ? Container(
                                                          margin: EdgeInsets.only(top: 4.0.w),
                                                          child: CustomTextBuilder(
                                                            text: '회차 : ${couponData[index - 1]['open_date'] != '전 회차' ? DateFormat('yy년 M월 d일 a h시 회차', 'ko').format(DateTime.parse(couponData[index - 1]['open_date']).toLocal()) : '전 회차'}',
                                                            fontColor: couponData[index - 1]['type'] == 1 || avaliableCouponStatus == true && selectedCouponList.indexWhere((e) => e['coupon_index'] == couponData[index - 1]['coupon_index']) == -1 ? ColorConfig().dark() : ColorConfig().dark(opacity: 0.6),
                                                            fontSize: 12.0.sp,
                                                            fontWeight: FontWeight.w700,
                                                          ),
                                                        ) : Container(),
                                                        // 공연 관람권 전용 텍스트 영역
                                                        couponData[index - 1]['type'] == 1 ? Container(
                                                          margin: EdgeInsets.only(top: 8.0.w),
                                                          child: CustomTextBuilder(
                                                            text: TextConstant.showTicketCouponText,
                                                            fontColor: couponData[index - 1]['type'] == 1 || avaliableCouponStatus == true && selectedCouponList.indexWhere((e) => e['coupon_index'] == couponData[index - 1]['coupon_index']) == -1 ? ColorConfig().gray3() : ColorConfig().gray3(opacity: 0.6),
                                                            fontSize: 12.0.sp,
                                                            fontWeight: FontWeight.w700,
                                                          ),
                                                        ) : Container(),
                                                        Container(
                                                          margin: couponData[index - 1]['type'] == 2 ? EdgeInsets.only(top: 12.0.w) : EdgeInsets.only(top: 8.0.w),
                                                          child: CustomTextBuilder(
                                                            text: DateCalculatorWrapper().deadlineCalculator(couponData[index - 1]['end_date']),
                                                            fontColor: couponData[index - 1]['type'] == 1 || avaliableCouponStatus == true && selectedCouponList.indexWhere((e) => e['coupon_index'] == couponData[index - 1]['coupon_index']) == -1 ? ColorConfig().gray3() : ColorConfig().gray3(opacity: 0.6),
                                                            fontSize: 12.0.sp,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                                SizedBox(height: 36.0 + 36.0 + 16.0.sp + 24.0 + 24.0.w),
                              ],
                            ),
                          ),
                        ),
                        // 선택완료 버튼
                        Positioned(
                          bottom: 0.0,
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  state(() {
                                    isChecked = !isChecked;
                                  });
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  color: ColorConfig().gray1(),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: isChecked,
                                        onChanged: (checked) {
                                          state(() {
                                            isChecked = checked!;
                                          });
                                        },
                                        activeColor: ColorConfig().primary(),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(2.0.r),
                                        ),
                                      ),
                                      CustomTextBuilder(
                                        text: TextConstant.couponCheckBoxText,
                                        fontColor: ColorConfig().gray5(),
                                        fontSize: 12.0.sp,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // 선택완료 버튼
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 24.0),
                                decoration: BoxDecoration(
                                  color: ColorConfig().white(),
                                  boxShadow: [
                                    BoxShadow(
                                      offset: const Offset(0.0, 0.0),
                                      blurRadius: 8.0,
                                      color: ColorConfig.defaultBlack.withOpacity(0.12),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  onTap: () {
                                    if (selectCouponData.isNotEmpty && isChecked == true) {
                                      setState(() {
                                        selectedCouponList.add(selectCouponData);
                                        selectedCouponIndex.add(selectCouponData['coupon_index']);

                                        // if (selectCouponData['type'] == 1) {
                                        //   showCouponTotalPrice += int.parse(selectCouponData['available_point'].toString());
                                        //   purchaseTextController.text = '${SetIntl().numberFormat(int.parse(purchaseTextController.text.replaceAll(',', '')) - (int.parse(selectCouponData['available_point'].toString()) > int.parse(purchaseTextController.text.replaceAll(',', '')) ? int.parse(purchaseTextController.text.replaceAll(',', '')) : int.parse(selectCouponData['available_point'].toString())))}';
                                        // } else if (selectCouponData['type'] == 2) {
                                          couponTotalPrice += int.parse(selectCouponData['available_point'].toString());
                                          purchaseTextController.text = '${SetIntl().numberFormat(int.parse(purchaseTextController.text.replaceAll(',', '')) - (int.parse(selectCouponData['available_point'].toString()) > int.parse(purchaseTextController.text.replaceAll(',', '')) ? int.parse(purchaseTextController.text.replaceAll(',', '')) : int.parse(selectCouponData['available_point'].toString())))}';
                                        // }

                                        Navigator.pop(context);
                                      });
                                    } else if (selectCouponData.isEmpty) {
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                                    decoration: BoxDecoration(
                                      color: selectCouponData.isNotEmpty && isChecked == true ? ColorConfig().primary() : ColorConfig().gray2(),
                                      borderRadius: BorderRadius.circular(4.0.r),
                                    ),
                                    child: Center(
                                      child: CustomTextBuilder(
                                        text: TextConstant.selectComplete,
                                        fontColor: selectCouponData.isNotEmpty && isChecked == true ? ColorConfig().white() : ColorConfig().gray3(),
                                        fontSize: 16.0.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// 좌석 여러개 선택 데이터를 가져오기 위한 class
class SeatMultiSelectRenderModel extends SingleChildRenderObjectWidget {
  final int index;

  const SeatMultiSelectRenderModel({
    Key? key,
    required Widget child,
    required this.index
  }) : super(child: child, key: key);

  @override
  SeatMultiSelectRenderBox createRenderObject(BuildContext context) {
    return SeatMultiSelectRenderBox()..index = index;
  }

  @override
  void updateRenderObject(BuildContext context, SeatMultiSelectRenderBox renderObject) {
    renderObject.index = index;
  }
}

class SeatMultiSelectRenderBox extends RenderProxyBox {
  late int index;
}