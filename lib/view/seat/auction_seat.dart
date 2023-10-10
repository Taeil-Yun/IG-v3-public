import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ig-public_v3/api/coupon/available_coupon.dart';
import 'package:ig-public_v3/api/history/auction_history.dart';
import 'package:ig-public_v3/api/profile/my_money.dart';
import 'package:ig-public_v3/component/border/dashed_border.dart';
import 'package:ig-public_v3/component/date_calculator/date_calculator.dart';
import 'package:ig-public_v3/util/toast.dart';
import 'package:ig-public_v3/widget/ticket_cliper.dart';

import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ig-public_v3/main.dart';
import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/api/auction/auction_betting.dart';
import 'package:ig-public_v3/api/auction/auction_betting_seat.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/component/popup/popup.dart';
import 'package:ig-public_v3/util/set_intl.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';

// ignore: must_be_immutable
class AuctionSeatScreen extends StatefulWidget {
  AuctionSeatScreen({
    super.key,
    this.seat,
    required this.showContentIndex,
    required this.showDetailIndex,
  });

  dynamic seat;
  int showDetailIndex;
  int showContentIndex;

  @override
  State<AuctionSeatScreen> createState() => _AuctionSeatScreenState();
}

class _AuctionSeatScreenState extends State<AuctionSeatScreen> with TickerProviderStateMixin {
  final TransformationController transformationController = TransformationController();
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  late TextEditingController purchaseTextController;
  late FocusNode purchaseFocusNode;
  late List catalogdata;

  GlobalKey positionKey = GlobalKey();
  GlobalKey seatAllKey = GlobalKey();

  List<bool> selectFloorList = [];
  List selectedCouponList = [];
  List myJoinedAuctionSeatList = [];

  Map<String, dynamic> selectedSeat = {};
  Map<String, dynamic> bettingSeat = {};
  Map<String, dynamic> auctionHistoryData = {};

  int pointersCount = 0;
  int couponTotalPrice = 0;
  int originPrice = 0;
  int ig-publicMoney = 0;

  double scalePadding = 40.0;

