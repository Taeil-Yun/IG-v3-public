import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/api/main/main_myprofile.dart';
import 'package:ig-public_v3/api/ticket/ticket_list.dart';
import 'package:ig-public_v3/component/popup/popup.dart';
import 'package:ig-public_v3/view/seat/seat_view.dart';
import 'package:ig-public_v3/view/ticketing/component/select_date.dart';
import 'package:ig-public_v3/widget/ticket_open_schedule_rank.dart';
import 'package:intl/intl.dart';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/src/route_argument.dart';
import 'package:ig-public_v3/api/ticket/ticket_detail.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/util/set_intl.dart';
import 'package:ig-public_v3/view/seat/ticketing_seat.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TicketingDetailScreen extends StatefulWidget {
  const TicketingDetailScreen({super.key});

  @override
  State<TicketingDetailScreen> createState() => _TicketingDetailScreenState();
}

class _TicketingDetailScreenState extends State<TicketingDetailScreen> {
  late ScrollController customScrollViewController;
  late PageController calendarController;

  GlobalKey residualLineKey = GlobalKey();

  int currentTabIndex = 0;
  int showDetailIndex = 0;
  int showContentIndex = 0;

  bool isExpandedAppBar = false;
  bool onShowInformationStatus = false;
  bool loadingProgress = true;

  double residualLine = 0.0;

  Map<String, dynamic> detailData = {};

  @override
  void initState() {
    super.initState();

    customScrollViewController = ScrollController();

    calendarController = PageController();

    Future.delayed(Duration.zero, () {
      if (RouteGetArguments().getArgs(context)['show_detail_index'] != null) {
        setState(() {
          showDetailIndex = RouteGetArguments().getArgs(context)['show_detail_index'];
          showContentIndex = RouteGetArguments().getArgs(context)['show_content_index'];
        });
      }

      setState(() {
        residualLine = residualLineKey.currentContext!.size!.height;
      });
    });

    initializeAPI();
  }

