import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/costant/enumerated.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/util/set_intl.dart';
import 'package:ig-public_v3/api/ticket/check_seat_list.dart';
import 'package:ig-public_v3/api/auction/auction_betting_seat.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';

// ignore: must_be_immutable
class SeatViewScreen extends StatefulWidget {
  SeatViewScreen({
    super.key,
    this.seat,
    required this.showDetailIndex,
    this.dataType = ShowDataType.ticket,
  });

  dynamic seat;
  int showDetailIndex;
  ShowDataType dataType;

  @override
  State<SeatViewScreen> createState() => _SeatViewScreenState();
}

class _SeatViewScreenState extends State<SeatViewScreen> with TickerProviderStateMixin {
  final TransformationController transformationController = TransformationController();
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  late List catalogdata;

  GlobalKey positionKey = GlobalKey();
  GlobalKey seatAllKey = GlobalKey();

  List<bool> selectFloorList = [];
  List checkSeatListData = [];

  Map<String, dynamic> selectedSeat = {};
  Map<String, dynamic> bettingSeat = {};

  int pointersCount = 0;

  double scalePadding = 40.0;

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
  }

  @override
  void dispose() {
    super.dispose();
    
    _verticalController.dispose();
    _horizontalController.dispose();
    transformationController.dispose();
  }

  Future<String> loadData() async {
    dynamic data = widget.seat['seat'];
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
    if (widget.dataType == ShowDataType.ticket) {
      CheckSeatListAPI().checkList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), showContentTicketIndex: widget.showDetailIndex).then((value) {
        setState(() {
          checkSeatListData = value.result['data'];
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ig-publicAppBar(
        leading: ig-publicAppBarLeading(
          press: () {},
          using: false,
        ),
        title: const ig-publicAppBarTitle(
          title: TextConstant.showSeatStatus,
        ),
        actions: [
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
        ],
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
                  height: (12.0 + 24.0.w) + (widget.dataType == ShowDataType.ticket
                    ? ((8.0 + 14.0.sp) * widget.seat['seats'].length) + MediaQuery.of(context).viewPadding.bottom + 10.0
                    : 32.0 + 8.0 + 14.0.sp + 14.0.sp + MediaQuery.of(context).viewPadding.bottom),
                ),
              ],
            ),
            // 잔여 좌석 등급 영역
            Positioned(
              bottom: 0.0,
              child: viewSeatBottomSheet(),
            ),
          ],
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
          widget.dataType == ShowDataType.ticket ? IconButton(
            onPressed: () async {
              CheckSeatListAPI().checkList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), showContentTicketIndex: widget.showDetailIndex).then((value) {
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
          ) : IconButton(
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
        color: widget.dataType == ShowDataType.ticket
          ? catalogdata[selectFloorList.indexOf(true)]['seats'][ia]['status'] == 0
            ? ColorConfig.transparent
            : catalogdata[selectFloorList.indexOf(true)]['seats'][ia]['status'] == 1 || (checkSeatListData.isNotEmpty && checkSeatListData.firstWhere((e) => e['name'] == catalogdata[selectFloorList.indexOf(true)]['seats'][ia]['name'], orElse: () => null)['status'] == true && checkSeatListData.contains(checkSeatListData.firstWhere((e) => e['name'] == catalogdata[selectFloorList.indexOf(true)]['seats'][ia]['name'], orElse: () => null)))
              ? ColorConfig().primaryLight3(opacity: 0.5)
              : catalogdata[selectFloorList.indexOf(true)]['seats'][ia]['status'] == 2 && (checkSeatListData.isNotEmpty && checkSeatListData.firstWhere((e) => e['name'] == catalogdata[selectFloorList.indexOf(true)]['seats'][ia]['name'], orElse: () => null)['status'] == true && checkSeatListData.contains(checkSeatListData.firstWhere((e) => e['name'] == catalogdata[selectFloorList.indexOf(true)]['seats'][ia]['name'], orElse: () => null))) == false
                ? ColorConfig().primaryLight()
                : ColorConfig().primaryLight3(opacity: 0.5)
          : selectedSeat['name'] == widget.seat['seat'][selectFloorList.indexOf(true)]['seats'][ia]['name']
            ? ColorConfig().primary()
            : catalogdata[selectFloorList.indexOf(true)]['seats'][ia]['status'] == 0
              ? ColorConfig.transparent
              : catalogdata[selectFloorList.indexOf(true)]['seats'][ia]['status'] == 1
                ? ColorConfig().primaryLight3(opacity: 0.5)
                : catalogdata[selectFloorList.indexOf(true)]['seats'][ia]['status'] == 2
                  ? ColorConfig().primaryLight()
                  : ColorConfig().primaryLight3(opacity: 0.5),
        borderRadius: BorderRadius.circular(4.0.r),
      ),
      child: widget.dataType == ShowDataType.auction && catalogdata.isNotEmpty && catalogdata[selectFloorList.indexOf(true)]['seats'][ia]['status'] == 2
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
                }
              }

              setState(() {
                selectedSeat = lseat;
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

  // 좌석 등급 잔여좌석 위젯
  Widget viewSeatBottomSheet() {
    if (widget.dataType == ShowDataType.auction) {
      return Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: ColorConfig().white(),
        ),
        child: SafeArea(
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
                      fontWeight: FontWeight.w800,
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
                      text: TextConstant.selectWantSeat,
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
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 8.0),
          decoration: BoxDecoration(
            color: ColorConfig().white(),
          ),
          child: SafeArea(
            child: Column(
              children: List.generate(widget.seat['seats'].length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 4.0),
                            child: CustomTextBuilder(
                              text: '${widget.seat['seats'][index]['seat_name']}석',
                              fontColor: ColorConfig().dark(),
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          CustomTextBuilder(
                            text: '${widget.seat['seats'][index]['ticket_total'] - int.parse(widget.seat['seats'][index]['sell_ticket_count'])}장 남음',
                            fontColor: ColorConfig().primary(),
                            fontSize: 12.0.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ],
                      ),
                      widget.dataType == ShowDataType.ticket ? CustomTextBuilder(
                        text: '${SetIntl().numberFormat(widget.seat['seats'][index]['discount'])}원',
                        fontColor: ColorConfig().gray3(),
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w700,
                      ) : Container(),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}