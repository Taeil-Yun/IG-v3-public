import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/api/follow/follow_list.dart';
import 'package:ig-public_v3/api/main/main_myprofile.dart';
import 'package:ig-public_v3/api/profile/my_write_post.dart';
import 'package:ig-public_v3/component/channel_talk/channel_talk.dart';
import 'package:ig-public_v3/component/popup/popup.dart';
import 'package:ig-public_v3/costant/build_config.dart';

import 'package:ig-public_v3/src/auth/login.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/util/set_intl.dart';
import 'package:ig-public_v3/util/share.dart';
import 'package:ig-public_v3/view/main/community_widget/widgets.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:ig-public_v3/widget/loading_progress.dart';
import 'package:ig-public_v3/widget/sliver_tabbar_widget.dart';
import 'package:yaml/yaml.dart';

class MainMyProfileScreen extends StatefulWidget {
  MainMyProfileScreen({
    super.key,
    this.isNavigator = false,
  });

  bool isNavigator;

  @override
  State<MainMyProfileScreen> createState() => _MainMyProfileScreenState();
}

class _MainMyProfileScreenState extends State<MainMyProfileScreen> with TickerProviderStateMixin {
  late ScrollController customScrollViewController;
  late TabController sliverTabBarController;

  Timer? _debounce;

  int currentTabIndex = 0;

  String appVersion = '';

  bool isExpandedAppBar = false;
  bool loadingProgress = true;

  Color appBarActionColor = ColorConfig.defaultWhite;

  List writePosts = [];
  List followList = [];

  Map<String, dynamic> myProfileData = {};

  @override
  void initState() {
    super.initState();

    customScrollViewController = ScrollController();

    sliverTabBarController = TabController(
      length: 2,
      vsync: this,  // vsync에 this 형태로 전달해줘야 애니메이션이 활성화됨
    );
    sliverTabBarController.addListener(handleTabSelection);
    
    getAppVersion().then((value) {
      setState(() {
        appVersion = value;
      });
    });

    initializeAPI();
  }

