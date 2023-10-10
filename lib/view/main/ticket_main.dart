import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ig-public_v3/api/auction/auction_list.dart';
import 'package:ig-public_v3/api/main/main_myprofile.dart';
import 'package:ig-public_v3/component/channel_talk/channel_talk.dart';
import 'package:ig-public_v3/component/date_calculator/date_calculator.dart';
import 'package:ig-public_v3/costant/enumerated.dart';
import 'package:ig-public_v3/main.dart';
import 'package:ig-public_v3/util/set_intl.dart';
import 'package:ig-public_v3/widget/loading_progress.dart';

import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/costant/svg_color.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/api/main/main_ticket.dart';
import 'package:ig-public_v3/api/ticket/ticket_list.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:ig-public_v3/view/ticketing/component/select_date.dart';

class MainTicketingScreen extends StatefulWidget {
  const MainTicketingScreen({super.key});

  @override
  State<MainTicketingScreen> createState() => _MainTicketingScreenState();
}

class _MainTicketingScreenState extends State<MainTicketingScreen> {
  late PageController _controller;
  late ScrollController listController;

  List mainTicketData = [];
  List mainNotificationData = [];
  List hasNoTicketData = [];
  
  bool processStatus = false;
  bool buildLoadStatus = false;
  bool loadingProgress = true;

  String bgImgData = '';

  @override
  void initState() {
    super.initState();

    _controller = PageController();
    listController = ScrollController();

    initializeAPI();

   WidgetsBinding.instance.addPostFrameCallback((_) {
    setState(() {
      buildLoadStatus = true;
    });
   }); 
  }
  