  bool isSwipeUp = false;
  bool holdingStatus = false;
  bool priceRemainingStatus = false;
  bool priceRemainingSeatCheckStatus = false;

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
    });
    return "success";
  }

  Future<void> initializeAPI() async {
    AuctionBettingAPI().getBettingSeat(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), showDetailIndex: widget.showDetailIndex).then((value) {
      setState(() {
        myJoinedAuctionSeatList = value.result['data'];
      });
    });
    Myig-publicMoneyAPI().ig-publicMoney(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
      setState(() {
        ig-publicMoney = value.result['data'][0]['point'];
      });
    });
  }

  void payCalculator(int money) {
    String text = purchaseTextController.text;
    int amount = 0;
    text = text.replaceAll(',', '');
    purchaseTextController.clear();
    setState(() {
      if (text.isNotEmpty) {
        amount = int.parse(text);
        purchaseTextController.text = SetIntl().numberFormat(amount + money).toString();
      } else {
        purchaseTextController.text = SetIntl().numberFormat(0 + money).toString();
      }
    });
  }

  bool dateOverCheck(int index, dynamic couponData) {
    if (DateTime.parse(couponData[index]['end_date']).toLocal().millisecondsSinceEpoch > DateTime.now().toLocal().millisecondsSinceEpoch) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (purchaseFocusNode.hasFocus) {
          purchaseFocusNode.unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: ig-publicAppBar(
          leading: isSwipeUp == true ? ig-publicAppBarLeading(
            press: () async {
              setState(() {
                if (priceRemainingStatus == true) {
                  priceRemainingStatus = false;
                }
                isSwipeUp = false;
                purchaseTextController.text = '';
                selectedCouponList.clear();
                couponTotalPrice = 0;
              });
            },
            iconColor: ColorConfig().gray3(),
          ) : ig-publicAppBarLeading(
            press: () {},
            using: false,
          ),
          title: ig-publicAppBarTitle(
            title: isSwipeUp != true
              ? TextConstant.selectSeat
              : priceRemainingStatus == true
                ? TextConstant.raiseAuctionPrice1
                : TextConstant.doJoinedAuction,
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
                  // 하단 요소 크기값
                  SizedBox(
                    height: (12.0 + 24.0.w) + (20.0 + 15.0.sp + 15.0.sp) + (36.0 + 36.0 + 16.0.sp),
                  ),
                ],
              ),
              // 결제하기 bottom sheet 및 선택완료 버튼
              Positioned(
                bottom: 0.0,
                child: Column(
                  children: [
                    // 결제하기 bottom sheet 영역
                    AnimatedContainer(
                      width: MediaQuery.of(context).size.width,
                      height: isSwipeUp != true ? (24.0 + 8.0 + 15.0.sp + 16.0 + 15.0.sp) : MediaQuery.of(context).size.height - (const ig-publicAppBar().preferredSize.height + MediaQuery.of(context).padding.top + (36.0 + 36.0 + 16.0.sp)),
                      curve: Curves.easeIn,
                      duration: const Duration(milliseconds: 200),
                      color: ColorConfig().white(),
                      child: isSwipeUp != true
                        ? Container(
                          padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
                          child: Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: selectedSeat.isNotEmpty
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomTextBuilder(
                                        text: '${selectedSeat['rank']}석 ${selectedSeat['name']}',
                                        fontColor: ColorConfig().dark(),
                                        fontSize: 14.0.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomTextBuilder(
                                              text: '${TextConstant.auctionStartPrice} 1,000원',
                                              fontColor: ColorConfig().gray3(),
                                              fontSize: 14.0.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            CustomTextBuilder(
                                              text: '${bettingSeat.isNotEmpty ? bettingSeat['list'].length : '0'}명 경매중',
                                              fontColor: ColorConfig().accent(),
                                              fontSize: 14.0.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CustomTextBuilder(
                                        text: '',
                                        fontColor: ColorConfig().gray3(),
                                        fontSize: 14.0.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomTextBuilder(
                                              text: '',
                                              fontColor: ColorConfig().gray3(),
                                              fontSize: 14.0.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            CustomTextBuilder(
                                              text: '',
                                              fontColor: ColorConfig().accent(),
                                              fontSize: 14.0.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                ),
                            ),
                        )
                      : SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                          child: Container(
                            color: ColorConfig().gray1(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                priceRemainingStatus == false ? Container(height: 8.0) : Container(),
                                // 공연일정 영역
                                priceRemainingStatus == false ? Container(
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
                                              text: DateFormat('yyyy. M. d. (E)', 'ko').format(DateTime.parse(widget.seat['open_date']).toLocal()),
                                              fontColor: ColorConfig().dark(),
                                              fontSize: 14.0.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          CustomTextBuilder(
                                            text: DateFormat('a h:m', 'ko').format(DateTime.parse(widget.seat['open_date']).toLocal()),
                                            fontColor: ColorConfig().gray5(),
                                            fontSize: 14.0.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ) : Container(),
                                // 공연종료일 영역
                                priceRemainingStatus == false ? Container(
                                  color: ColorConfig().gray1(),
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomTextBuilder(
                                        text: TextConstant.auctionEndDate,
                                        fontColor: ColorConfig().dark(),
                                        fontSize: 14.0.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(right: 4.0),
                                            child: CustomTextBuilder(
                                              text: DateFormat('yyyy. M. d. (E)', 'ko').format(DateTime.parse(widget.seat['end_date']).toLocal()),
                                              fontColor: ColorConfig().dark(),
                                              fontSize: 14.0.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          CustomTextBuilder(
                                            text: DateFormat('a h:m', 'ko').format(DateTime.parse(widget.seat['end_date']).toLocal()),
                                            fontColor: ColorConfig().gray5(),
                                            fontSize: 14.0.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ) : Container(),
                                // empty space
                                priceRemainingStatus == false ? Container(height: 8.0)  : Container(),
                                Container(
                                  color: ColorConfig().white(),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // 좌석정보 타이틀 영역
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                        margin: const EdgeInsets.only(top: 8.0),
                                        child: CustomTextBuilder(
                                          text: TextConstant.seatInformation,
                                          fontColor: ColorConfig().dark(),
                                          fontSize: 14.0.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      // 정가 영역
                                      priceRemainingStatus == false ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomTextBuilder(
                                              text: TextConstant.originalPrice,
                                              fontColor: ColorConfig().dark(),
                                              fontSize: 12.0.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            CustomTextBuilder(
                                              text: '${SetIntl().numberFormat(int.parse(originPrice.toString().replaceAll(',', '')))} 원',
                                              fontColor: ColorConfig().dark(),
                                              fontSize: 14.0.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ],
                                        ),
                                      ) : Container(),
                                      // 좌석정보 영역
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width,
                                          padding: const EdgeInsets.all(16.0),
                                          decoration: BoxDecoration(
                                            color: ColorConfig().primaryLight3(),
                                            border: Border.all(
                                              width: 1.0,
                                              color: ColorConfig().primary(),
                                            ),
                                            borderRadius: BorderRadius.circular(4.0.r),
                                          ),
                                          child: CustomTextBuilder(
                                            text: '${selectedSeat['rank']}석 ${selectedSeat['name']}',
                                            fontColor: ColorConfig().dark(),
                                            fontSize: 14.0.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(height: 8.0),
                                Container(
                                  color: ColorConfig().white(),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // 입찰가격 타이틀 영역
                                      Container(
                                        margin: const EdgeInsets.only(top: 8.0),
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                        child: CustomTextBuilder(
                                          text: TextConstant.joinAuctionPrice,
                                          fontColor: ColorConfig().dark(),
                                          fontSize: 14.0.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      // 기존 가격 영역
                                      priceRemainingStatus == true ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomTextBuilder(
                                              text: TextConstant.previousPrice,
                                              fontColor: ColorConfig().dark(),
                                              fontSize: 12.0.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            CustomTextBuilder(
                                              text: '${SetIntl().numberFormat(auctionHistoryData['price'])} 원',
                                              fontColor: ColorConfig().dark(),
                                              fontSize: 14.0.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ],
                                        ),
                                      ) : Container(),
                                      // 보유한 ig-public머니 영역
                                      Container(
                                        margin: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomTextBuilder(
                                              text: TextConstant.howHasig-publicMoney,
                                              fontColor: ColorConfig().dark(),
                                              fontSize: 12.0.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            CustomTextBuilder(
                                              text: '${ig-publicMoney != 0 ? SetIntl().numberFormat(ig-publicMoney) : 0} 원',
                                              fontColor: ColorConfig().dark(),
                                              fontSize: 14.0.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // 충전금액 입력 위젯                                                                                                                                                                                     
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 16.0),
                                        child: Column(
                                          children: [
                                            // 금액 입력 폼 영역
                                            TextFormField(
                                              controller: purchaseTextController,
                                              focusNode: purchaseFocusNode,
                                              keyboardType: TextInputType.number,
                                              onChanged: (value) {
                                                int num = int.parse(value.replaceAll(',', '').isEmpty ? '0': value.replaceAll(',', ''));
                                                // num = num < 1000 ? 1000 : num;
                                                purchaseTextController.text = SetIntl().numberFormat(num);
                                                purchaseTextController.selection = TextSelection.fromPosition(TextPosition(offset: purchaseTextController.text.length));
                                              },
                                              decoration: InputDecoration(
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 17.0),
                                                filled: true,
                                                fillColor: ColorConfig().gray1(),
                                                hintText: priceRemainingStatus == false ? TextConstant.minimumAuctionPrice : '${SetIntl().numberFormat(auctionHistoryData['price'])}',
                                                hintStyle: TextStyle(
                                                  color: ColorConfig().gray3(),
                                                  fontSize: 14.0.sp,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                                errorText: priceRemainingSeatCheckStatus == true && purchaseTextController.text.isNotEmpty && auctionHistoryData['price'] >= int.parse(purchaseTextController.text.replaceAll(',', '')) ? TextConstant.auctionInputErrorText : null,
                                                enabledBorder: const UnderlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                ),
                                                focusedBorder: const UnderlineInputBorder(
                                                  borderSide: BorderSide.none,
                                                ),
                                                prefixIcon: Container(
                                                  margin: const EdgeInsets.only(left: 20.0, right: 8.0, top: 16.0),
                                                  child: CustomTextBuilder(
                                                    text: TextConstant.joinAuctionPrice,
                                                    fontColor: ColorConfig().gray3(),
                                                    fontSize: 18.0.sp,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                suffixText: purchaseTextController.text.isNotEmpty ? '원' : '',
                                                suffixStyle: TextStyle(
                                                  color: ColorConfig().gray3(),
                                                  fontSize: 14.0.sp,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              textAlign: TextAlign.end,
                                              style: TextStyle(
                                                color: ColorConfig().dark(),
                                                fontSize: 14.0.sp,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            // 금액 버튼 영역
                                            Row(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    payCalculator(10000);
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                                    margin: const EdgeInsets.fromLTRB(0.0, 12.0, 8.0, 12.0),
                                                    decoration: BoxDecoration(
                                                      color: ColorConfig().white(),
                                                      border: Border.all(
                                                        width: 1.0,
                                                        color: ColorConfig().primaryLight2(),
                                                      ),
                                                      borderRadius: BorderRadius.circular(4.0.r),
                                                    ),
                                                    child: Center(
                                                      child: CustomTextBuilder(
                                                        text: '+ 1만원',
                                                        fontColor: ColorConfig().gray5(),
                                                        fontSize: 12.0.sp,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    payCalculator(30000);
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                                    margin: const EdgeInsets.fromLTRB(0.0, 12.0, 8.0, 12.0),
                                                    decoration: BoxDecoration(
                                                      color: ColorConfig().white(),
                                                      border: Border.all(
                                                        width: 1.0,
                                                        color: ColorConfig().primaryLight2(),
                                                      ),
                                                      borderRadius: BorderRadius.circular(4.0.r),
                                                    ),
                                                    child: Center(
                                                      child: CustomTextBuilder(
                                                        text: '+ 3만원',
                                                        fontColor: ColorConfig().gray5(),
                                                        fontSize: 12.0.sp,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    payCalculator(50000);
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                                    margin: const EdgeInsets.fromLTRB(0.0, 12.0, 8.0, 12.0),
                                                    decoration: BoxDecoration(
                                                      color: ColorConfig().white(),
                                                      border: Border.all(
                                                        width: 1.0,
                                                        color: ColorConfig().primaryLight2(),
                                                      ),
                                                      borderRadius: BorderRadius.circular(4.0.r),
                                                    ),
                                                    child: Center(
                                                      child: CustomTextBuilder(
                                                        text: '+ 5만원',
                                                        fontColor: ColorConfig().gray5(),
                                                        fontSize: 12.0.sp,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    payCalculator(100000);
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                                                    margin: const EdgeInsets.symmetric(vertical: 12.0),
                                                    decoration: BoxDecoration(
                                                      color: ColorConfig().white(),
                                                      border: Border.all(
                                                        width: 1.0,
                                                        color: ColorConfig().primaryLight2(),
                                                      ),
                                                      borderRadius: BorderRadius.circular(4.0.r),
                                                    ),
                                                    child: Center(
                                                      child: CustomTextBuilder(
                                                        text: '+ 10만원',
                                                        fontColor: ColorConfig().gray5(),
                                                        fontSize: 12.0.sp,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            // 참여자 리스트 버튼 영역
                                            InkWell(
                                              onTap: () {
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
                                                                text: ' ${bettingSeat['list'].length}',
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
                                                      children: List.generate(bettingSeat['list'].length, (joinedIndex) {
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
                                                                  image: bettingSeat['list'][joinedIndex]['image'] != null
                                                                    ? DecorationImage(
                                                                        image: NetworkImage(bettingSeat['list'][joinedIndex]['image']),
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
                                                                  image: bettingSeat['list'][joinedIndex]['rank'] == 7
                                                                    ? const AssetImage('assets/img/rank-m.png')
                                                                    : bettingSeat['list'][joinedIndex]['rank'] == 6
                                                                      ? const AssetImage('assets/img/rank-d.png')
                                                                      : bettingSeat['list'][joinedIndex]['rank'] == 5
                                                                        ? const AssetImage('assets/img/rank-pl.png')
                                                                        : bettingSeat['list'][joinedIndex]['rank'] == 4
                                                                          ? const AssetImage('assets/img/rank-r.png')
                                                                          : bettingSeat['list'][joinedIndex]['rank'] == 3
                                                                            ? const AssetImage('assets/img/rank-g.png')
                                                                            : bettingSeat['list'][joinedIndex]['rank'] == 2
                                                                              ? const AssetImage('assets/img/rank-s.png')
                                                                              : const AssetImage('assets/img/rank-w.png'),
                                                                  filterQuality: FilterQuality.high,
                                                                  width: 16.0.w,
                                                                  height: 16.0.w,
                                                                ),
                                                              ),
                                                              CustomTextBuilder(
                                                                text: '${bettingSeat['list'][joinedIndex]['nick']}',
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
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(8.0),
                                                margin: const EdgeInsets.only(bottom: 8.0),
                                                decoration: BoxDecoration(
                                                  color: ColorConfig().gray1(),
                                                  border: Border.all(
                                                    width: 1.0,
                                                    color: ColorConfig().gray2(),
                                                  ),
                                                  borderRadius: BorderRadius.circular(4.0.r),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          width: 1.0,
                                                          color: ColorConfig().primary(),
                                                        ),
                                                        borderRadius: BorderRadius.circular(50.0.r),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            margin: const EdgeInsets.only(right: 4.0),
                                                            child: SVGBuilder(
                                                              image: 'assets/icon/cast.svg',
                                                              width: 16.0.w,
                                                              height: 16.0.w,
                                                              color: ColorConfig().primary(),
                                                            ),
                                                          ),
                                                          CustomTextBuilder(
                                                            text: '${bettingSeat['list'].length}명 경매중',
                                                            fontColor: ColorConfig().primary(),
                                                            fontSize: 12.0.sp,
                                                            fontWeight: FontWeight.w700,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Container(
                                                          margin: const EdgeInsets.only(right: 8.0),
                                                          child: CustomTextBuilder(
                                                            text: TextConstant.checkAttendeesList,
                                                            fontColor: ColorConfig().dark(),
                                                            fontSize: 12.0.sp,
                                                            fontWeight: FontWeight.w700,
                                                          ),
                                                        ),
                                                        SVGBuilder(
                                                          image: 'assets/icon/arrow_right_bold.svg',
                                                          width: 16.0.w,
                                                          height: 16.0.w,
                                                          color: ColorConfig().dark(),
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
                                    ],
                                  ),
                                ),
                                Container(height: 8.0),
                                Container(
                                  color: ColorConfig().white(),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // 쿠폰 타이틀 영역
                                      Container(
                                        margin: const EdgeInsets.only(top: 8.0),
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                        child: CustomTextBuilder(
                                          text: TextConstant.usingCoupon,
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
                                              return couponBottomSheetWidget(couponData.result['data']);
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
                                                    text: TextConstant.pleaseSelectCoupon,
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
                                      // 쿠폰 데이터 영역
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
                                                      text: '잔여금액: ${SetIntl().numberFormat(selectedCouponList[index]['available_point'])}원',
                                                      fontColor: ColorConfig().accent(),
                                                      fontSize: 12.0.sp,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ],
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      couponTotalPrice -= int.parse(selectedCouponList[index]['available_point'].toString());
                                                      selectedCouponList.removeAt(index);
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
                                    ],
                                  ),
                                ),
                                priceRemainingSeatCheckStatus == false
                                  ? Container(height: 8.0)
                                  : priceRemainingStatus == false && purchaseTextController.text.isNotEmpty && int.parse(purchaseTextController.text.replaceAll(',', '')) > auctionHistoryData['price']
                                    ? Container(height: 8.0)
                                    : Container(),
                                // 결제정보 영역
                                priceRemainingSeatCheckStatus == true
                                  ? priceRemainingStatus == true && purchaseTextController.text.isNotEmpty && int.parse(purchaseTextController.text.replaceAll(',', '')) > auctionHistoryData['price']
                                    ? Container(
                                        color: ColorConfig().white(),
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                        child: Column(
                                          children: [
                                            // 입찰가격 영역
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  CustomTextBuilder(
                                                    text: priceRemainingStatus == false ? TextConstant.joinAuctionPrice : TextConstant.finalJoinedAuctionPrice,
                                                    fontColor: ColorConfig().dark(),
                                                    fontSize: 12.0.sp,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  CustomTextBuilder(
                                                    text: '${SetIntl().numberFormat(int.parse(purchaseTextController.text.replaceAll(',', '')))} 원',
                                                    fontColor: ColorConfig().dark(),
                                                    fontSize: 12.0.sp,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              children: [
                                                // 쿠폰사용 영역
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      CustomTextBuilder(
                                                        text: TextConstant.useCoupon,
                                                        fontColor: ColorConfig().dark(),
                                                        fontSize: 12.0.sp,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                      CustomTextBuilder(
                                                        text: '-${(int.parse(purchaseTextController.text.replaceAll(',', '')) - auctionHistoryData['price']) > couponTotalPrice ? SetIntl().numberFormat(couponTotalPrice) : SetIntl().numberFormat(int.parse(purchaseTextController.text.replaceAll(',', '')) - auctionHistoryData['price'])} 원',
                                                        fontColor: ColorConfig().dark(),
                                                        fontSize: 12.0.sp,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // 쿠폰사용 리스트 영역
                                                Column(
                                                  children: List.generate(selectedCouponList.length, (selectCouponIndex) {
                                                    return Padding(
                                                      padding: EdgeInsets.only(top: 8.0, bottom: selectCouponIndex != selectedCouponList.length - 1 ? 0.0 : 12.0),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          CustomTextBuilder(
                                                            text: '└${selectedCouponList[selectCouponIndex]['name']}',
                                                            fontColor: ColorConfig().gray3(),
                                                            fontSize: 11.0.sp,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                          CustomTextBuilder(
                                                            text: '-${(int.parse(purchaseTextController.text.replaceAll(',', '')) - auctionHistoryData['price']) > selectedCouponList[selectCouponIndex]['available_point'] ? SetIntl().numberFormat(selectedCouponList[selectCouponIndex]['available_point']) : SetIntl().numberFormat(int.parse(purchaseTextController.text.replaceAll(',', '')) - auctionHistoryData['price'])} 원',
                                                            fontColor: ColorConfig().gray3(),
                                                            fontSize: 11.0.sp,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }),
                                                ),
                                              ],
                                            ),
                                            // 기존 가격 영역
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  CustomTextBuilder(
                                                    text: TextConstant.previousPrice,
                                                    fontColor: ColorConfig().dark(),
                                                    fontSize: 12.0.sp,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  CustomTextBuilder(
                                                    text: '-${SetIntl().numberFormat(auctionHistoryData['price'])} 원',
                                                    fontColor: ColorConfig().dark(),
                                                    fontSize: 12.0.sp,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // 총 결제금액 영역
                                            Padding(
                                              padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  CustomTextBuilder(
                                                    text: TextConstant.totalPurchasePrice,
                                                    fontColor: ColorConfig().dark(),
                                                    fontSize: 14.0.sp,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  CustomTextBuilder(
                                                    text: '${SetIntl().numberFormat((int.parse(purchaseTextController.text.replaceAll(',', '')) - auctionHistoryData['price']) > couponTotalPrice ? int.parse(purchaseTextController.text.replaceAll(',', '')) - couponTotalPrice - auctionHistoryData['price'] : 0)} 원',
                                                    fontColor: ColorConfig().dark(),
                                                    fontSize: 14.0.sp,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container()
                                  : Container(
                                      color: ColorConfig().white(),
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                      child: Column(
                                        children: [
                                          // 입찰가격 영역
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                CustomTextBuilder(
                                                  text: priceRemainingStatus == false ? TextConstant.joinAuctionPrice : TextConstant.finalJoinedAuctionPrice,
                                                  fontColor: ColorConfig().dark(),
                                                  fontSize: 12.0.sp,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                CustomTextBuilder(
                                                  text: '${SetIntl().numberFormat(int.parse(purchaseTextController.text.replaceAll(',', '')))} 원',
                                                  fontColor: ColorConfig().dark(),
                                                  fontSize: 12.0.sp,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              // 쿠폰사용 영역
                                              Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    CustomTextBuilder(
                                                      text: TextConstant.useCoupon,
                                                      fontColor: ColorConfig().dark(),
                                                      fontSize: 12.0.sp,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                    CustomTextBuilder(
                                                      text: '-${int.parse(purchaseTextController.text.replaceAll(',', '')) > couponTotalPrice ? SetIntl().numberFormat(couponTotalPrice) : SetIntl().numberFormat(int.parse(purchaseTextController.text.replaceAll(',', '')))} 원',
                                                      fontColor: ColorConfig().dark(),
                                                      fontSize: 12.0.sp,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // 쿠폰사용 리스트 영역
                                              Column(
                                                children: List.generate(selectedCouponList.length, (selectCouponIndex) {
                                                  return Padding(
                                                    padding: EdgeInsets.only(top: 8.0, bottom: selectCouponIndex != selectedCouponList.length - 1 ? 0.0 : 12.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        CustomTextBuilder(
                                                          text: '└${selectedCouponList[selectCouponIndex]['name']}',
                                                          fontColor: ColorConfig().gray3(),
                                                          fontSize: 11.0.sp,
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                        CustomTextBuilder(
                                                          text: '-${int.parse(purchaseTextController.text.replaceAll(',', '')) > selectedCouponList[selectCouponIndex]['available_point'] ? SetIntl().numberFormat(selectedCouponList[selectCouponIndex]['available_point']) : SetIntl().numberFormat(int.parse(purchaseTextController.text.replaceAll(',', '')))} 원',
                                                          fontColor: ColorConfig().gray3(),
                                                          fontSize: 11.0.sp,
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                              ),
                                            ],
                                          ),
                                          // 총 결제금액 영역
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                CustomTextBuilder(
                                                  text: TextConstant.totalPurchasePrice,
                                                  fontColor: ColorConfig().dark(),
                                                  fontSize: 14.0.sp,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                CustomTextBuilder(
                                                  text: '${SetIntl().numberFormat(int.parse(purchaseTextController.text.replaceAll(',', '')) > couponTotalPrice ? int.parse(purchaseTextController.text.replaceAll(',', '')) - couponTotalPrice - (priceRemainingSeatCheckStatus == true ? auctionHistoryData['price'] : 0) : 0)} 원',
                                                  fontColor: ColorConfig().dark(),
                                                  fontSize: 14.0.sp,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                Container(height: 8.0),
                                Container(
                                  color: ColorConfig().white(),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // 주의사항 타이틀 영역
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                        margin: const EdgeInsets.only(top: 8.0),
                                        child: CustomTextBuilder(
                                          text: TextConstant.auctionGuide,
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
                                          children: List.generate(TextConstant.auctionCaution.length, (index) {
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
                                                      text: TextConstant.auctionCaution[index],
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
                                    ],
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
                        onTap: selectedSeat.isNotEmpty
                          ? isSwipeUp != true
                            ? () async {
                                AuctionBettingAPI().bettingSeat(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), seatData: selectedSeat).then((value) {
                                  setState(() {
                                    bettingSeat = value.result['data'];
                                  });
                                });

                                setState(() {
                                  if (priceRemainingSeatCheckStatus == false) {
                                    isSwipeUp = true;
                                  }
                                  purchaseTextController.text = '1000';

                                  for (int i=0; i<myJoinedAuctionSeatList.length; i++) {
                                    if (myJoinedAuctionSeatList[i]['name'] == selectedSeat['name'] && myJoinedAuctionSeatList[i]['x'] == selectedSeat['x'] && myJoinedAuctionSeatList[i]['y'] == selectedSeat['y']) {
                                      priceRemainingStatus = true;
                                      purchaseTextController.clear();
                                    }
                                  }
                                });

                                if (priceRemainingStatus == true) {
                                  AuctionHistoryAPI().auctionHistory(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((myauctions) {
                                    setState(() {
                                      for (int i=0; i<myauctions.result['data'].length; i++) {
                                        if (myauctions.result['data'][i]['seat_name'] == selectedSeat['name'] && myauctions.result['data'][i]['x'] == selectedSeat['x'] && myauctions.result['data'][i]['y'] == selectedSeat['y']) {
                                          auctionHistoryData = myauctions.result['data'][i];
                                          isSwipeUp = true;
                                        }
                                      }
                                    });
                                  });
                                }
                              }
                            : () async {
                              if (purchaseTextController.text.isNotEmpty) {
                                if (int.parse(purchaseTextController.text.replaceAll(',', '')) > 0) {
                                  if (int.parse(purchaseTextController.text.replaceAll(',', '')) < 1000) {
                                    PopupBuilder(
                                      title: TextConstant.auctionMinimunPricePopupTitle,
                                      content: TextConstant.auctionMinimunPricePopupContent,
                                      actions: [
                                        InkWell(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            color: ColorConfig().dark(),
                                            padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                                  } else if (int.parse(purchaseTextController.text.replaceAll(',', '')) > ig-publicMoney) {
                                    Navigator.pushNamed(context, 'ig-publicMoneyPurchase');
                                  } else {
                                    if(int.parse(purchaseTextController.text.replaceAll(',', '')) % 1000 == 0) {
                                      // if (int.parse(purchaseTextController.text.replaceAll(',', '')) > auctionHistoryData['price']) {
                                        PopupBuilder(
                                          title: '${SetIntl().numberFormat(int.parse(purchaseTextController.text.replaceAll(',', '')))}${TextConstant.auctionBettingTitlePopup}',
                                          content: TextConstant.auctionBettingDescriptionPopup,
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
                                                    dynamic localSelectedSeat = selectedSeat;
                                                    localSelectedSeat['price'] = purchaseTextController.text.replaceAll(',', '');
                                                    
                                                    if (selectedCouponList.isNotEmpty) {
                                                      localSelectedSeat['coupon'] = selectedCouponList;
                                                    }
                                                    
                                                    AuctionBettingApplyAPI().betting(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), seatData: localSelectedSeat).then((value) {
                                                      Navigator.pop(context);
                                                      
                                                      // 성공
                                                      if (value.result['status'] == 1) {
                                                        PopupBuilder(
                                                          title: priceRemainingStatus == false ? TextConstant.auctionJoinSuccess : TextConstant.auctionRaisePriceCompleteTitle,
                                                          content: priceRemainingStatus == false ? TextConstant.auctionJoinSuccessContent : TextConstant.auctionRaisePriceCompleteContent,
                                                          actions: [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                InkWell(
                                                                  onTap: () async {
                                                                    Navigator.pop(context);
                                                                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainBuilder(crnIndex: 2)), (route) => false);
                                                                    Navigator.pushNamed(context, 'ticketHistory', arguments: {
                                                                      "tabIndex": 1,
                                                                    });
                                                                  },
                                                                  splashColor: ColorConfig.transparent,
                                                                  child: Container(
                                                                    width: (MediaQuery.of(context).size.width - 120.0.w) / 2,
                                                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                                                                        text: TextConstant.viewAuctionHistory,
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
                                                                    
                                                                    AuctionBettingAPI().getBettingSeat(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), showDetailIndex: widget.showDetailIndex).then((joinSeat) {
                                                                      setState(() {
                                                                        myJoinedAuctionSeatList = joinSeat.result['data'];
                                                                        isSwipeUp = false;
                                                                        purchaseTextController.text = '';
                                                                        selectedCouponList.clear();
                                                                        couponTotalPrice = 0;
                                                                        selectedSeat = {};
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
                                                                        text: TextConstant.continueToJoin,
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
                                                      // 해당 티켓이 없음
                                                      else if (value.result['status'] == 0) {
                                                        ToastModel().iconToast(value.result['message'], iconType: 2);
                                                      }
                                                      // json 파라미터 에러
                                                      else if (value.result['status'] == -1) {
                                                        ToastModel().iconToast(value.result['message'], iconType: 2);
                                                      }
                                                      // 최고 금액 부족
                                                      else if (value.result['status'] == -2) {
                                                        ToastModel().iconToast(value.result['message'], iconType: 2);
                                                      }
                                                      // 경매 티켓 아님
                                                      else if (value.result['status'] == -3) {
                                                        ToastModel().iconToast(value.result['message'], iconType: 2);
                                                      }
                                                      // ig-public 머니 부족
                                                      else if (value.result['status'] == -4) {
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
                                                        text: TextConstant.auction,
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
                                      // }
                                    } else {
                                      PopupBuilder(
                                        title: TextConstant.auctionMinimunPricePopupTitle,
                                        content: TextConstant.auctionMinimunPricePopupContent,
                                        actions: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: Container(
                                              color: ColorConfig().dark(),
                                              padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                                    }
                                  }
                                } else {
                                  purchaseTextController.clear();
                                }
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
                            color: selectedSeat.isNotEmpty
                              ? priceRemainingStatus == false
                                ? purchaseTextController.text.isNotEmpty && int.parse(purchaseTextController.text.replaceAll(',', '')) > ig-publicMoney
                                  ? ColorConfig().accent()
                                  : priceRemainingSeatCheckStatus == false
                                    ? ColorConfig().primary()
                                    : ColorConfig().dark()
                                : purchaseTextController.text.isNotEmpty && int.parse(purchaseTextController.text.replaceAll(',', '')) > ig-publicMoney
                                  ? ColorConfig().accent()
                                  : purchaseTextController.text.isNotEmpty && int.parse(purchaseTextController.text.replaceAll(',', '')) > auctionHistoryData['price']
                                    ? ColorConfig().primary()
                                    : ColorConfig().gray2()
                              : ColorConfig().gray2(),
                            borderRadius: BorderRadius.circular(4.0.r),
                          ),
                          child: isSwipeUp != true
                            ? Center(
                              child: CustomTextBuilder(
                                text: selectedSeat.isNotEmpty
                                  ? priceRemainingSeatCheckStatus == false
                                    ? TextConstant.doJoinedAuction
                                    : TextConstant.raiseAuctionPrice1
                                  : TextConstant.selectSeatPlease,
                                fontColor: selectedSeat.isNotEmpty ? ColorConfig().white() : ColorConfig().gray3(),
                                fontSize: 16.0.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomTextBuilder(
                                  text: '${selectedSeat['name']}',
                                  fontColor: ColorConfig().white(),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                                CustomTextBuilder(
                                  text: purchaseTextController.text.isNotEmpty && int.parse(purchaseTextController.text.replaceAll(',', '')) > ig-publicMoney
                                    ? TextConstant.fillig-publicMoneyAfterJoinAuction
                                    : priceRemainingStatus == false ? TextConstant.doJoinedAuction : TextConstant.raiseAuctionPrice1,
                                  fontColor: ColorConfig().white(),
                                  fontSize: 14.0.sp,
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
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                color: ColorConfig().primaryLight(),
                borderRadius: BorderRadius.circular(4.0.r),
              ),
            ),
            CustomTextBuilder(
              text: TextConstant.ableSelectSeatShort,
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
              text: TextConstant.unableSelectSeatShort,
              fontColor: ColorConfig().gray4(),
              fontSize: 12.0.sp,
              fontWeight: FontWeight.w400,
            ),
            Container(
              width: 15.0.w,
              height: 15.0.w,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                color: ColorConfig().accent(),
                borderRadius: BorderRadius.circular(4.0.r),
              ),
            ),
            CustomTextBuilder(
              text: TextConstant.alreadyJoinedSeat,
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
            onPressed: () {},
            icon: Container(),
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

    return Column(
      key: seatAllKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: returnListRow_,
    );
  }
  
  // 각각의 좌석 데이터 위젯
  Widget seatsWidget(int ia) {
    return Container(
      width: 30.0.w,
      height: 30.0.w,
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: selectedSeat['name'] == widget.seat['seat'][selectFloorList.indexOf(true)]['seats'][ia]['name']
          ? ColorConfig().primary()
          : myJoinedAuctionSeatList.indexWhere((el) => el['name'] == widget.seat['seat'][selectFloorList.indexOf(true)]['seats'][ia]['name']) > -1
            ? ColorConfig().accent()
            : catalogdata[selectFloorList.indexOf(true)]['seats'][ia]['status'] == 0
              ? ColorConfig.transparent
              : catalogdata[selectFloorList.indexOf(true)]['seats'][ia]['status'] == 1
                ? ColorConfig().primaryLight3(opacity: 0.5)
                : catalogdata[selectFloorList.indexOf(true)]['seats'][ia]['status'] == 2
                  ? ColorConfig().primaryLight()
                  : ColorConfig().primaryLight3(opacity: 0.5),
        borderRadius: BorderRadius.circular(4.0.r),
      ),
      child: catalogdata.isNotEmpty &&catalogdata[selectFloorList.indexOf(true)]['seats'][ia]['status'] == 2
        ? TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
            onPressed: () async {
              int selectFloor = selectFloorList.indexOf(true) + 1;
              dynamic lseat = widget.seat['seat'][selectFloor - 1]['seats'][ia];
              lseat['floor'] = selectFloor;

              for (int i=0; i<widget.seat['seats'].length; i++) {
                if (lseat['rank'] == widget.seat['seats'][i]['seat_name']) {
                  lseat['seat_index'] = widget.seat['seats'][i]['seat_index'];
                  lseat['price'] = widget.seat['seats'][i]['price'];
                  lseat['discount'] = widget.seat['seats'][i]['discount'];
                  lseat['participant_count'] = widget.seat['seats'][i]['participant_count'];
                }
              }

              setState(() {
                if (myJoinedAuctionSeatList.indexWhere((el) => el['name'] == widget.seat['seat'][selectFloorList.indexOf(true)]['seats'][ia]['name']) > -1) {
                  priceRemainingSeatCheckStatus = true;
                } else {
                  priceRemainingSeatCheckStatus = false;
                }

                selectedSeat = lseat;
                originPrice = selectedSeat['price'];
              });

              AuctionBettingAPI().bettingSeat(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), seatData: selectedSeat).then((value) {
                setState(() {
                  bettingSeat = value.result['data'];
                });
              });
            },
            child: Container(),
          )
        : Container(),
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

                                    bool avaliableCouponStatus = (couponData[index - 1]['show_content_index'] == 0 || widget.showContentIndex == couponData[index - 1]['show_content_index'])&& 
                                                                 (couponData[index - 1]['show_content_ticket_index'] == 0 || widget.showDetailIndex == couponData[index - 1]['show_content_ticket_index']) &&
                                                                 (couponData[index - 1]['show_content_ticket_seat_index'] == 0 || selectedSeat['seat_index'] == couponData[index - 1]['show_content_ticket_seat_index'])
                                      ? true : false;

                                    return InkWell(
                                      onTap: avaliableCouponStatus == true && couponData[index - 1]['type'] == 1 && selectedCouponList.indexWhere((e) => e['coupon_index'] == couponData[index - 1]['coupon_index']) == -1 ? () {
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
                                        couponTotalPrice += int.parse(selectCouponData['available_point'].toString());
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