  Future<void> initializeAPI() async {
    Future.wait([
      MainMyProfileAPI().myProfile(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
        setState(() {
          myProfileData = value.result['data'];
        });
      }),
      MyWritingPostAPI().post(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
        setState(() {
          writePosts = value.result['data'];
        });
      }),
      FollowListAPI().followList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
        setState(() {
          followList = value.result['data'];
        });
      }),
    ]).then((_) {
      setState(() {
        loadingProgress = false;
      });
    });
  }

  void handleTabSelection() {
    if (sliverTabBarController.indexIsChanging || sliverTabBarController.index != currentTabIndex) {
      setState(() {
        currentTabIndex = sliverTabBarController.index;
      });
    }
  }

  // sliver appbar 축소 or 확대 체크 함수
  bool get isSliverAppBarExpanded {
    return customScrollViewController.hasClients && customScrollViewController.offset > kToolbarHeight; //kExpandedHeight - kToolbarHeight;
  }

  void changeAppBarActionColor() {
    setState(() {
      if (isExpandedAppBar) {
        appBarActionColor = ColorConfig.defaultBlack;
      } else {
        appBarActionColor = ColorConfig.defaultWhite;
      }
    });
  }

  Future<String> getAppVersion() async {
    dynamic yaml = await rootBundle.loadString('pubspec.yaml');
    dynamic localYaml = loadYaml(yaml);

    if (Platform.isAndroid) {
      return localYaml['version'].toString().split('+')[0];
    } else {
      return localYaml['ios_version'].toString().split('+')[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      body: SafeArea(
        child: loadingProgress == false ? CustomScrollView(
          controller: customScrollViewController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            // sliver appbar
            SliverAppBar(
              toolbarHeight: const ig-publicAppBar().preferredSize.height,
              expandedHeight: const ig-publicAppBar().preferredSize.height + 142.0.w,
              pinned: true,
              elevation: 0.0,
              backgroundColor: ColorConfig().white(),
              leading: ig-publicAppBarLeading(
                press: widget.isNavigator == false ? () {} : () => Navigator.pop(context),
                using: widget.isNavigator == false ? false : true,
                iconColor: isExpandedAppBar ? ColorConfig().dark() : ColorConfig().white(),
              ),
              flexibleSpace: sliverAppBarFlexibleSpaceWidget(),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, 'editProfile', arguments: {
                      'profile_info': myProfileData,
                    }).then((value) {
                      // print(value);
                    });
                  },
                  icon: SVGBuilder(
                    image: 'assets/icon/edit.svg',
                    color: isExpandedAppBar ? ColorConfig().dark() : ColorConfig().white(),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    if (_debounce?.isActive ?? false) _debounce!.cancel();

                    _debounce = Timer(const Duration(milliseconds: 300), () async {
                      shareBuilder(context, type: 'user', index: -1);
                    });
                  },
                  icon: SVGBuilder(
                    image: 'assets/icon/share.svg',
                    color: isExpandedAppBar ? ColorConfig().dark() : ColorConfig().white(),
                  ),
                ),
              ],
            ),
            // tabbar sliver header
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverAppBarDelegate(
                TabBar(
                  controller: sliverTabBarController,
                  isScrollable: false,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  labelColor: ColorConfig().dark(),
                  labelStyle: TextStyle(
                    fontSize: 14.0.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  unselectedLabelColor: ColorConfig().gray3(),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 14.0.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  indicator: CustomTabIndicator(
                    color: ColorConfig().dark(),
                    height: 4.0,
                    tabPosition: TabPosition.bottom,
                    horizontalPadding: 12.0,
                  ),
                  tabs: const [
                    Tab(
                      text: TextConstant.myProfileMenu,
                    ),
                    Tab(
                      text: TextConstant.myProfileFeed,
                    ),
                  ],
                ),
                /** isSliverAppBarExpanded */ false,
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  width: MediaQuery.of(context).size.width,
                  color: ColorConfig().white(),
                  child: [
                    // 나의 메뉴 탭
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 내 지갑영역
                        Container(
                          color: ColorConfig().gray1(),
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                          child: Column(
                            children: [
                              // ig-public머니, 충전하기, ig-public랭킹, 티켓팅 영역
                              Container(
                                margin: const EdgeInsets.only(bottom: 8.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6.0.r),
                                ),
                                child: Column(
                                  children: [
                                    // ig-public머니, ig-public포인트 영역
                                    moneyOrPointWidget(),
                                    // ig-public 랭킹 영역
                                    InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(context, 'rankingList');
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 16.0),
                                        decoration: BoxDecoration(
                                          color: ColorConfig().white(),
                                          borderRadius: BorderRadius.circular(4.0.r),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Image(
                                                  image: myProfileData['rank'] == 1
                                                    ? const AssetImage('assets/img/rank-m.png')
                                                    : myProfileData['rank'] == 2
                                                      ? const AssetImage('assets/img/rank-d.png')
                                                      : myProfileData['rank'] == 3
                                                        ? const AssetImage('assets/img/rank-pl.png')
                                                        : myProfileData['rank'] == 4
                                                          ? const AssetImage('assets/img/rank-r.png')
                                                          : myProfileData['rank'] == 5
                                                            ? const AssetImage('assets/img/rank-g.png')
                                                            : myProfileData['rank'] == 6
                                                              ? const AssetImage('assets/img/rank-s.png')
                                                              : const AssetImage('assets/img/rank-w.png'),
                                                  width: 16.0.w,
                                                  height: 16.0.w,
                                                  filterQuality: FilterQuality.high,
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(left: 8.0),
                                                  child: CustomTextBuilder(
                                                    text: TextConstant.ig-publicRank,
                                                    fontColor: ColorConfig().dark(),
                                                    fontSize: 14.0.sp,
                                                    fontWeight: FontWeight.w400,
                                                    height: null,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(right: 4.0),
                                                  child: CustomTextBuilder(
                                                    text: myProfileData['rank'] == 1
                                                      ? '마스터'
                                                      : myProfileData['rank'] == 2
                                                        ? '다이아'
                                                        : myProfileData['rank'] == 3
                                                          ? '플래티넘'
                                                          : myProfileData['rank'] == 4
                                                            ? '로얄'
                                                            : myProfileData['rank'] == 5
                                                              ? '골드'
                                                              : myProfileData['rank'] == 6
                                                                ? '실버'
                                                                : '화이트',
                                                    fontColor: ColorConfig().primary(),
                                                    fontSize: 12.0.sp,
                                                    fontWeight: FontWeight.w400,
                                                    height: null,
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
                        // 티켓팅 영역
                        Container(
                          color: ColorConfig().white(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 타이틀 영역
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                                child: CustomTextBuilder(
                                  text: TextConstant.ticketingTitle,
                                  fontColor: ColorConfig().dark(),
                                  fontSize: 14.0.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              // 내역 영역
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // 티켓내역
                                  myHistoriesWidget(
                                    image: 'assets/icon/ticket.svg',
                                    text: TextConstant.ticketHistory,
                                    // useAmount: true,
                                    // amount: myProfileData['ticket_count'],
                                    press: () {
                                      Navigator.pushNamed(context, 'ticketHistory', arguments: {
                                        "tabIndex": 0,
                                      });
                                    },
                                  ),
                                  // // 공연 히스토리
                                  // myHistoriesWidget(
                                  //   image: 'assets/icon/ticket-history.svg',
                                  //   text: TextConstant.showHistory,
                                  //   press: () {
                                  //     Navigator.pushNamed(context, 'showHistory');
                                  //   },
                                  // ),
                                  // 선물함
                                  myHistoriesWidget(
                                    image: 'assets/icon/gift-box-p.svg',
                                    text: TextConstant.giftBox,
                                    press: () {
                                      Navigator.pushNamed(context, 'giftBox');
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // divider
                        Container(
                          height: 8.0,
                          color: ColorConfig().gray1(),
                        ),
                        myActivityWidget(
                          text: TextConstant.notice,
                          press: () {
                            Navigator.pushNamed(context, 'noticeList');
                          },
                        ),
                        myActivityWidget(
                          text: TextConstant.couponBox,
                          press: () {
                            Navigator.pushNamed(context, 'couponBox');
                          },
                        ),
                        myActivityWidget(
                          text: TextConstant.faq,
                          press: () {
                            Navigator.pushNamed(context, 'faqList');
                          },
                        ),
                        myActivityWidget(
                          text: TextConstant.appSetting,
                          rightRow: true,
                          rightText: true,
                          press: () {
                            Navigator.pushNamed(context, 'appSettingList');
                          },
                        ),
                        myActivityWidget(
                          text: TextConstant.chatConsultation,
                          press: () {
                            getChannelTalk(
                              nickname: myProfileData['nick'],
                              name: myProfileData['name'],
                              email: myProfileData['email'],
                              phoneNumber: myProfileData['phone'],
                            );
                          },
                        ),
                        myActivityWidget(
                          text: TextConstant.blacklist,
                          press: () {
                            Navigator.pushNamed(context, 'blacklist');
                          },
                        ),
                        myActivityWidget(
                          text: TextConstant.logout,
                          press: () {
                            PopupBuilder(
                              title: TextConstant.logout,
                              content: TextConstant.logoutContent,
                              actions: [
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
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
                                            text: TextConstant.cancel,
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

                                        await SecureStorageConfig().storage.delete(key: 'login_type');
                                        await SecureStorageConfig().storage.delete(key: 'token_status');
                                        await SecureStorageConfig().storage.delete(key: 'access_token');
                                        await SecureStorageConfig().storage.delete(key: 'refresh_token');
                                        await SecureStorageConfig().storage.delete(key: 'is_auth');

                                        // ignore: use_build_context_synchronously
                                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const ig-publicLoginScreen()), (route) => false);
                                      },
                                      child: Container(
                                        width: (MediaQuery.of(context).size.width - 120.0.w) / 2,
                                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                                        decoration: BoxDecoration(
                                          color: ColorConfig().accent(),
                                          borderRadius: BorderRadius.circular(4.0.r),
                                        ),
                                        child: Center(
                                          child: CustomTextBuilder(
                                            text: TextConstant.logout,
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
                        ),
                        const SizedBox(height: 62.0),
                      ],
                    ),
                    // 나의 피드 탭
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          color: ColorConfig().gray1(),
                          child: Column(
                            children: [
                              // // 나의 뱃지 타이틀 영역
                              // feedContentsTitleWidget(text: TextConstant.myBadge, count: 4),
                              // // 뱃지 영역
                              // badgeListWidget(),
                              // 팔로우한 아티스트 타이틀 영역
                              feedContentsTitleWidget(text: TextConstant.followCommunity, count: followList.length),
                              // 팔로우한 아티스트 리스트 영역
                              followArtistListWidget(),
                              // empty space
                              const SizedBox(height: 24.0),
                              // 저장된 게시물 영역
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, 'bookmarkPost');
                                },
                                child: Container(
                                  color: ColorConfig().white(),
                                  margin: const EdgeInsets.only(bottom: 8.0),
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(right: 4.0),
                                            child: SVGBuilder(
                                              image: 'assets/icon/bookmark-fill.svg',
                                              width: 20.0.w,
                                              height: 20.0.w,
                                              color: ColorConfig().dark(),
                                            ),
                                          ),
                                          CustomTextBuilder(
                                            text: TextConstant.bookmarkPost,
                                            fontColor: ColorConfig().dark(),
                                            fontSize: 16.0.sp,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ],
                                      ),
                                      SVGBuilder(
                                        image: 'assets/icon/arrow_right_bold.svg',
                                        width: 20.0.w,
                                        height: 20.0.w,
                                        color: ColorConfig().dark(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // sorting 버튼 영역
                        sortingAreaWidget(),
                        // 피드리스트 영역
                        Container(
                          color: ColorConfig().gray1(),
                          child: Column(
                            children: List.generate(writePosts.length, (index) {
                              if (writePosts[index]['type'] == 'R' || writePosts[index]['type'] == 'T') {
                                return MainCommunityWidgetBuilder().showReviewList(context, data: [writePosts[index]], onProfile: true);
                              } else {
                                return MainCommunityWidgetBuilder().feedList(context, data: [writePosts[index]], onProfile: true);
                              }
                            }),
                          ),
                        ),
                      ],
                    ),
                  ][currentTabIndex],
                )
              ]),
            ),
            // SliverFillRemaining(
            //   child: Container(
            //     width: MediaQuery.of(context).size.width,
            //     color: ColorConfig().white(),
            //     child: TabBarView(
            //       controller: sliverTabBarController,
            //       children: [
            //         Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             // 내 지갑영역
            //             Padding(
            //               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            //               child: Container(
            //                 decoration: BoxDecoration(
            //                   color: ColorConfig().gray1(),
            //                   borderRadius: BorderRadius.circular(8.0.r),
            //                   boxShadow: [
            //                     BoxShadow(
            //                       offset: const Offset(0.0, 1.0),
            //                       blurRadius: 4.0,
            //                       color: ColorConfig.defaultBlack.withOpacity(0.06),
            //                     ),
            //                   ],
            //                 ),
            //                 child: Column(
            //                   children: [
            //                     // ig-public 머니, 포인트 영역
            //                     Padding(
            //                       padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
            //                       child: Row(
            //                         children: [
            //                           // ig-public 머니
            //                           Expanded(
            //                             child: Column(
            //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                               children: [
            //                                 Row(
            //                                   children: [
            //                                     CustomTextBuilder(
            //                                       text: TextConstant.ig-publicMoney,
            //                                       fontColor: ColorConfig().dark(),
            //                                       fontSize: 12.0.sp,
            //                                       fontWeight: FontWeight.w700,
            //                                     ),
            //                                     SVGBuilder(
            //                                       image: 'assets/icon/arrow_right_light.svg',
            //                                       width: 16.0.w,
            //                                       height: 16.0.w,
            //                                       color: ColorConfig().gray3(),
            //                                     ),
            //                                   ],
            //                                 ),
            //                                 Row(
            //                                   children: [
            //                                     Container(
            //                                       margin: const EdgeInsets.only(right: 4.0),
            //                                       child: SVGStringBuilder(
            //                                         image: 'assets/icon/money_won.svg',
            //                                         width: 16.0.w,
            //                                         height: 16.0.w,
            //                                       ),
            //                                     ),
            //                                     CustomTextBuilder(
            //                                       text: '999,000',
            //                                       fontColor: ColorConfig.wonIconColor,
            //                                       fontSize: 16.0.sp,
            //                                       fontWeight: FontWeight.w800,
            //                                     ),
            //                                   ],
            //                                 ),
            //                               ],
            //                             ),
            //                           ),
            //                           // ig-public 포인트
            //                           Expanded(
            //                             child: Column(
            //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                               children: [
            //                                 Row(
            //                                   children: [
            //                                     CustomTextBuilder(
            //                                       text: TextConstant.ig-publicPoint,
            //                                       fontColor: ColorConfig().dark(),
            //                                       fontSize: 12.0.sp,
            //                                       fontWeight: FontWeight.w700,
            //                                     ),
            //                                     SVGBuilder(
            //                                       image: 'assets/icon/arrow_right_light.svg',
            //                                       width: 16.0.w,
            //                                       height: 16.0.w,
            //                                       color: ColorConfig().gray3(),
            //                                     ),
            //                                   ],
            //                                 ),
            //                                 Row(
            //                                   children: [
            //                                     Container(
            //                                       margin: const EdgeInsets.only(right: 4.0),
            //                                       child: SVGStringBuilder(
            //                                         image: 'assets/icon/money_point.svg',
            //                                         width: 16.0.w,
            //                                         height: 16.0.w,
            //                                       ),
            //                                     ),
            //                                     CustomTextBuilder(
            //                                       text: '999,000',
            //                                       fontColor: ColorConfig.pointIconColor,
            //                                       fontSize: 16.0.sp,
            //                                       fontWeight: FontWeight.w800,
            //                                     ),
            //                                   ],
            //                                 ),
            //                               ],
            //                             ),
            //                           ),
            //                         ],
            //                       ),
            //                     ),
            //                     // divider
            //                     Container(
            //                       height: 1.0,
            //                       margin: const EdgeInsets.symmetric(horizontal: 12.0),
            //                       color: ColorConfig().gray2(),
            //                     ),
            //                     // 내역
            //                     Row(
            //                       children: [
            //                         // 쿠폰함
            //                         Container(
            //                           padding: const EdgeInsets.symmetric(vertical: 13.0),
            //                           width: (MediaQuery.of(context).size.width - 32.0) / 3,
            //                           child: Column(
            //                             children: [
            //                               Container(
            //                                 width: 36.0.w,
            //                                 height: 36.0.w,
            //                                 color: Colors.red,
            //                               ),
            //                               Row(
            //                                 mainAxisAlignment: MainAxisAlignment.center,
            //                                 children: [
            //                                   CustomTextBuilder(
            //                                     text: TextConstant.couponBox,
            //                                     fontColor: ColorConfig().gray5(),
            //                                     fontSize: 12.0.sp,
            //                                     fontWeight: FontWeight.w700,
            //                                   ),
            //                                   CustomTextBuilder(
            //                                     text: '5',
            //                                     fontColor: ColorConfig().primary(),
            //                                     fontSize: 12.0.sp,
            //                                     fontWeight: FontWeight.w800,
            //                                   ),
            //                                 ],
            //                               ),
            //                             ],
            //                           ),
            //                         ),
            //                         // 티켓내역
            //                         Container(
            //                           padding: const EdgeInsets.symmetric(vertical: 13.0),
            //                           width: (MediaQuery.of(context).size.width - 32.0) / 3,
            //                           child: Column(
            //                             children: [
            //                               Container(
            //                                 width: 36.0.w,
            //                                 height: 36.0.w,
            //                                 color: Colors.red,
            //                               ),
            //                               Row(
            //                                 mainAxisAlignment: MainAxisAlignment.center,
            //                                 children: [
            //                                   CustomTextBuilder(
            //                                     text: TextConstant.ticketHistory,
            //                                     fontColor: ColorConfig().gray5(),
            //                                     fontSize: 12.0.sp,
            //                                     fontWeight: FontWeight.w700,
            //                                   ),
            //                                   CustomTextBuilder(
            //                                     text: '5',
            //                                     fontColor: ColorConfig().primary(),
            //                                     fontSize: 12.0.sp,
            //                                     fontWeight: FontWeight.w800,
            //                                   ),
            //                                 ],
            //                               ),
            //                             ],
            //                           ),
            //                         ),
            //                         // 쇼핑내역
            //                         Container(
            //                           padding: const EdgeInsets.symmetric(vertical: 13.0),
            //                           width: (MediaQuery.of(context).size.width - 32.0) / 3,
            //                           child: Column(
            //                             children: [
            //                               Container(
            //                                 width: 36.0.w,
            //                                 height: 36.0.w,
            //                                 color: Colors.red,
            //                               ),
            //                               CustomTextBuilder(
            //                                 text: TextConstant.shoppingHistory,
            //                                 fontColor: ColorConfig().gray5(),
            //                                 fontSize: 12.0.sp,
            //                                 fontWeight: FontWeight.w700,
            //                               ),
            //                             ],
            //                           ),
            //                         ),
            //                       ],
            //                     ),
            //                     // 내역
            //                     Row(
            //                       children: [
            //                         // 선물함
            //                         Container(
            //                           padding: const EdgeInsets.symmetric(vertical: 13.0),
            //                           width: (MediaQuery.of(context).size.width - 32.0) / 3,
            //                           child: Column(
            //                             children: [
            //                               Container(
            //                                 width: 36.0.w,
            //                                 height: 36.0.w,
            //                                 color: Colors.red,
            //                               ),
            //                               CustomTextBuilder(
            //                                 text: TextConstant.giftBox,
            //                                 fontColor: ColorConfig().gray5(),
            //                                 fontSize: 12.0.sp,
            //                                 fontWeight: FontWeight.w700,
            //                               ),
            //                             ],
            //                           ),
            //                         ),
            //                         // ig-public 랭킹
            //                         Container(
            //                           padding: const EdgeInsets.symmetric(vertical: 13.0),
            //                           width: (MediaQuery.of(context).size.width - 32.0) / 3,
            //                           child: Column(
            //                             children: [
            //                               Container(
            //                                 width: 36.0.w,
            //                                 height: 36.0.w,
            //                                 color: Colors.red,
            //                               ),
            //                               CustomTextBuilder(
            //                                 text: TextConstant.ig-publicRank,
            //                                 fontColor: ColorConfig().gray5(),
            //                                 fontSize: 12.0.sp,
            //                                 fontWeight: FontWeight.w700,
            //                               ),
            //                             ],
            //                           ),
            //                         ),
            //                         // 결제내역
            //                         Container(
            //                           padding: const EdgeInsets.symmetric(vertical: 13.0),
            //                           width: (MediaQuery.of(context).size.width - 32.0) / 3,
            //                           child: Column(
            //                             children: [
            //                               Container(
            //                                 width: 36.0.w,
            //                                 height: 36.0.w,
            //                                 color: Colors.red,
            //                               ),
            //                               CustomTextBuilder(
            //                                 text: TextConstant.paymentHistory,
            //                                 fontColor: ColorConfig().gray5(),
            //                                 fontSize: 12.0.sp,
            //                                 fontWeight: FontWeight.w700,
            //                               ),
            //                             ],
            //                           ),
            //                         ),
            //                       ],
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //             ),
            //             // 나의 활동 타이틀 영역
            //             Padding(
            //               padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            //               child: CustomTextBuilder(
            //                 text: TextConstant.myActivity,
            //                 fontColor: ColorConfig().dark(),
            //                 fontSize: 16.0.sp,
            //                 fontWeight: FontWeight.w800,
            //               ),
            //             ),
            //             // 나의 활동 리스트 영역
            //             myActivityWidget(text: TextConstant.myBadge, rightRow: true),
            //             myActivityWidget(text: TextConstant.myProfile),
            //             myActivityWidget(text: TextConstant.showHistory),
            //             // divider
            //             Container(
            //               height: 8.0,
            //               color: ColorConfig().gray1(),
            //             ),
            //             myActivityWidget(text: TextConstant.notice),
            //             myActivityWidget(text: TextConstant.faq),
            //             myActivityWidget(text: TextConstant.appSetting),
            //             myActivityWidget(text: TextConstant.chatConsultation),
            //           ],
            //         ),
            //         Container(),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ) : const LoadingProgressBuilder(),
      ),
    );
  }

  // sliver appbar flexible widget
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
                    color: myProfileData['background'] == null ? ColorConfig().gray2() : null,
                    image: myProfileData['background'] != null ? DecorationImage(
                      image: NetworkImage(myProfileData['background']),
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ) : null,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      color: ColorConfig.defaultBlack.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
              // contents data
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 24.0),
                margin: EdgeInsets.only(top: const ig-publicAppBar().preferredSize.height),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 72.0.w,
                      height: 72.0.w,
                      margin: const EdgeInsets.only(right: 16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(36.0.r),
                        image: myProfileData['image'] == null
                          ? const DecorationImage(
                              image: AssetImage('assets/img/profile_default.png'),
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            )
                          : DecorationImage(
                              image: NetworkImage(myProfileData['image']),
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            ),
                      ),
                    ),
                    Expanded(
                      child: myProfileData.isNotEmpty ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextBuilder(
                            text: '${myProfileData['nick']}',
                            fontColor: ColorConfig().white(),
                            fontSize: 16.0.sp,
                            fontWeight: FontWeight.w800,
                            height: null,
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 8.0, bottom: 11.0),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(context, 'followList', arguments: {
                                      'click': 'follower',
                                    }).then((rt) async {
                                      MainMyProfileAPI().myProfile(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
                                        setState(() {
                                          myProfileData = value.result['data'];
                                        });
                                      });
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(right: 4.0),
                                        child: CustomTextBuilder(
                                          text: TextConstant.follower,
                                          fontColor: ColorConfig().primaryLight2(),
                                          fontSize: 14.0.sp,
                                          fontWeight: FontWeight.w400,
                                          height: null,
                                        ),
                                      ),
                                      CustomTextBuilder(
                                        text: '${SetIntl().numberFormat(myProfileData['following_count'])}',
                                        fontColor: ColorConfig().gray1(),
                                        fontSize: 14.0.sp,
                                        fontWeight: FontWeight.w400,
                                        height: null,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 16.0),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, 'followList', arguments: {
                                        'click': 'following',
                                      }).then((rt) async {
                                        MainMyProfileAPI().myProfile(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
                                          setState(() {
                                            myProfileData = value.result['data'];
                                          });
                                        });
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(right: 4.0),
                                          child: CustomTextBuilder(
                                            text: TextConstant.following,
                                            fontColor: ColorConfig().primaryLight2(),
                                            fontSize: 14.0.sp,
                                            fontWeight: FontWeight.w400,
                                            height: null,
                                          ),
                                        ),
                                        CustomTextBuilder(
                                          text: '${SetIntl().numberFormat(myProfileData['follower_count'])}',
                                          fontColor: ColorConfig().gray1(),
                                          fontSize: 14.0.sp,
                                          fontWeight: FontWeight.w400,
                                          height: null,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CustomTextBuilder(
                            text: myProfileData['description'] != null ? '${myProfileData['description']}' : TextConstant.selfIntroducePlease,
                            fontColor: myProfileData['description'] != null ? ColorConfig().white() : ColorConfig().borderGray1(),
                            fontSize: 12.0.sp,
                            fontWeight: FontWeight.w700,
                            height: null,
                          ),
                        ],
                      ) : Container(),
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

  // 내 지갑 위젯
  Widget moneyOrPointWidget() {
    if (myProfileData.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            // ig-public머니 영역
            Container(
              // width: (MediaQuery.of(context).size.width - 48.0) / 2,
              width: (MediaQuery.of(context).size.width - 40.0),
              decoration: BoxDecoration(
                color: ColorConfig().white(),
                borderRadius: BorderRadius.circular(6.0.r),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.5),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, 'paymentHistory');
                      },
                      child: Row(
                        children: [
                          CustomTextBuilder(
                            text: TextConstant.ig-publicMoney,
                            fontColor: ColorConfig().dark(),
                            fontSize: 14.0.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 2.0),
                            child: SVGBuilder(
                              image: 'assets/icon/arrow_right_light.svg',
                              width: 12.0.w,
                              height: 16.0.w,
                              color: ColorConfig().gray3(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 보유수량 영역
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 4.0),
                          child: SVGStringBuilder(
                            image: 'assets/icon/money_won.svg',
                            width: 16.0.w,
                            height: 16.0.w,
                          ),
                        ),
                        CustomTextBuilder(
                          text: '${SetIntl().numberFormat(myProfileData['money'])}',
                          fontColor: ColorConfig.wonIconColor,
                          fontSize: 16.0.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                    ),
                  ),
                  // 버튼 영역
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, 'ig-publicMoneyPurchase');
                      },
                      child: Container(
                        // padding: const EdgeInsets.symmetric(vertical: 8.0),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          color: ColorConfig.wonIconColor,
                          borderRadius: BorderRadius.circular(4.0.r),
                        ),
                        child: Center(
                          child: CustomTextBuilder(
                            text: TextConstant.purchaseChargeMethod,
                            fontColor: ColorConfig().white(),
                            fontSize: 12.0.sp,
                            fontWeight: FontWeight.w400,
                            height: null,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // // ig-public 포인트 영역
            // Container(
            //   width: (MediaQuery.of(context).size.width - 48.0) / 2,
            //   decoration: BoxDecoration(
            //     color: ColorConfig().white(),
            //     borderRadius: BorderRadius.circular(6.0.r),
            //   ),
            //   child: Column(
            //     children: [
            //       Padding(
            //         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.5),
            //         child: Row(
            //           children: [
            //             CustomTextBuilder(
            //               text: TextConstant.ig-publicPoint,
            //               fontColor: ColorConfig().dark(),
            //               fontSize: 14.0.sp,
            //               fontWeight: FontWeight.w400,
            //               height: 1.2,
            //             ),
            //             Container(
            //               margin: const EdgeInsets.only(left: 2.0),
            //               child: SVGBuilder(
            //                 image: 'assets/icon/arrow_right_light.svg',
            //                 width: 12.0.w,
            //                 height: 16.0.w,
            //                 color: ColorConfig().gray3(),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //       // 보유수량 영역
            //       Padding(
            //         padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //         child: Row(
            //           children: [
            //             Container(
            //               margin: const EdgeInsets.only(right: 4.0),
            //               child: SVGStringBuilder(
            //                 image: 'assets/icon/money_point.svg',
            //                 width: 16.0.w,
            //                 height: 16.0.w,
            //               ),
            //             ),
            //             CustomTextBuilder(
            //               text: '${SetIntl().numberFormat(myProfileData['point'])}',
            //               fontColor: ColorConfig.pointIconColor,
            //               fontSize: 16.0.sp,
            //               fontWeight: FontWeight.w400,
            //             ),
            //           ],
            //         ),
            //       ),
            //       // 버튼 영역
            //       Padding(
            //         padding: const EdgeInsets.all(16.0),
            //         child: Container(
            //           padding: const EdgeInsets.symmetric(vertical: 8.0),
            //           decoration: BoxDecoration(
            //             color: ColorConfig().primaryLight(),
            //             borderRadius: BorderRadius.circular(4.0.r),
            //           ),
            //           child: Center(
            //             child: CustomTextBuilder(
            //               text: TextConstant.getReward,
            //               fontColor: ColorConfig().white(),
            //               fontSize: 12.0.sp,
            //               fontWeight: FontWeight.w400,
            //               height: null,
            //             ),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  ///
  /// 내역 위젯
  /// [amount] 사용시 [useAmount] 필수
  /// 
  Widget myHistoriesWidget({Function()? press, required String image, required String text, bool useAmount = false, int? amount}) {
    return InkWell(
      onTap: press,
      child: Container(
        padding: const EdgeInsets.only(bottom: 24.0),
        // width: (MediaQuery.of(context).size.width - 32.0) / 3,
        width: (MediaQuery.of(context).size.width - 32.0) / 2,
        child: Column(
          children: [
            SVGStringBuilder(
              image: image,
              width: 36.0.w,
              height: 36.0.w,
            ),
            !useAmount
              ? CustomTextBuilder(
                  text: text,
                  fontColor: ColorConfig().gray5(),
                  fontSize: 12.0.sp,
                  fontWeight: FontWeight.w400,
                  height: 0.0,
                )
              : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextBuilder(
                    text: text,
                    fontColor: ColorConfig().gray5(),
                    fontSize: 12.0.sp,
                    fontWeight: FontWeight.w400,
                    height: 0.0,
                  ),
                  CustomTextBuilder(
                    text: ' $amount',
                    fontColor: ColorConfig().primary(),
                    fontSize: 12.0.sp,
                    fontWeight: FontWeight.w400,
                    height: 0.0,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  ///
  /// 나의 활동 위젯
  /// [rightText] 사용시 [rightRow]를 같이 사용해줘야 활성화
  /// 
  Widget myActivityWidget({required String text, Function()? press, bool rightRow = false, bool rightText = false}) {
    if (rightRow) {
      return InkWell(
        onTap: press,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextBuilder(
                text: text,
                fontColor: ColorConfig.defaultBlack,
                fontSize: 14.0.sp,
                fontWeight: FontWeight.w400,
              ),
              rightText == false
                ? Container()
                : Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 4.0),
                      child: CustomTextBuilder(
                        text: 'v$appVersion 업데이트 필요',
                        fontColor: ColorConfig().gray3(),
                        fontSize: 12.0.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SVGBuilder(
                      image: 'assets/icon/arrow_right_light.svg',
                      width: 16.0.w,
                      height: 16.0.w,
                      color: ColorConfig().gray3(),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    }
    
    return InkWell(
      onTap: press,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomTextBuilder(
              text: text,
              fontColor: text == TextConstant.logout ? ColorConfig().accent() : ColorConfig.defaultBlack,
              fontSize: 14.0.sp,
              fontWeight: FontWeight.w400,
            ),
            SVGBuilder(
              image: 'assets/icon/arrow_right_light.svg',
              width: 20.0.w,
              height: 20.0.w,
              color: ColorConfig().gray3(),
            ),
          ],
        ),
      ),
    );
  }

  // 뱃지 리스트 위젯
  Widget badgeListWidget() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, 'badgeList');
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 48.0.w
          ),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Container(
                width: 48.0.w,
                height: 48.0.w,
                margin: const EdgeInsets.only(right: 12.0),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6.0.r),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // 나의피드 콘텐츠 타이틀 위젯
  Widget feedContentsTitleWidget({required String text, required int count}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      margin: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          CustomTextBuilder(
            text: text,
            fontColor: ColorConfig().dark(),
            fontSize: 16.0.sp,
            fontWeight: FontWeight.w800,
            height: null,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: CustomTextBuilder(
              text: '$count',
              fontColor: ColorConfig().primary(),
              fontSize: 16.0.sp,
              fontWeight: FontWeight.w800,
              height: null,
            ),
          ),
          SVGBuilder(
            image: 'assets/icon/arrow_right_light.svg',
            width: 12.0.w,
            height: 16.0.w,
            color: ColorConfig().primary(),
          ),
        ],
      ),
    );
  }

  // 팔로우한 아티스트 리스트 위젯
  Widget followArtistListWidget() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 48.0.w,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        itemCount: followList.length,
        itemBuilder: (context, index) {
          return Container(
            width: 48.0.w,
            height: 48.0.w,
            margin: index != followList.length - 1 ? const EdgeInsets.only(right: 8.0) : null,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.0.r),
              image: followList[index]['image'] != null
              ? DecorationImage(
                  image: NetworkImage(followList[index]['image']),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                )
              : const DecorationImage(
                  image: AssetImage('assets/img/profile_default.png'),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
            ),
          );
        },
      ),
    );
  }

  Widget sortingAreaWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      color: ColorConfig().white(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomTextBuilder(
            text: TextConstant.writePostForMe,
            fontColor: ColorConfig().dark(),
            fontSize: 16.0.sp,
            fontWeight: FontWeight.w800,
            height: null,
          ),
          // Container(
          //   padding: const EdgeInsets.fromLTRB(10.0, 8.0, 8.0, 8.0),
          //   decoration: BoxDecoration(
          //     color: ColorConfig().white(),
          //     border: Border.all(
          //       width: 1.0,
          //       color: ColorConfig().gray2(),
          //     ),
          //     borderRadius: BorderRadius.circular(4.0.r),
          //   ),
          //   child: Row(
          //     children: [
          //       Container(
          //         margin: const EdgeInsets.only(right: 4.0),
          //         child: CustomTextBuilder(
          //           text: '최신순',
          //           fontColor: ColorConfig().gray5(),
          //           fontSize: 12.0.sp,
          //           fontWeight: FontWeight.w400,
          //           height: null,
          //         ),
          //       ),
          //       SVGBuilder(
          //         image: 'assets/icon/arrow_down_light.svg',
          //         width: 16.0.w,
          //         height: 16.0.w,
          //         color: ColorConfig().gray5(),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}