  Future<void> initializeAPI() async {
    TicketDetailDataAPI().ticketDetail(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), showIndex: showDetailIndex).then((value) {
      setState(() {
        detailData = value.result['data'];
        loadingProgress = false;
      });
    });
  }

  // sliver appbar 축소 or 확대 체크 함수
  bool get isSliverAppBarExpanded {
    return customScrollViewController.hasClients && customScrollViewController.offset > kToolbarHeight; //kExpandedHeight - kToolbarHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              controller: customScrollViewController,
              physics: const ClampingScrollPhysics(),
              slivers: [
                // sliver appbar
                SliverAppBar(
                  toolbarHeight: const ig-publicAppBar().preferredSize.height,
                  expandedHeight: const ig-publicAppBar().preferredSize.height + 220.0.w,
                  pinned: true,
                  elevation: 0.0,
                  backgroundColor: ColorConfig().white(),
                  leading: ig-publicAppBarLeading(
                    press: () => Navigator.pop(context),
                    iconColor: isExpandedAppBar ? ColorConfig().dark() : ColorConfig().white(),
                  ),
                  flexibleSpace: sliverAppBarFlexibleSpaceWidget(),
                  actions: [
                    IconButton(
                      onPressed: () {},
                      icon: SVGBuilder(
                        image: 'assets/icon/share.svg',
                        width: 22.0.w,
                        height: 22.0.w,
                        color: isExpandedAppBar ? ColorConfig().dark() : ColorConfig().white(),
                      ),
                    ),
                  ],
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Container(
                        color: ColorConfig().white(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            contentsSubtitleText(title: TextConstant.ticketInfomation),
                            selectDateWidget(),
                            seatTicketInfomation(),
                            showSeatStatusWidget(), 
                            detailData.isNotEmpty && detailData['artists'].isNotEmpty ? contentsSubtitleText(title: TextConstant.castCommunity, useMore: detailData['artists'] != null ? true : false, quantity: detailData['artists'] != null ? detailData['artists'].length : 0) : Container(),
                            artistCommunityListWidget(),
                            detailData.isNotEmpty && detailData['reviews'].isNotEmpty ? contentsSubtitleText(title: TextConstant.review, useMore: true, quantity: detailData['reviews'].length, useTopMargin: false) : Container(),
                            detailData.isNotEmpty && detailData['reviews'].isNotEmpty ? reviewListWidget() : Container(),
                            contentsSubtitleText(title: TextConstant.ticketInfomation),
                            detailInfomationWidget(),
                            Container(
                              margin: const EdgeInsets.only(top: 16.0),
                              child: Container(
                                height: 8.0.w,
                                color: ColorConfig().divider1(),
                              ),
                            ),
                            contentsSubtitleText(title: TextConstant.howTicketing),
                            howTicketingStep(),
                            contentsSubtitleText(title: TextConstant.caution),
                            cautionWidget(),
                            SizedBox(height: 48.0.w),  // 여백처리
                            SizedBox(height: 24.0 + 54.0.w,),  // 예매하기 박스 높이값만큼 올려주기
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0.0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: ColorConfig().white(),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0.0, -10.0),
                      blurRadius: 8.0,
                      color: ColorConfig.defaultBlack.withOpacity(0.12),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () async {
                    final SharedPreferences prefs = await SharedPreferences.getInstance();

                    if (!mounted) return;

                    if (DateTime.now().millisecondsSinceEpoch >= DateTime.parse(detailData['start_date_${prefs.get('myRank')}']).toLocal().millisecondsSinceEpoch) {
                      Navigator.push(context, routeMoveVertical(page: TicketingSeatScreen(seat: detailData, showTicketIndex: showDetailIndex, showContentIndex: showContentIndex)));
                    } else {
                      List<String> openDates = [
                        detailData['start_date_1'],
                        detailData['start_date_2'],
                        detailData['start_date_3'],
                        detailData['start_date_4'],
                        detailData['start_date_5'],
                        detailData['start_date_6'],
                        detailData['start_date_7'],
                      ];

                      int myRanking = prefs.getInt('myRank') ?? -1;

                      ticketOpenScheduleRankingPopup(context, myRanking: myRanking, openDates: openDates);
                    }
                  },
                  child: Container(
                    height: 54.0.w,
                    decoration: BoxDecoration(
                      color: ColorConfig().primary(),
                      borderRadius: BorderRadius.circular(4.0.r),
                    ),
                    child: Center(
                      child: CustomTextBuilder(
                        text: TextConstant.ticketing,
                        fontColor: ColorConfig().white(),
                        fontSize: 16.0.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // sliver appbar 
  Widget sliverAppBarFlexibleSpaceWidget() {
    return LayoutBuilder(
      builder: (_, constraints) {
        Future.delayed(Duration.zero, () {
          setState(() {  
            if (constraints.biggest.height == const ig-publicAppBar().preferredSize.height) {
              isExpandedAppBar = true;
            } else {
              isExpandedAppBar = false;
            }
          });
        });

        return FlexibleSpaceBar(
          background: Stack(
            children: [
              // background
              ClipRect(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Container(
                  decoration: BoxDecoration(
                    color: detailData['image'] == null ? ColorConfig().borderGray1() : null,
                    image: detailData['image'] != null ? DecorationImage(
                      image: NetworkImage(detailData['image']),
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ) : null,
                  ),
                  child: detailData['image'] != null ? BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      color: ColorConfig.defaultBlack.withOpacity(0.2),
                    ),
                  ) : Container(),
                ),
              ),
              // contents data
              Container(
                width: MediaQuery.of(context).size.width,
                height: 220.0.w,
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 32.0),
                margin: EdgeInsets.only(top: const ig-publicAppBar().preferredSize.height,),
                child: Row(
                  children: [
                    Container(
                      width: 120.0.w,
                      height: 172.0.w,
                      margin: const EdgeInsets.only(right: 20.0),
                      decoration: BoxDecoration(
                        color: detailData['image'] == null ? ColorConfig().borderGray2() : null,
                        borderRadius: BorderRadius.circular(4.0.r),
                        image: detailData['image'] != null ? DecorationImage(
                          image: NetworkImage(detailData['image']),
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                        ) : null,
                      ),
                      child: detailData['image'] == null ? Center(
                        child: SVGBuilder(
                          image: 'assets/icon/album.svg',
                          width: 30.0.w,
                          height: 30.0.w,
                          color: ColorConfig().white(),
                        ),
                      ) : Container(),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            child: CustomTextBuilder(
                              text: '${detailData['name']}',
                              fontColor: ColorConfig().white(),
                              fontSize: 18.0.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          CustomTextBuilder(
                            text: detailData.isNotEmpty ? '${DateFormat('yyyy.M.d. (E)', 'ko').format(DateTime.parse(detailData['view_start_date']).toLocal())} ~ ${DateFormat('yyyy.M.d. (E)', 'ko').format(DateTime.parse(detailData['view_end_date']).toLocal())}' : '',
                            fontColor: ColorConfig().white(),
                            fontSize: 12.0.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 2.0),
                                  child: SVGBuilder(
                                    image: 'assets/icon/location.svg',
                                    width: 20.0.w,
                                    height: 20.0.w,
                                    color: ColorConfig().white(),
                                  ),
                                ),
                                CustomTextBuilder(
                                  text: '${detailData['location']}',
                                  fontColor: ColorConfig().white(),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                            child: CustomTextBuilder(
                              text: '${TextConstant.runningTime} ${detailData['running_time']}${TextConstant.minute}',
                              fontColor: ColorConfig().divider1(),
                              fontSize: 12.0.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          // SizedBox(
                          //   width: MediaQuery.of(context).size.width,
                          //   height: 32.0.w,
                          //   child: Stack(
                          //     children: List.generate(4, (index) {
                          //       return Positioned(
                          //         left: index * 24.0,
                          //         child: Container(
                          //           width: 32.0.w,
                          //           height: 32.0.w,
                          //           decoration: BoxDecoration(
                          //             color: index.isEven ? Colors.red : Colors.blue,
                          //             borderRadius: BorderRadius.circular(16.0.r),
                          //           ),
                          //         ),
                          //       );
                          //     }),
                          //   ),
                          // ),
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
    );
  }

  // 콘텐츠 subtitle 텍스트
  Widget contentsSubtitleText({required String title, bool useMore = false, int? quantity, bool useTopMargin = true}) {
    return Container(
      margin: useTopMargin ? const EdgeInsets.only(top: 16.0) : null,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: !useMore
        ? CustomTextBuilder(
            text: title,
            fontColor: ColorConfig().dark(),
            fontSize: 16.0.sp,
            fontWeight: FontWeight.w800,
          )
        : Row(
            children: [
              CustomTextBuilder(
                text: title,
                fontColor: ColorConfig().dark(),
                fontSize: 16.0.sp,
                fontWeight: FontWeight.w800,
              ),
              Container(
                margin: const EdgeInsets.only(left: 4.0),
                child: CustomTextBuilder(
                  text: quantity.toString(),
                  fontColor: ColorConfig().primary(),
                  fontSize: 16.0.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_outlined,
                color: ColorConfig().primary(),
                size: 16.0.sp,
              ),
            ], 
          ),
    );
  }

  // 날짜선택 박스
  Widget selectDateWidget() {
    if (detailData.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        child: InkWell(
          onTap: () async {
            TicketListAPI().list(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), showIndex: showContentIndex).then((value) {
              SelectTicketDate().modalDatePicker(
                context,
                calendarController,
                data: value.result['data'],
                minYear: int.parse(DateFormat('yyyy').format(DateTime.parse(detailData['min_show_date']).toLocal())),
                minMonth: int.parse(DateFormat('MM').format(DateTime.parse(detailData['min_show_date']).toLocal())),
                maxYear: int.parse(DateFormat('yyyy').format(DateTime.parse(detailData['max_show_date']).toLocal())),
                maxMonth: int.parse(DateFormat('MM').format(DateTime.parse(detailData['max_show_date']).toLocal())),
                showContentIndex: showContentIndex,
                selectInDetail: true,
              );
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: ColorConfig().light(),
              border: Border.all(
                width: 1.0,
                color: ColorConfig().primary(),
              ),
              borderRadius: BorderRadius.circular(4.0.r),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CustomTextBuilder(
                        text: detailData['open_date'] != null ? DateFormat('yyyy. M. dd (E)', 'ko').format(DateTime.parse(detailData['open_date']).toLocal()) : '',
                        fontColor: ColorConfig().primary(),
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w800,
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 6.0),
                        child: CustomTextBuilder(
                          text: detailData['open_date'] != null ? DateFormat('aa hh:mm', 'ko').format(DateTime.parse(detailData['open_date']).toLocal()) : '',
                          fontColor: ColorConfig().gray5(),
                          fontSize: 14.0.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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
      );
    } else {
      return Container();
    }
  }

  // 좌석티켓 정보
  Widget seatTicketInfomation() {
    if (detailData['seats'] != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: List.generate(detailData['seats'].length, (index) {
            return Container(
              height: 32.0.w,
              margin: const EdgeInsets.only(top: 4.0),
              decoration: BoxDecoration(
                color: ColorConfig().gray1(),
                borderRadius: BorderRadius.circular(4.0.r),
              ),
              child: Stack(
                children: [
                  Container(
                    width: (MediaQuery.of(context).size.width / detailData['seats'][index]['ticket_total']) * int.parse(detailData['seats'][index]['sell_ticket_count']),
                    decoration: BoxDecoration(
                      color: detailData['seats'][index]['ticket_total'] - int.parse(detailData['seats'][index]['sell_ticket_count']) > 10 ? ColorConfig().gray5(opacity: 0.2) : ColorConfig().accent(opacity: 0.2),
                      borderRadius: BorderRadius.circular(4.0.r),
                    ),
                  ),
                  SizedBox(
                    height: 32.0.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40.0.w,
                              margin: const EdgeInsets.only(left: 8.0),
                              child: CustomTextBuilder(
                                text: '${detailData['seats'][index]['seat_name']}',
                                fontColor: ColorConfig().dark(),
                                fontSize: 14.0.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 8.0, right: 4.0),
                              child: CustomTextBuilder(
                                text: '${SetIntl().numberFormat(detailData['seats'][index]['discount'])}',
                                fontColor: ColorConfig().dark(),
                                fontSize: 12.0.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            CustomTextBuilder(
                              text: '${SetIntl().numberFormat(detailData['seats'][index]['price'])}',
                              style: TextStyle(
                                color: ColorConfig().gray3(),
                                fontSize: 11.0.sp,
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.lineThrough
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 8.0),
                          child: CustomTextBuilder(
                            text: '${detailData['seats'][index]['ticket_total'] - int.parse(detailData['seats'][index]['sell_ticket_count'])}명 남음',
                            fontColor: detailData['seats'][index]['ticket_total'] - int.parse(detailData['seats'][index]['sell_ticket_count']) > 10 ? ColorConfig().gray5() : ColorConfig().accent(),
                            fontSize: 12.0.sp,
                            fontWeight: FontWeight.w700,
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
      );
    }
    return Container();
  }
  
  // 좌석현황 보기 박스
  Widget showSeatStatusWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 24.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 13.0),
      color: ColorConfig().gray1(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextBuilder(
                text: TextConstant.ticketOpenSchedule,
                fontColor: ColorConfig().dark(),
                fontSize: 12.0.sp,
                fontWeight: FontWeight.w700,
              ),
              InkWell(
                onTap: () {
                  // 티켓 오픈 일정 팝업 및 내 좌석 선택 시간 영역
                  PopupBuilder(
                    title: TextConstant.ticketOpenSchedule,
                    content: '',
                    useScrollBar: false,
                    scrollable: true,
                    onlyContentScrollable: false,
                    onContentWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextBuilder(
                          text: '본인의 ig-public 등급에 해당하는 일정에 예매할 수 있습니다.',
                          fontColor: ColorConfig().gray4(),
                          fontSize: 12.0.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                          child: Column(
                            children: List.generate(7, (index) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                                margin: index != 6 ? const EdgeInsets.only(bottom: 8.0) : null,
                                decoration: BoxDecoration(
                                  color: index == 1 ? ColorConfig().gray2() : null,
                                  borderRadius: BorderRadius.circular(4.0.r),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Image(
                                          image: index == 0
                                            ? const AssetImage('assets/img/rank-m.png')
                                            : index == 1
                                              ? const AssetImage('assets/img/rank-d.png')
                                              : index == 2
                                                ? const AssetImage('assets/img/rank-pl.png')
                                                : index == 3
                                                  ? const AssetImage('assets/img/rank-r.png')
                                                  : index == 4
                                                    ? const AssetImage('assets/img/rank-g.png')
                                                    : index == 5
                                                      ? const AssetImage('assets/img/rank-s.png')
                                                      : const AssetImage('assets/img/rank-w.png'),
                                          width: 16.0.w,
                                          height: 16.0.w,
                                          fit: BoxFit.cover,
                                          filterQuality: FilterQuality.high,
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(left: 4.0),
                                          child: CustomTextBuilder(
                                            text: TextConstant.rankNames[index],
                                            fontColor: ColorConfig().gray5(),
                                            fontSize: 14.0.sp,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                    CustomTextBuilder(
                                      text: index == 0
                                            ? DateFormat('yyyy.MM.dd aa hh:mm', 'ko').format(DateTime.parse(detailData['start_date_1']).toLocal())
                                            : index == 1
                                              ? DateFormat('yyyy.MM.dd aa hh:mm', 'ko').format(DateTime.parse(detailData['start_date_2']).toLocal())
                                              : index == 2
                                                ? DateFormat('yyyy.MM.dd aa hh:mm', 'ko').format(DateTime.parse(detailData['start_date_3']).toLocal())
                                                : index == 3
                                                  ? DateFormat('yyyy.MM.dd aa hh:mm', 'ko').format(DateTime.parse(detailData['start_date_4']).toLocal())
                                                  : index == 4
                                                    ? DateFormat('yyyy.MM.dd aa hh:mm', 'ko').format(DateTime.parse(detailData['start_date_5']).toLocal())
                                                    : index == 5
                                                      ? DateFormat('yyyy.MM.dd aa hh:mm', 'ko').format(DateTime.parse(detailData['start_date_6']).toLocal())
                                                      : DateFormat('yyyy.MM.dd aa hh:mm', 'ko').format(DateTime.parse(detailData['start_date_7']).toLocal()),
                                      fontColor: ColorConfig().gray5(),
                                      fontSize: 12.0.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
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
                    ),
                  ).ig-publicDialog(context);
                },
                child: Row(
                  children: [
                    CustomTextBuilder(
                      text: detailData.isNotEmpty ? '${DateFormat('yyyy.MM.dd').format(DateTime.parse(detailData['open_date']).toLocal())} · ${DateFormat('aa hh:mm', 'ko').format(DateTime.parse(detailData['open_date']).toLocal())}' : '',
                      fontColor: ColorConfig().gray4(),
                      fontSize: 12.0.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 6.0),
                      child: SVGBuilder(
                        image: 'assets/icon/arrow_right_light.svg',
                        width: 16.0.w,
                        height: 16.0.w,
                        color: ColorConfig().gray4(),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          InkWell(
            onTap: () {
              Navigator.push(context, routeMoveVertical(page: SeatViewScreen(seat: detailData, showDetailIndex: showDetailIndex)));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13.0),
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
                  text: TextConstant.showSeatStatus,
                  fontColor: ColorConfig().gray5(),
                  fontSize: 13.0.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 아티스트 커뮤니티 리스트
  Widget artistCommunityListWidget() {
    if (detailData['artists'] != null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.fromLTRB(20.0, 4.0, 20.0, 16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(detailData['artists'].length, (index) {
              return InkWell(
                onTap: () {
                  Navigator.pushNamed(context, 'artistCommunity', arguments: {
                    'artist_index': detailData['artists'][index]['artist_index'],
                  });
                },
                child: Stack(
                  children: [
                    Container(
                      width: 48.0.w,
                      height: 48.0.w,
                      margin: detailData['artists'].length - 1 != index ? const EdgeInsets.only(right: 8.0) : null,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1.0,
                            color: ColorConfig().borderGray1(opacity: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(24.0.r),
                          image: detailData['artists'][index]['image'] == null
                            ? const DecorationImage(
                                image: AssetImage('assets/img/profile_default.png'),
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                              )
                            : DecorationImage(
                                image: NetworkImage(detailData['artists'][index]['image']),
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                              ),
                        ),
                      ),
                    ),
                    // Positioned(
                    //   right: 0.0,
                    //   child: Container(
                    //     width: 16.0.w,
                    //     height: 16.0.w,
                    //     decoration: BoxDecoration(
                    //       color: Colors.red,
                    //       borderRadius: BorderRadius.circular(8.0.r),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              );
            }),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  // 공연후기 리스트
  Widget reviewListWidget() {
    return Container(
      padding: const EdgeInsets.only(top: 4.0, bottom: 16.0),
      constraints: BoxConstraints(
        maxHeight: 122.0.w,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        itemCount: detailData['reviews'].length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.pushNamed(context, 'postDetail', arguments: {
                'community_index': detailData['reviews'][index]['community_index'],
              });
            },
            child: Container(
              width: 292.0.w,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              margin: EdgeInsets.only(right: index != detailData['reviews'].length - 1 ? 8.0 : 0.0),
              decoration: BoxDecoration(
                color: ColorConfig().gray1(),
                borderRadius: BorderRadius.circular(4.0.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RatingBar.builder(
                        initialRating: detailData['reviews'][index]['star'] != null ? detailData['reviews'][index]['star'] / 10 : 0.0,
                        ignoreGestures: true,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 18.0.w,
                        unratedColor: ColorConfig().gray2(),
                        // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => SVGBuilder(
                          image: 'assets/icon/star.svg',
                          width: 18.0.w,
                          height: 18.0.w,
                          color: ColorConfig().primaryLight(),
                        ),
                        onRatingUpdate: (rating) {},
                      ),
                      CustomTextBuilder(
                        text: '${detailData['reviews'][index]['nick']}',
                        fontColor: ColorConfig().gray5(),
                        fontSize: 12.0.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                  CustomTextBuilder(
                    text: '${detailData['reviews'][index]['content']}',
                    fontColor: ColorConfig().dark(),
                    fontSize: 12.0.sp,
                    fontWeight: FontWeight.w400,
                    maxLines: 2,
                    textOverflow: TextOverflow.ellipsis,
                    height: 1.2,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomTextBuilder(
                        text: detailData['reviews'][index]['open_date'] != null ? DateFormat('yyyy.MM.dd 관람').format(DateTime.parse(detailData['reviews'][index]['open_date']).toLocal()) : '',
                        fontColor: ColorConfig().gray3(),
                        fontSize: 11.0.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      Row(
                        children: [
                          Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 4.0),
                                child: SVGBuilder(
                                  image: 'assets/icon/chat-off.svg',
                                  width: 16.0.w,
                                  height: 16.0.w,
                                  color: ColorConfig().gray3(),
                                ),
                              ),
                              CustomTextBuilder(
                                text: '${detailData['reviews'][index]['reply_count']}',
                                fontColor: ColorConfig().gray3(),
                                fontSize: 12.0.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 16.0),
                            child: Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 4.0),
                                  child: SVGBuilder(
                                    image: 'assets/icon/heart-off-disabled-bg.svg',
                                    width: 16.0.w,
                                    height: 16.0.w,
                                    color: ColorConfig().gray3(),
                                  ),
                                ),
                                CustomTextBuilder(
                                  text: '${detailData['reviews'][index]['like_count']}',
                                  fontColor: ColorConfig().gray3(),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 공연정보 상세
  Widget detailInfomationWidget() {
    if (detailData.isNotEmpty) {
      return Column(
        children: [
          SizedBox(
            height: onShowInformationStatus == false ? 183.0.w : null,
            child: Html(
            data: detailData['description'],
            style: {
              "img" : Style(
                width: Width.auto(),
              ),
              "br" : Style(
                height: Height(0.0),
                display: Display.none,
              ),
            },
            // onLinkTap: (url, _, __, ___) {
            //           ig-publicUrlLauncher().launchURL(url.toString());
            //           print("Opening $url...");
            //         },
            ),
          ),
          onShowInformationStatus == false ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  onShowInformationStatus = true;
                });
              },
              child: Container(
                height: 40.0.w,
                decoration: BoxDecoration(
                  color: ColorConfig().white(),
                  border: Border.all(
                    width: 1.0,
                    color: ColorConfig().borderGray2(),
                  ),
                  borderRadius: BorderRadius.circular(6.0.r),
                ),
                child: Center(
                  child: CustomTextBuilder(
                    text: TextConstant.showAllText,
                    fontColor: ColorConfig().gray5(),
                    fontSize: 14.0.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ) : Container(),
        ],
      );
    } else {
      return Container();
    }
  }

  // 예매방법 step
  Widget howTicketingStep() {
    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Stack(
        children: [
          Positioned.fill(
            left: 3.0.w,
            bottom: residualLine - 16.0,
            right: (MediaQuery.of(context).size.width - (40.0 + 8.0.w - 3.0.w)),
            child: Container(
              width: 2.0.w,
              color: ColorConfig().primaryLight(),
            ),
          ),
          Column(
            children: List.generate(TextConstant.ticketingStep.length, (index) {
              return Container(
                key: index == TextConstant.ticketingStep.length - 1 ? residualLineKey : null,
                margin: EdgeInsets.only(top: index != 0 ? 16.0 : 0.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8.0.w,
                      height: 8.0.w,
                      decoration: BoxDecoration(
                        color: ColorConfig().primaryLight(),
                        borderRadius: BorderRadius.circular(4.0.r),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 8.0, right: 4.0),
                      child: CustomTextBuilder(
                        text: 'Step ${index + 1}',
                        fontColor: ColorConfig().primaryLight(),
                        fontSize: 12.0.sp,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                      ),
                    ),
                    Flexible(
                      child: CustomTextBuilder(
                        text: TextConstant.ticketingStep[index],
                        fontColor: ColorConfig().dark(),
                        fontSize: 12.0.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // 주의사항 데이터
  Widget cautionWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: List.generate(TextConstant.ticketingCaution.length, (index) {
          return Container(
            margin: EdgeInsets.only(top: index != 0 ? 8.0 : 0.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4.0.w,
                  height: 4.0.w,
                  margin: const EdgeInsets.only(top: 6.0, right: 10.0),
                  decoration: BoxDecoration(
                    color: ColorConfig().gray5(),
                    borderRadius: BorderRadius.circular(2.0.r),
                  ),
                ),
                Flexible(
                  child: CustomTextBuilder(
                    text: TextConstant.ticketingCaution[index],
                    fontColor: ColorConfig().gray5(),
                    fontSize: 12.0.sp,
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}