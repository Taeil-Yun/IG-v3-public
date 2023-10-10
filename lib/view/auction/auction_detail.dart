import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:ig-public_v3/api/auction/auction_goer_list.dart';
import 'package:ig-public_v3/component/popup/popup.dart';
import 'package:intl/intl.dart';

import 'package:ig-public_v3/costant/enumerated.dart';
import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/src/route_argument.dart';
import 'package:ig-public_v3/api/auction/auction_detail.dart';
import 'package:ig-public_v3/api/auction/auction_list.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/view/seat/seat_view.dart';
import 'package:ig-public_v3/view/seat/auction_seat.dart';
import 'package:ig-public_v3/view/ticketing/component/select_date.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';

class AuctionDetailScreen extends StatefulWidget {
  const AuctionDetailScreen({super.key});

  @override
  State<AuctionDetailScreen> createState() => _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends State<AuctionDetailScreen> {
  late ScrollController customScrollViewController;
  late PageController calendarController;

  GlobalKey residualLineKey = GlobalKey();

  int currentTabIndex = 0;
  int showDetailIndex = 0;
  int showContentIndex = 0;

  bool isExpandedAppBar = false;
  bool onShowInformationStatus = false;

  double residualLine = 0.0;

  List auctionGoerList = [];

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
    AuctionDetailDataAPI().auctionDetail(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), showIndex: showDetailIndex).then((value) {
      setState(() {
        detailData = value.result['data'];
      });
    });
    AuctionGoerListAPI().goerList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), showDetailIndex: showDetailIndex).then((value) {
      setState(() {
        auctionGoerList = value.result['data'];
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
                            botBannerWidget(),
                            contentsSubtitleText(title: TextConstant.auctionMethod),
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
                  onTap: () {
                    Navigator.push(context, routeMoveVertical(page: AuctionSeatScreen(seat: detailData, showDetailIndex: showDetailIndex, showContentIndex: showContentIndex,)));
                  },
                  child: Container(
                    height: 54.0.w,
                    decoration: BoxDecoration(
                      color: ColorConfig().primary(),
                      borderRadius: BorderRadius.circular(4.0.r),
                    ),
                    child: Center(
                      child: CustomTextBuilder(
                        text: TextConstant.doJoinedAuction,
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
                          auctionGoerList.isNotEmpty ? InkWell(
                            onTap: () {
                              PopupBuilder(
                                title: '',
                                content: '',
                                onlyContentScrollable: false,
                                onTitleWidget: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 4.0),
                                      child: Text.rich(
                                        TextSpan(
                                          children: <TextSpan> [
                                            TextSpan(
                                              text: '해당 공연 경매에 참여한 회원',
                                              style: TextStyle(
                                                color: ColorConfig().dark(),
                                                fontSize: 16.0.sp,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' ${auctionGoerList.length}',
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
                                onContentWidget: Container(
                                  width: MediaQuery.of(context).size.width,
                                  constraints: const BoxConstraints(
                                    maxHeight: 300.0,
                                  ),
                                  child: auctionGoerList.isNotEmpty ? ListView(
                                    shrinkWrap: true,
                                    children: List.generate(auctionGoerList.length, (joinedIndex) {
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
                                                image: auctionGoerList[joinedIndex]['image'] != null
                                                  ? DecorationImage(
                                                      image: NetworkImage(auctionGoerList[joinedIndex]['image']),
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
                                                image: auctionGoerList[joinedIndex]['rank'] == 7
                                                  ? const AssetImage('assets/img/rank-m.png')
                                                  : auctionGoerList[joinedIndex]['rank'] == 6
                                                    ? const AssetImage('assets/img/rank-d.png')
                                                    : auctionGoerList[joinedIndex]['rank'] == 5
                                                      ? const AssetImage('assets/img/rank-pl.png')
                                                      : auctionGoerList[joinedIndex]['rank'] == 4
                                                        ? const AssetImage('assets/img/rank-r.png')
                                                        : auctionGoerList[joinedIndex]['rank'] == 3
                                                          ? const AssetImage('assets/img/rank-g.png')
                                                          : auctionGoerList[joinedIndex]['rank'] == 2
                                                            ? const AssetImage('assets/img/rank-s.png')
                                                            : const AssetImage('assets/img/rank-w.png'),
                                                filterQuality: FilterQuality.high,
                                                width: 16.0.w,
                                                height: 16.0.w,
                                              ),
                                            ),
                                            CustomTextBuilder(
                                              text: '${auctionGoerList[joinedIndex]['nick']}',
                                              fontColor: ColorConfig().dark(),
                                              fontSize: 12.0.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ],
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
                                            image: AssetImage('assets/img/no-data-person.png'),
                                            filterQuality: FilterQuality.high,
                                          ),
                                        ),
                                      ),
                                      CustomTextBuilder(
                                        text: '아직 경매에 참여한 회원이 없습니다.\n천원으로 경매에 참여해보는건 어떨까요?',
                                        fontColor: ColorConfig().gray4(),
                                        fontSize: 14.0.sp,
                                        fontWeight: FontWeight.w400,
                                        height: 1.2,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
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
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 32.0.w,
                              child: Stack(
                                children: List.generate(4, (index) {
                                  if (index == 3) {
                                    return Positioned(
                                      left: index * 24.0,
                                      child: Container(
                                        width: 32.0.w,
                                        height: 32.0.w,
                                        decoration: BoxDecoration(
                                          color: ColorConfig().gray2(),
                                          borderRadius: BorderRadius.circular(16.0.r),
                                        ),
                                        child: Center(
                                          child: CustomTextBuilder(
                                            text: '+${auctionGoerList.length - 3}',
                                            fontColor: ColorConfig().gray4(),
                                            fontSize: 10.0.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                          
                                  return Positioned(
                                    left: index * 24.0,
                                    child: Container(
                                      width: 32.0.w,
                                      height: 32.0.w,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16.0.r),
                                        image: auctionGoerList[index]['image'] != null
                                          ? DecorationImage(
                                              image: NetworkImage(auctionGoerList[index]['image']),
                                              fit: BoxFit.cover,
                                              filterQuality: FilterQuality.high,
                                            )
                                          : const DecorationImage(
                                              image: AssetImage('assets/img/profile_default.png'),
                                              fit: BoxFit.cover,
                                              filterQuality: FilterQuality.high,
                                            ),
                                      ),
                                    ),
                                  );
                                }),
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
            AuctionListAPI().auctionList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), showContentIndex: showContentIndex).then((value) {
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
                dataType: ShowDataType.auction,
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
                    decoration: BoxDecoration(
                      color: ColorConfig().gray1(),
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
                                text: '1,000원',
                                fontColor: ColorConfig().dark(),
                                fontSize: 14.0.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            CustomTextBuilder(
                              text: TextConstant.auctionStartPrice,
                              style: TextStyle(
                                color: ColorConfig().gray5(),
                                fontSize: 11.0.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 8.0),
                          child: CustomTextBuilder(
                            text: '${detailData['seats'][index]['participant_count']}명 경매',
                            fontColor: ColorConfig().gray5(),
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
                text: TextConstant.untilAuctionEndDate,
                fontColor: ColorConfig().dark(),
                fontSize: 12.0.sp,
                fontWeight: FontWeight.w700,
              ),
              CustomTextBuilder(
                text: detailData.isNotEmpty ? '${DateTime.parse(detailData['end_date']).toLocal().difference(DateTime.now().toLocal()).inDays.toString()}일 ${DateTime.parse(detailData['end_date']).toLocal().hour - DateTime.now().hour < 0 ? 24 - (DateTime.parse(detailData['end_date']).toLocal().hour - DateTime.now().hour).abs() : DateTime.parse(detailData['end_date']).toLocal().hour - DateTime.now().hour}시간 남음' : '',
                fontColor: ColorConfig().accentLight(),
                fontSize: 12.0.sp,
                fontWeight: FontWeight.w700,
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          InkWell(
            onTap: () {
              Navigator.push(context, routeMoveVertical(page: SeatViewScreen(seat: detailData, showDetailIndex: showDetailIndex, dataType: ShowDataType.auction)));
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
                  text: TextConstant.viewAuctionAbleSeat,
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
              return Stack(
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
          return Container(
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

  // 경매방법 step
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
            children: List.generate(TextConstant.auctionStep.length, (index) {
              return Container(
                key: index == TextConstant.auctionStep.length - 1 ? residualLineKey : null,
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
                        text: TextConstant.auctionStep[index],
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
        children: List.generate(TextConstant.auctionCaution.length, (index) {
          return Container(
            margin: EdgeInsets.only(top: index != 0 ? 8.0 : 0.0),
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
                Flexible(
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
    );
  }

  // 하단 배너 위젯
  Widget botBannerWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        color: ColorConfig().primaryLight3(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.87, 0, -1, 0.255, 0,
                0, 0.45, -1, 0.255, 0,
                0, 0, 1, 0.255, 0,
                0, 0, -1, 1, 0,
              ]),
              child: Container(
                width: 16.0.w,
                height: 16.0.w,
                margin: const EdgeInsets.only(right: 6.0),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/img/heart2.png'),
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: CustomTextBuilder(
                      text: TextConstant.auctionBannerDescript1,
                      fontColor: ColorConfig().primary(),
                      fontSize: 12.0.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  CustomTextBuilder(
                    text: TextConstant.auctionBannerDescript2,
                    fontColor: ColorConfig().gray4(),
                    fontSize: 12.0.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}