  Future<void> initializeAPI() async {
    MainTicketListAPI().ticket(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
      setState(() {
        if (value.result['data']['process'] == true) {
          mainTicketData = value.result['data']['list'];
          mainNotificationData = value.result['data']['notification'];
          processStatus = true;
        } else {
          hasNoTicketData = value.result['data']['list'];
          processStatus = false;
        }

        loadingProgress = false;
      });
    });
  }
  
  void changeBackgroundImgFunc(String img) {
    if (mounted) {
      Future.delayed(Duration.zero, () {
        if (img != bgImgData) {
          setState(() {
            if (img == null) {
              bgImgData = 'null';
            } else {
              bgImgData = img;
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: loadingProgress == false ? SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              // background image
              Positioned.fill(
                child: ClipRect(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgImgData != '' || bgImgData != 'null' ? ColorConfig().gray5() : null,
                      image: bgImgData != '' || bgImgData != 'null' ? DecorationImage(
                        image: NetworkImage(bgImgData),
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ) : null,
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        color: ColorConfig.defaultBlack.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                physics: processStatus == false ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SizedBox(height: const ig-publicAppBar().preferredSize.height + MediaQuery.of(context).padding.top),
                    ig-publicAppBar(
                      backgroundColor: ColorConfig.transparent,
                      leading: ig-publicAppBarLeading(
                        press: () {},
                        icon: Container(
                          margin: const EdgeInsets.only(left: 10.0),
                          child: SVGStringBuilder(
                            image: 'assets/img/logo-white.svg',
                          ),
                        ),
                      ),
                      leadingWidth: 100.0,
                      actions: [
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, 'searchHome');
                          },
                          icon: SVGBuilder(
                            image: 'assets/icon/search.svg',
                            color: ColorConfig().white(),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Scaffold.of(context).openEndDrawer();
                          },
                          icon: SVGBuilder(
                            image: 'assets/icon/sidemenu.svg',
                            color: ColorConfig().white(),
                          ),
                        ),
                      ],
                    ),

                    processStatus == true ? SizedBox(
                      height: MediaQuery.of(context).size.height - (const ig-publicAppBar().preferredSize.height + MediaQuery.of(context).padding.top + 90),
                      child: RefreshIndicator(
                        backgroundColor: ColorConfig.transparent,
                        onRefresh: () async {
                          MainTicketListAPI().ticket(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
                            setState(() {
                              if (value.result['data']['process'] == true) {
                                mainTicketData = value.result['data']['list'];
                                mainNotificationData = value.result['data']['notification'];
                                processStatus = true;
                              } else {
                                hasNoTicketData = value.result['data']['list'];
                                processStatus = false;
                              }
                            });
                          });
                        },
                        child: ListView.builder(
                          controller: listController,
                          itemCount: mainTicketData.length,
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemBuilder: (context, index) {
                            List discountPercentData = [];
                            List toSetSeatNames = [];
                                          
                            for (int i=0; i<mainTicketData[index]['seat'].length; i++) {
                              if (mainTicketData[index]['seat'][i]['type'] == 'T') {
                                discountPercentData.add((mainTicketData[index]['seat'][i]['price'] - mainTicketData[index]['seat'][i]['discount']) / mainTicketData[index]['seat'][i]['price'] * 100);
                              }
                            }
                            discountPercentData.sort((a, b) => b.compareTo(a));
                                          
                            for (int i=0; i<mainTicketData[index]['seat'].length; i++) {
                              if (!toSetSeatNames.contains(mainTicketData[index]['seat'][i]['seat_name'])) {
                                toSetSeatNames.add(mainTicketData[index]['seat'][i]['seat_name']);
                              }
                            }
                            if (buildLoadStatus == true) {
                              changeBackgroundImgFunc(mainTicketData[index]['image']);
                            }
                                    
                            if (index == 0) {
                              return SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 알려드려요 텍스트
                                    processStatus == true && mainNotificationData.isNotEmpty ? Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 20.0),
                                      child: CustomTextBuilder(
                                        text: '알려드려요',
                                        fontColor: ColorConfig.defaultWhite,
                                        fontSize: 16.0.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ) : Container(),
                                    // 좌석선택 안내 리스트
                                    processStatus == true && mainNotificationData.isNotEmpty ? SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height: 118.0.w,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        children: List.generate(mainNotificationData.length, (index) {
                                          return InkWell(
                                            onTap: () async {
                                              if (mainNotificationData[index]['type'] == 'A') {
                                                Navigator.pushNamed(context, 'ticketHistory', arguments: {
                                                  "tabIndex": 1,
                                                });
                                              } else {
                                                Navigator.pushNamed(context, 'ticketHistory', arguments: {
                                                  "tabIndex": null,
                                                });
                                              }
                                            },
                                            child: Container(
                                              width: 280.0.w,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF121016).withOpacity(0.7),
                                                borderRadius: BorderRadius.circular(4.0.r),
                                              ),
                                              padding: const EdgeInsets.all(16.0),
                                              margin: EdgeInsets.only(left: index == 0 ? 16.0 : 0.0, right: index != 4 ? 8.0 : 16.0),
                                              child: Row(
                                                children: [
                                                  // poster
                                                  Container(
                                                    width: 60.0.w,
                                                    height: 86.0.w,
                                                    decoration: BoxDecoration(
                                                      color: mainNotificationData[index]['image'] == null ? ColorConfig().gray2() : null,
                                                      borderRadius: BorderRadius.circular(4.0.r),
                                                      image: mainNotificationData[index]['image'] != null ? DecorationImage(
                                                        image: NetworkImage(mainNotificationData[index]['image']),
                                                        fit: BoxFit.cover,
                                                        filterQuality: FilterQuality.high,
                                                      ) : null,
                                                    ),
                                                    child: mainNotificationData[index]['image'] == null ? Center(
                                                      child: SVGBuilder(
                                                        image: 'assets/icon/album.svg',
                                                        width: 24.0.w,
                                                        height: 24.0.w,
                                                        color: ColorConfig().white(),
                                                      ),
                                                    ) : Container(),
                                                  ),
                                                  // text
                                                  Expanded(
                                                    child: Container(
                                                      height: 86.0.w,
                                                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          // 티켓 타입 텍스트
                                                          Row(
                                                            children: [
                                                              // 티켓 타입 이미지
                                                              Container(
                                                                width: 29.0.w,
                                                                height: 16.0.w,
                                                                margin: const EdgeInsets.only(right: 4.0),
                                                                child: mainNotificationData[index]['type'] == 'A'
                                                                ? SVGStringBuilder(
                                                                    image: 'assets/icon/auction-label.svg',
                                                                  )
                                                                : SVGStringBuilder(
                                                                    image: 'assets/icon/ticket-label.svg'
                                                                  ),
                                                              ),
                                                              CustomTextBuilder(
                                                                text: mainNotificationData[index]['type'] == 'A' ? TextConstant.checkPleaseAuctionPrice : TextConstant.checkPleaseTicket,
                                                                fontColor: mainNotificationData[index]['type'] == 'A' ? ColorConfig().accent() : ColorConfig().white(),
                                                                fontSize: 12.0.sp,
                                                                fontWeight: FontWeight.w700,
                                                              ),
                                                            ],
                                                          ),
                                                          // 제목
                                                          Container(
                                                            margin: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                                                            child: CustomTextBuilder(
                                                              text: '${mainNotificationData[index]['name']}',
                                                              fontColor: ColorConfig.defaultWhite,
                                                              fontSize: 16.0.sp,
                                                              fontWeight: FontWeight.w800,
                                                              maxLines: 2,
                                                              textOverflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                          // 종료날짜
                                                          CustomTextBuilder(
                                                            text: DateCalculatorWrapper().endTimeCalculator(mainNotificationData[index]['date']),
                                                            fontColor: ColorConfig.defaultWhite,
                                                            fontSize: 12.0.sp,
                                                            fontWeight: FontWeight.w700,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  // 화살표 아이콘
                                                  SVGBuilder(
                                                    image: 'assets/icon/arrow_right_light.svg',
                                                    width: 16.0.w,
                                                    height: 16.0.w,
                                                    color: ColorConfig().white(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ) : Container(),
                                    // ig-public에서 볼 수 있는 공연 or ig-public에서 현재까지 진행한 공연 텍스트 영역
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(4.0, 24.0, 4.0, processStatus == true ? 20.0 : 28.0),
                                      child: CustomTextBuilder(
                                        text: processStatus == true ? TextConstant.ableToSeeShowFromig-public : TextConstant.pastToNowShowFromig-public,
                                        fontColor: ColorConfig.defaultWhite,
                                        fontSize: 16.0.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        color: ColorConfig().mainPosterBackground(opacity: 0.7),
                                        borderRadius: BorderRadius.circular(6.0.r),
                                      ),
                                      margin: const EdgeInsets.only(bottom: 8.0),
                                      child: Column(
                                        children: [
                                          // 공연정보
                                          Container(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Row(
                                              children: [
                                                // 포스터
                                                Container(
                                                  width: 120.0.w,
                                                  height: 172.0.w,
                                                  margin: const EdgeInsets.only(right: 16.0),
                                                  decoration: BoxDecoration(
                                                    color: mainTicketData[index]['image'] == null ? ColorConfig().gray2() : null,
                                                    borderRadius: BorderRadius.circular(4.0.r),
                                                    image: mainTicketData[index]['image'] != null
                                                      ? DecorationImage(
                                                          image: NetworkImage(mainTicketData[index]['image']),
                                                          fit: BoxFit.cover,
                                                          filterQuality: FilterQuality.high,
                                                        )
                                                      : null,
                                                  ),
                                                  child: mainTicketData[index]['image'] == null ? Center(
                                                    child: SVGBuilder(
                                                      image: 'assets/icon/album.svg',
                                                      width: 22.0.w,
                                                      height: 22.0.w,
                                                      color: ColorConfig().white(),
                                                    ),
                                                  ) : Container(),
                                                ),
                                                // 텍스트
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      // ig-public 단독 표시
                                                      mainTicketData[index]['is_only'] == 1 ? SVGStringBuilder(image: 'assets/img/ig-public-only.svg') : Container(),
                                                      // 예매가능 좌석 표시
                                                      Wrap(
                                                        children: List.generate(toSetSeatNames.length, (seats) {
                                                          return Container(
                                                            decoration: BoxDecoration(
                                                              color: ColorConfig().gray5(),
                                                              borderRadius: BorderRadius.circular(1.0.r),
                                                            ),
                                                            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
                                                            margin: mainTicketData[index]['seat'].length - 1 != seats ? const EdgeInsets.only(right: 2.0, top: 4.0) : const EdgeInsets.only(top: 4.0),
                                                            child: CustomTextBuilder(
                                                              text: '${toSetSeatNames[seats]}석',
                                                              fontColor: ColorConfig.defaultWhite,
                                                              fontSize: 12.0.sp,
                                                              fontWeight: FontWeight.w900,
                                                              height: 0.0,
                                                            ),
                                                          );
                                                        }),
                                                      ),
                                                      // 공연 제목
                                                      Container(
                                                        width: MediaQuery.of(context).size.width,
                                                        margin: const EdgeInsets.only(top: 16.0, bottom: 4.0),
                                                        child: CustomTextBuilder(
                                                          text: '${mainTicketData[index]['name']}',
                                                          fontColor: ColorConfig.defaultWhite,
                                                          fontSize: 16.0.sp,
                                                          fontWeight: FontWeight.w800,
                                                        ),
                                                      ),
                                                      // 공연기간
                                                      mainTicketData[index]['view_start_date'] != null || mainTicketData[index]['view_end_date'] != null ? CustomTextBuilder(
                                                        text: '${DateFormat('yyyy.M.d.').format(DateTime.parse(mainTicketData[index]['view_start_date']).toLocal())} - ${DateFormat('yyyy.M.d.').format(DateTime.parse(mainTicketData[index]['view_end_date']).toLocal())}',
                                                        fontColor: ColorConfig().gray3(),
                                                        fontSize: 12.0.sp,
                                                        fontWeight: FontWeight.w700,
                                                      ) : Container(),
                                                      // 최대 할인율
                                                      mainTicketData[index]['is_sell_ticket'] != 0 ? Container(
                                                        margin: const EdgeInsets.only(top: 16.0),
                                                        child: Row(
                                                          children: [
                                                            // 아이콘
                                                            Container(
                                                              margin: const EdgeInsets.only(right: 4.0),
                                                              child: SVGBuilder(
                                                                image: 'assets/icon/discount.svg',
                                                                width: 16.0.w,
                                                                height: 16.0.w,
                                                                color: discountSvg,
                                                              ),
                                                            ),
                                                            Container(
                                                              height: 16.0.w,
                                                              alignment: Alignment.bottomCenter,
                                                              child: CustomTextBuilder(
                                                                text: '${TextConstant.maxDiscount} ',
                                                                fontColor: ColorConfig.defaultWhite,
                                                                fontSize: 12.0.sp,
                                                                fontWeight: FontWeight.w700,
                                                              ),
                                                            ),
                                                            mainTicketData[index]['seat'].isNotEmpty ? Container(
                                                              height: 16.0.w,
                                                              alignment: Alignment.bottomCenter,
                                                              child: CustomTextBuilder(
                                                                text: '${discountPercentData.first.floor()}%',
                                                                fontColor: ColorConfig().accent(),
                                                                fontSize: 12.0.sp,
                                                                fontWeight: FontWeight.w900,
                                                              ),
                                                            ) : Container(),
                                                          ],
                                                        ),
                                                      ) : Container(),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // 공연가격
                                          Container(
                                            width: MediaQuery.of(context).size.width,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(6.0.r),
                                            ),
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                // 예매참여 버튼
                                                mainTicketData[index]['is_sell_ticket'] == 1 ? InkWell(
                                                  onTap: () async {
                                                    TicketListAPI().list(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), showIndex: mainTicketData[index]['show_content_index']).then((value) {
                                                      SelectTicketDate().modalDatePicker(
                                                        context,
                                                        _controller,
                                                        data: value.result['data'],
                                                        minYear: int.parse(DateFormat('yyyy').format(DateTime.parse(mainTicketData[index]['min_date']).toLocal())),
                                                        minMonth: int.parse(DateFormat('MM').format(DateTime.parse(mainTicketData[index]['min_date']).toLocal())),
                                                        maxYear: int.parse(DateFormat('yyyy').format(DateTime.parse(mainTicketData[index]['max_date']).toLocal())),
                                                        maxMonth: int.parse(DateFormat('MM').format(DateTime.parse(mainTicketData[index]['max_date']).toLocal())),
                                                        showContentIndex: mainTicketData[index]['show_content_index'],
                                                      );
                                                    });
                                                  },
                                                  child: Container(
                                                    width: mainTicketData[index]['is_sell_auction'] == 1 && mainTicketData[index]['is_sell_ticket'] == 1
                                                      ? (MediaQuery.of(context).size.width - 52.0) / 2
                                                      : MediaQuery.of(context).size.width - 48.0,
                                                    decoration: BoxDecoration(
                                                      color: ColorConfig().gray5(),
                                                      borderRadius: BorderRadius.circular(4.0.r),
                                                    ),
                                                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                      children: [
                                                        Column(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Container(
                                                              margin: const EdgeInsets.only(bottom: 4.0),
                                                              child: CustomTextBuilder(
                                                                text: TextConstant.discountMinPrice,
                                                                fontColor: ColorConfig().gray2(),
                                                                fontSize: 11.0.sp,
                                                                fontWeight: FontWeight.w400,
                                                                height: null,
                                                              ),
                                                            ),
                                                            CustomTextBuilder(
                                                              text: '${SetIntl().numberFormat(mainTicketData[index]['seat'].firstWhere((el) => el['type'] == 'T')['discount'])}원',
                                                              fontColor: ColorConfig().white(),
                                                              fontSize: 12.0.sp,
                                                              fontWeight: FontWeight.w700,
                                                              height: null,
                                                            ),
                                                          ],
                                                        ),
                                                        CustomTextBuilder(
                                                          text: TextConstant.ticketing,
                                                          fontColor: ColorConfig().white(),
                                                          fontSize: 14.0.sp,
                                                          fontWeight: FontWeight.w800,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ) : Container(),
                                                // 경매참여 버튼
                                                mainTicketData[index]['is_sell_auction'] == 1 ? InkWell(
                                                  onTap: () async {
                                                    AuctionListAPI().auctionList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), showContentIndex: mainTicketData[index]['show_content_index']).then((value) {
                                                      SelectTicketDate().modalDatePicker(
                                                          context,
                                                          _controller,
                                                          dataType: ShowDataType.auction,
                                                          data: value.result['data'],
                                                          minYear: int.parse(DateFormat('yyyy').format(DateTime.parse(mainTicketData[index]['min_date']).toLocal())),
                                                          minMonth: int.parse(DateFormat('MM').format(DateTime.parse(mainTicketData[index]['min_date']).toLocal())),
                                                          maxYear: int.parse(DateFormat('yyyy').format(DateTime.parse(mainTicketData[index]['max_date']).toLocal())),
                                                          maxMonth: int.parse(DateFormat('MM').format(DateTime.parse(mainTicketData[index]['max_date']).toLocal())),
                                                          showContentIndex: mainTicketData[index]['show_content_index'],
                                                        );
                                                    });
                                                  },
                                                  child: Container(
                                                    width: mainTicketData[index]['is_sell_auction'] == 1 && mainTicketData[index]['is_sell_ticket'] == 1
                                                      ? (MediaQuery.of(context).size.width - 52.0) / 2
                                                      : MediaQuery.of(context).size.width - 48.0,
                                                    decoration: BoxDecoration(
                                                      color: ColorConfig().primary(),
                                                      borderRadius: BorderRadius.circular(4.0.r),
                                                    ),
                                                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                                                    margin: mainTicketData[index]['is_sell_auction'] == 1 && mainTicketData[index]['is_sell_ticket'] == 1
                                                      ? const EdgeInsets.only(left: 4.0)
                                                      : null,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                      children: [
                                                        Column(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Container(
                                                              margin: const EdgeInsets.only(bottom: 4.0),
                                                              child: CustomTextBuilder(
                                                                text: TextConstant.biddingStartPrice,
                                                                fontColor: ColorConfig().gray2(),
                                                                fontSize: 11.0.sp,
                                                                fontWeight: FontWeight.w400,
                                                              ),
                                                            ),
                                                            CustomTextBuilder(
                                                              text: '${SetIntl().numberFormat(mainTicketData[index]['seat'].firstWhere((el) => el['type'] == 'A')['discount'])}원',
                                                              fontColor: ColorConfig().white(),
                                                              fontSize: 12.0.sp,
                                                              fontWeight: FontWeight.w700,
                                                            ),
                                                          ],
                                                        ),
                                                        CustomTextBuilder(
                                                          text: TextConstant.joinedAuction,
                                                          fontColor: ColorConfig().white(),
                                                          fontSize: 14.0.sp,
                                                          fontWeight: FontWeight.w800,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ) : Container(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                                          
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: ColorConfig().mainPosterBackground(opacity: 0.7),
                                borderRadius: BorderRadius.circular(6.0.r),
                              ),
                              margin: const EdgeInsets.only(bottom: 8.0),
                              child: Column(
                                children: [
                                  // 공연정보
                                  Container(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        // 포스터
                                        Container(
                                          width: 120.0.w,
                                          height: 172.0.w,
                                          margin: const EdgeInsets.only(right: 16.0),
                                          decoration: BoxDecoration(
                                            color: mainTicketData[index]['image'] == null ? ColorConfig().gray2() : null,
                                            borderRadius: BorderRadius.circular(4.0.r),
                                            image: mainTicketData[index]['image'] != null
                                              ? DecorationImage(
                                                  image: NetworkImage(mainTicketData[index]['image']),
                                                  fit: BoxFit.cover,
                                                  filterQuality: FilterQuality.high,
                                                )
                                              : null,
                                          ),
                                          child: mainTicketData[index]['image'] == null ? Center(
                                            child: SVGBuilder(
                                              image: 'assets/icon/album.svg',
                                              width: 22.0.w,
                                              height: 22.0.w,
                                              color: ColorConfig().white(),
                                            ),
                                          ) : Container(),
                                        ),
                                        // 텍스트
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // ig-public 단독 표시
                                              mainTicketData[index]['is_only'] == 1 ? SVGStringBuilder(image: 'assets/img/ig-public-only.svg') : Container(),
                                              // 예매가능 좌석 표시
                                              Wrap(
                                                children: List.generate(toSetSeatNames.length, (seats) {
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      color: ColorConfig().gray5(),
                                                      borderRadius: BorderRadius.circular(1.0.r),
                                                    ),
                                                    padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
                                                    margin: mainTicketData[index]['seat'].length - 1 != seats ? const EdgeInsets.only(right: 2.0, top: 4.0) : const EdgeInsets.only(top: 4.0),
                                                    child: CustomTextBuilder(
                                                      text: '${toSetSeatNames[seats]}석',
                                                      fontColor: ColorConfig.defaultWhite,
                                                      fontSize: 12.0.sp,
                                                      fontWeight: FontWeight.w900,
                                                      height: 0.0,
                                                    ),
                                                  );
                                                }),
                                              ),
                                              // 공연 제목
                                              Container(
                                                width: MediaQuery.of(context).size.width,
                                                margin: const EdgeInsets.only(top: 16.0, bottom: 4.0),
                                                child: CustomTextBuilder(
                                                  text: '${mainTicketData[index]['name']}',
                                                  fontColor: ColorConfig.defaultWhite,
                                                  fontSize: 16.0.sp,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              // 공연기간
                                              mainTicketData[index]['view_start_date'] != null || mainTicketData[index]['view_end_date'] != null ? CustomTextBuilder(
                                                text: '${DateFormat('yyyy.M.d.').format(DateTime.parse(mainTicketData[index]['view_start_date']).toLocal())} - ${DateFormat('yyyy.M.d.').format(DateTime.parse(mainTicketData[index]['view_end_date']).toLocal())}',
                                                fontColor: ColorConfig().gray3(),
                                                fontSize: 12.0.sp,
                                                fontWeight: FontWeight.w700,
                                              ) : Container(),
                                              // 최대 할인율
                                              mainTicketData[index]['is_sell_ticket'] != 0 ? Container(
                                                margin: const EdgeInsets.only(top: 16.0),
                                                child: Row(
                                                  children: [
                                                    // 아이콘
                                                    Container(
                                                      margin: const EdgeInsets.only(right: 4.0),
                                                      child: SVGBuilder(
                                                        image: 'assets/icon/discount.svg',
                                                        width: 16.0.w,
                                                        height: 16.0.w,
                                                        color: discountSvg,
                                                      ),
                                                    ),
                                                    Container(
                                                      height: 16.0.w,
                                                      alignment: Alignment.bottomCenter,
                                                      child: CustomTextBuilder(
                                                        text: '${TextConstant.maxDiscount} ',
                                                        fontColor: ColorConfig.defaultWhite,
                                                        fontSize: 12.0.sp,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                    mainTicketData[index]['seat'].isNotEmpty ? Container(
                                                      height: 16.0.w,
                                                      alignment: Alignment.bottomCenter,
                                                      child: CustomTextBuilder(
                                                        text: '${discountPercentData.first.floor()}%',
                                                        fontColor: ColorConfig().accent(),
                                                        fontSize: 12.0.sp,
                                                        fontWeight: FontWeight.w900,
                                                      ),
                                                    ) : Container(),
                                                  ],
                                                ),
                                              ) : Container(),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // 공연가격
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6.0.r),
                                    ),
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // 예매참여 버튼
                                        mainTicketData[index]['is_sell_ticket'] == 1 ? InkWell(
                                          onTap: () async {
                                            TicketListAPI().list(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), showIndex: mainTicketData[index]['show_content_index']).then((value) {
                                              SelectTicketDate().modalDatePicker(
                                                context,
                                                _controller,
                                                data: value.result['data'],
                                                minYear: int.parse(DateFormat('yyyy').format(DateTime.parse(mainTicketData[index]['min_date']).toLocal())),
                                                minMonth: int.parse(DateFormat('MM').format(DateTime.parse(mainTicketData[index]['min_date']).toLocal())),
                                                maxYear: int.parse(DateFormat('yyyy').format(DateTime.parse(mainTicketData[index]['max_date']).toLocal())),
                                                maxMonth: int.parse(DateFormat('MM').format(DateTime.parse(mainTicketData[index]['max_date']).toLocal())),
                                                showContentIndex: mainTicketData[index]['show_content_index'],
                                              );
                                            });
                                          },
                                          child: Container(
                                            width: mainTicketData[index]['is_sell_auction'] == 1 && mainTicketData[index]['is_sell_ticket'] == 1
                                              ? (MediaQuery.of(context).size.width - 52.0) / 2
                                              : MediaQuery.of(context).size.width - 48.0,
                                            decoration: BoxDecoration(
                                              color: ColorConfig().gray5(),
                                              borderRadius: BorderRadius.circular(4.0.r),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      margin: const EdgeInsets.only(bottom: 4.0),
                                                      child: CustomTextBuilder(
                                                        text: TextConstant.discountMinPrice,
                                                        fontColor: ColorConfig().gray2(),
                                                        fontSize: 11.0.sp,
                                                        fontWeight: FontWeight.w400,
                                                        height: null,
                                                      ),
                                                    ),
                                                    CustomTextBuilder(
                                                      text: '${SetIntl().numberFormat(mainTicketData[index]['seat'].firstWhere((el) => el['type'] == 'T')['discount'])}원',
                                                      fontColor: ColorConfig().white(),
                                                      fontSize: 12.0.sp,
                                                      fontWeight: FontWeight.w700,
                                                      height: null,
                                                    ),
                                                  ],
                                                ),
                                                CustomTextBuilder(
                                                  text: TextConstant.ticketing,
                                                  fontColor: ColorConfig().white(),
                                                  fontSize: 14.0.sp,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ) : Container(),
                                        // 경매참여 버튼
                                        mainTicketData[index]['is_sell_auction'] == 1 ? InkWell(
                                          onTap: () async {
                                            AuctionListAPI().auctionList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), showContentIndex: mainTicketData[index]['show_content_index']).then((value) {
                                              SelectTicketDate().modalDatePicker(
                                                  context,
                                                  _controller,
                                                  dataType: ShowDataType.auction,
                                                  data: value.result['data'],
                                                  minYear: int.parse(DateFormat('yyyy').format(DateTime.parse(mainTicketData[index]['min_date']).toLocal())),
                                                  minMonth: int.parse(DateFormat('MM').format(DateTime.parse(mainTicketData[index]['min_date']).toLocal())),
                                                  maxYear: int.parse(DateFormat('yyyy').format(DateTime.parse(mainTicketData[index]['max_date']).toLocal())),
                                                  maxMonth: int.parse(DateFormat('MM').format(DateTime.parse(mainTicketData[index]['max_date']).toLocal())),
                                                  showContentIndex: mainTicketData[index]['show_content_index'],
                                                );
                                            });
                                          },
                                          child: Container(
                                            width: mainTicketData[index]['is_sell_auction'] == 1 && mainTicketData[index]['is_sell_ticket'] == 1
                                              ? (MediaQuery.of(context).size.width - 52.0) / 2
                                              : MediaQuery.of(context).size.width - 48.0,
                                            decoration: BoxDecoration(
                                              color: ColorConfig().primary(),
                                              borderRadius: BorderRadius.circular(4.0.r),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                                            margin: mainTicketData[index]['is_sell_auction'] == 1 && mainTicketData[index]['is_sell_ticket'] == 1
                                              ? const EdgeInsets.only(left: 4.0)
                                              : null,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      margin: const EdgeInsets.only(bottom: 4.0),
                                                      child: CustomTextBuilder(
                                                        text: TextConstant.biddingStartPrice,
                                                        fontColor: ColorConfig().gray2(),
                                                        fontSize: 11.0.sp,
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                    CustomTextBuilder(
                                                      text: '${SetIntl().numberFormat(mainTicketData[index]['seat'].firstWhere((el) => el['type'] == 'A')['discount'])}원',
                                                      fontColor: ColorConfig().white(),
                                                      fontSize: 12.0.sp,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ],
                                                ),
                                                CustomTextBuilder(
                                                  text: TextConstant.joinedAuction,
                                                  fontColor: ColorConfig().white(),
                                                  fontSize: 14.0.sp,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ) : Container(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ) : Container(),
                    
                    // 현재 진행중인 공연이 없을 때 현재까지 진행한 공연데이터 영역
                    processStatus == false ? Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          Column(
                            children: List.generate(hasNoTicketData.length, (index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: ColorConfig().mainPosterBackground(opacity: 0.7),
                                  borderRadius: BorderRadius.circular(6.0.r),
                                ),
                                margin: const EdgeInsets.only(bottom: 8.0),
                                child: Column(
                                  children: [
                                    // 공연정보
                                    Container(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          // 포스터
                                          Container(
                                            width: 120.0.w,
                                            height: 172.0.w,
                                            margin: const EdgeInsets.only(right: 16.0),
                                            decoration: BoxDecoration(
                                              color: hasNoTicketData[index]['image'] == null ? ColorConfig().gray2() : null,
                                              borderRadius: BorderRadius.circular(4.0.r),
                                              image: hasNoTicketData[index]['image'] != null
                                                ? DecorationImage(
                                                    image: NetworkImage(hasNoTicketData[index]['image']),
                                                    fit: BoxFit.cover,
                                                    filterQuality: FilterQuality.high,
                                                  )
                                                : null,
                                            ),
                                            child: hasNoTicketData[index]['image'] == null ? Center(
                                              child: SVGBuilder(
                                                image: 'assets/icon/album.svg',
                                                width: 22.0.w,
                                                height: 22.0.w,
                                                color: ColorConfig().white(),
                                              ),
                                            ) : Container(),
                                          ),
                                          // 텍스트
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // 공연 제목
                                                Container(
                                                  width: MediaQuery.of(context).size.width,
                                                  margin: const EdgeInsets.only(bottom: 8.0),
                                                  child: CustomTextBuilder(
                                                    text: '${hasNoTicketData[index]['name']}',
                                                    fontColor: ColorConfig.defaultWhite,
                                                    fontSize: 16.0.sp,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                // 공연기간
                                                hasNoTicketData[index]['view_start_date'] != null || hasNoTicketData[index]['view_end_date'] != null ? CustomTextBuilder(
                                                  text: '${DateFormat('yyyy.M.d.').format(DateTime.parse(hasNoTicketData[index]['view_start_date']).toLocal())} ~ ${DateFormat('yyyy.M.d.').format(DateTime.parse(hasNoTicketData[index]['view_end_date']).toLocal())}',
                                                  fontColor: ColorConfig().gray3(),
                                                  fontSize: 12.0.sp,
                                                  fontWeight: FontWeight.w700,
                                                ) : Container(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                          // 공연 오픈 요청 영역
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 4.0),
                                  child: CustomTextBuilder(
                                    text: TextConstant.hasNoShowingNowTitle,
                                    fontColor: ColorConfig().white(),
                                    fontSize: 16.0.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                CustomTextBuilder(
                                  text: TextConstant.hasNoShowingNowDescription,
                                  fontColor: ColorConfig().gray3(),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          // 공연 오픈 요청 버튼 영역
                          InkWell(
                            onTap: () async {
                              MainMyProfileAPI().myProfile(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
                                getChannelTalk(
                                  nickname: value.result['data']['nick'],
                                  name: value.result['data']['name'],
                                  email: value.result['data']['email'],
                                  phoneNumber: value.result['data']['phone'],
                                );
                              });
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              decoration: BoxDecoration(
                                color: ColorConfig().primary(),
                                borderRadius: BorderRadius.circular(4.0.r),
                              ),
                              child: Center(
                                child: CustomTextBuilder(
                                  text: TextConstant.requestNewShowOpen,
                                  fontColor: ColorConfig().white(),
                                  fontSize: 14.0.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ) : Container(),
                    // empty space
                    SizedBox(height: 60.0.w),
                  ],
                ),
              ),
              // SizedBox(
              //   height: const ig-publicAppBar().preferredSize.height + MediaQuery.of(context).padding.top,
              //   child: Stack(
              //     children: [
              //       ImageFiltered(
              //         imageFilter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 0.0),
              //         child: Container(
              //           color: ColorConfig().overlay(opacity: 0.4),
              //         ),
              //       ),
              //       ig-publicAppBar(
              //         backgroundColor: ColorConfig.transparent,
              //         leading: ig-publicAppBarLeading(
              //           press: () {},
              //           icon: Container(
              //             margin: const EdgeInsets.only(left: 10.0),
              //             child: SVGStringBuilder(
              //               image: 'assets/img/logo-white.svg',
              //             ),
              //           ),
              //         ),
              //         leadingWidth: 100.0,
              //         actions: [
              //           IconButton(
              //             onPressed: () {
              //               Navigator.pushNamed(context, 'searchHome');
              //             },
              //             icon: SVGBuilder(
              //               image: 'assets/icon/search.svg',
              //               color: ColorConfig().white(),
              //             ),
              //           ),
              //           IconButton(
              //             onPressed: () {
              //               Scaffold.of(context).openEndDrawer();
              //             },
              //             icon: SVGBuilder(
              //               image: 'assets/icon/sidemenu.svg',
              //               color: ColorConfig().white(),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ) : const LoadingProgressBuilder(),
      ),
    );
  }
}