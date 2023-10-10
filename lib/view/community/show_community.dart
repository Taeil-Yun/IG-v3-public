import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/api/community/show_community.dart';
import 'package:ig-public_v3/api/follow/follow_add_cancel.dart';
import 'package:ig-public_v3/api/main/main_community.dart';
import 'package:ig-public_v3/costant/build_config.dart';

import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/src/route_argument.dart';
import 'package:ig-public_v3/util/set_intl.dart';
import 'package:ig-public_v3/util/url_launcher.dart';
import 'package:ig-public_v3/view/community/relative_video.dart';
import 'package:ig-public_v3/view/main/community_widget/widgets.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:ig-public_v3/widget/sliver_tabbar_widget.dart';

class ShowCommunityScreen extends StatefulWidget {
  const ShowCommunityScreen({super.key});

  @override
  State<ShowCommunityScreen> createState() => _ShowCommunityScreenState();
}

class _ShowCommunityScreenState extends State<ShowCommunityScreen> with TickerProviderStateMixin {
  late ScrollController customScrollViewController;
  late TabController sliverTabBarController;
  late Animation<double> animatedAction;
  late AnimationController animatedController;

  int currentTabIndex = 0;
  int showIndex = 0;

  bool isExpandedAppBar = false;

  Color appBarActionColor = ColorConfig.defaultWhite;

  List postList = [];
  List reviewList = [];
  List<dynamic> snsLinks = [
    {
      'link': null,
      'image': 'assets/icon/youtube.svg',
    },
    {
      'link': null,
      'image': 'assets/icon/facebook.svg',
    },
    {
      'link': null,
      'image': 'assets/icon/twitter.svg',
    },
    {
      'link': null,
      'image': 'assets/icon/instagram.svg'
    },
  ];

  Map<String, dynamic> showCummunityData = {};

  @override
  void initState() {
    super.initState();

    customScrollViewController = ScrollController();

    sliverTabBarController = TabController(
      length: 2,
      vsync: this,  // vsync에 this 형태로 전달해줘야 애니메이션이 활성화됨
    );
    sliverTabBarController.addListener(handleTabSelection);

    animatedController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    animatedAction = Tween<double>(begin: 1.0, end: 0.75).animate(animatedController);

    Future.delayed(Duration.zero, () {
      if (RouteGetArguments().getArgs(context)['show_index'] != null) {
        setState(() {
          showIndex = RouteGetArguments().getArgs(context)['show_index'];
        });
      }
    }).then((_) {
      initializeAPI();
    });
  }

  @override
  void dispose() {
    super.dispose();

    customScrollViewController.dispose();
    sliverTabBarController.dispose();
    animatedController.dispose();
  }

  void handleTabSelection() {
    if (sliverTabBarController.indexIsChanging || sliverTabBarController.index != currentTabIndex) {
      setState(() {
        currentTabIndex = sliverTabBarController.index;
      });
    }
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

  Future<void> initializeAPI() async {
    ShowCommunityAPI().showCommunity(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), showIndex: showIndex).then((value) {
      if (value.result['status'] == 1) {
        setState(() {
          showCummunityData = value.result['data'];
          snsLinks[0]['link'] = value.result['data']['youtube'];
          snsLinks[1]['link'] = value.result['data']['facebook'];
          snsLinks[2]['link'] = value.result['data']['twitter'];
          snsLinks[3]['link'] = value.result['data']['instagram'];
        });
      }
    });
    MainCommunityListAPI().communityList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), type: 1, showIndex: showIndex).then((value) {
      if (value.result['status'] == 1) {
        setState(() {
          postList = value.result['data'];
        });
      }
    });
    MainCommunityListAPI().communityList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), type: 2, showIndex: showIndex).then((value) {
      if (value.result['status'] == 1) {
        setState(() {
          reviewList = value.result['data'];
        });
      }
    });
  }

  // sliver appbar 축소 or 확대 체크 함수
  bool get isSliverAppBarExpanded {
    return customScrollViewController.hasClients && customScrollViewController.offset > kToolbarHeight; //kExpandedHeight - kToolbarHeight;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: showCummunityData.isNotEmpty ? SafeArea(
        child: CustomScrollView(
          controller: customScrollViewController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            // sliver appbar
            SliverAppBar(
              toolbarHeight: const ig-publicAppBar().preferredSize.height,
              expandedHeight: const ig-publicAppBar().preferredSize.height + 92.0 + 172.0.w + 16.0.sp + 48.0.w,
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
                    color: isExpandedAppBar ? ColorConfig().dark() : ColorConfig().white(),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: SVGBuilder(
                    image: 'assets/icon/more_vertical.svg',
                    color: isExpandedAppBar ? ColorConfig().dark() : ColorConfig().white(),
                  ),
                ),
              ],
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Column(
                  children: [
                    // 공연 커뮤니티 타이틀 영역
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.5),
                      decoration: BoxDecoration(
                        color: ColorConfig().white(),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6.0.r),
                          topRight: Radius.circular(6.0.r),
                        )
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomTextBuilder(
                                text: '${showCummunityData['name']} 커뮤니티',
                                fontColor: ColorConfig().dark(),
                                fontSize: 16.0.sp,
                                fontWeight: FontWeight.w900,
                              ),
                              InkWell(
                                onTap: () async {
                                  if (showCummunityData['is_follow'] == false) {
                                    FollowAddOrCancel().followApply(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), kind: 'f', type: 2, index: showIndex).then((value) {
                                      if (value.result['status'] == 1) {
                                        setState(() {
                                          showCummunityData['is_follow'] = true;
                                        });
                                      }
                                    });
                                  } else {
                                    FollowAddOrCancel().followApply(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), kind: 'u', type: 2, index: showIndex).then((value) {
                                      if (value.result['status'] == 1) {
                                        setState(() {
                                          showCummunityData['is_follow'] = false;
                                        });
                                      }
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                  decoration: BoxDecoration(
                                    color: showCummunityData['is_follow'] == false ? ColorConfig().primary() : ColorConfig().primaryLight(),
                                    borderRadius: BorderRadius.circular(4.0.r),
                                  ),
                                  child: Center(
                                    child: CustomTextBuilder(
                                      text: showCummunityData['is_follow'] == false ? TextConstant.follow : TextConstant.following,
                                      fontColor: ColorConfig().white(),
                                      fontSize: 13.0.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // 팔로워, 커뮤니티 랭킹 영역
                    Container(
                      margin: const EdgeInsets.only(top: 16.0),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          // 팔로워 영역
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 4.0),
                                  child: CustomTextBuilder(
                                    text: TextConstant.follower,
                                    fontColor: ColorConfig().gray4(),
                                    fontSize: 14.0.sp,
                                    fontWeight: FontWeight.w700,
                                    height: 1.0,
                                  ),
                                ),
                                CustomTextBuilder(
                                  text: '${SetIntl().numberFormat(showCummunityData['follow_count'])}',
                                  fontColor: ColorConfig().primary(),
                                  fontSize: 14.0.sp,
                                  fontWeight: FontWeight.w700,
                                  height: 1.0,
                                ),
                              ],
                            ),
                          ),
                          // // 커뮤니티 랭킹 영역
                          // Expanded(
                          //   child: Row(
                          //     children: [
                          //       Container(
                          //         margin: const EdgeInsets.only(right: 4.0),
                          //         child: CustomTextBuilder(
                          //           text: TextConstant.communityRank,
                          //           fontColor: ColorConfig().gray4(),
                          //           fontSize: 14.0.sp,
                          //           fontWeight: FontWeight.w700,
                          //           height: 1.0,
                          //         ),
                          //       ),
                          //       CustomTextBuilder(
                          //         text: '12위',
                          //         fontColor: ColorConfig().primary(),
                          //         fontSize: 14.0.sp,
                          //         fontWeight: FontWeight.w700,
                          //         height: 1.0,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    // empty space
                    Container(
                      height: 16.0,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1.0,
                            color: ColorConfig().gray1(),
                          ),
                        ),
                      ),
                    ),
                    // // 활동많은 회원 타이틀 영역
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    //   child: Row(
                    //     children: [
                    //       Container(
                    //         margin: const EdgeInsets.only(right: 4.0),
                    //         child: CustomTextBuilder(
                    //           text: TextConstant.manyActiveMember,
                    //           fontColor: ColorConfig().dark(),
                    //           fontSize: 16.0.sp,
                    //           fontWeight: FontWeight.w800,
                    //           height: 1.0,
                    //         ),
                    //       ),
                    //       SVGBuilder(
                    //         image: 'assets/icon/arrow_right_light.svg',
                    //         width: 12.0.w,
                    //         height: 16.0.w,
                    //         color: ColorConfig().primary(),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // // 활동많은 회원 리스트 영역
                    // Container(
                    //   height: 48.0.w,
                    //   margin: const EdgeInsets.only(top: 4.0),
                    //   child: ListView.builder(
                    //     scrollDirection: Axis.horizontal,
                    //     padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    //     itemCount: 6,
                    //     itemBuilder: (context, index) {
                    //       return Container(
                    //         width: 48.0.w,
                    //         height: 48.0.w,
                    //         margin: index != 5 ? const EdgeInsets.only(right: 8.0) : null,
                    //         decoration: BoxDecoration(
                    //           color: ColorConfig().gray2(),
                    //           border: Border.all(
                    //             width: 1.0,
                    //             color: ColorConfig().borderGray1(opacity: 0.3),
                    //           ),
                    //           borderRadius: BorderRadius.circular(24.0.r),
                    //           image: const DecorationImage(
                    //             image: AssetImage('assets/img/profile_default.png'),
                    //             fit: BoxFit.cover,
                    //             filterQuality: FilterQuality.high,
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),
                    // const SizedBox(height: 24.0),
                    // 관련 영상 타이틀 영역
                    showCummunityData['videos'].isNotEmpty ? InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RelativeVideoScreen(videos: showCummunityData['videos'])));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                        child: Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 4.0),
                              child: CustomTextBuilder(
                                text: TextConstant.relationshipVideo,
                                fontColor: ColorConfig().dark(),
                                fontSize: 16.0.sp,
                                fontWeight: FontWeight.w800,
                                height: 1.0,
                              ),
                            ),
                            SVGBuilder(
                              image: 'assets/icon/arrow_right_light.svg',
                              width: 12.0.w,
                              height: 16.0.w,
                              color: ColorConfig().gray4(),
                            ),
                          ],
                        ),
                      ),
                    ) : Container(),
                    // 관련 영상 리스트 영역
                    showCummunityData['videos'].isNotEmpty ? Container(
                      height: 90.0.w + 8.0 + (13.0.sp * 2),
                      margin: const EdgeInsets.only(top: 4.0),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        itemCount: showCummunityData['videos'].length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              UrlLauncherBuilder().launchURL(showCummunityData['videos'][index]['url']);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 160.0.w,
                                  height: 90.0.w,
                                  margin: index != 5 ? const EdgeInsets.only(right: 8.0) : null,
                                  decoration: BoxDecoration(
                                    color: showCummunityData['videos'][index]['thumbnail'] == null || showCummunityData['videos'][index]['thumbnail'] == false ? ColorConfig().gray2() : null,
                                    borderRadius: BorderRadius.circular(4.0.r),
                                    image: showCummunityData['videos'][index]['thumbnail'] != null || showCummunityData['videos'][index]['thumbnail'] != false ? DecorationImage(
                                      image: NetworkImage(showCummunityData['videos'][index]['thumbnail']),
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.high,
                                    ) : null,
                                  ),
                                  child: showCummunityData['videos'][index]['thumbnail'] == null || showCummunityData['videos'][index]['thumbnail'] == false ? Center(
                                    child: SVGBuilder(
                                      image: 'assets/icon/album.svg',
                                      width: 24.0.w,
                                      height: 24.0.w,
                                      color: ColorConfig().white(),
                                    ),
                                  ) : Container(),
                                ),
                                Container(
                                  width: 160.0.w,
                                  margin: const EdgeInsets.only(top: 8.0),
                                  child: CustomTextBuilder(
                                    text: '${showCummunityData['videos'][index]['title']}',
                                    fontColor: ColorConfig().dark(),
                                    fontSize: 12.0.sp,
                                    fontWeight: FontWeight.w700,
                                    height: 1.0,
                                    maxLines: 2,
                                    textOverflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ) : Container(),
                    showCummunityData['videos'].isNotEmpty ? Container(
                      height: 32.0,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1.0,
                            color: ColorConfig().gray1(),
                          ),
                        ),
                      ),
                    ) : Container(),
                  ],
                ),
              ]),
            ),
            // 게시물, 공연 후기 탭 영역
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
                      text: TextConstant.post,
                    ),
                    Tab(
                      text: TextConstant.review,
                    ),
                  ],
                ),
                /** isSliverAppBarExpanded */ false,
              ),
            ),
            // 피드 영역
            SliverList(
              delegate: SliverChildListDelegate([
                // CommunitySortingLayerWidget().sorting(context),
                Container(
                  color: ColorConfig().gray1(),
                  child: [
                    // 게시물 영역
                    MainCommunityWidgetBuilder().feedList(context, data: postList, type: 'S', typeIndex: showIndex),
                    // 공연 후기 영역
                    MainCommunityWidgetBuilder().feedList(context, data: reviewList, type: 'S', typeIndex: showIndex),
                  ][currentTabIndex],
                ),
                Container(
                  height: 62.0 + 16.0,
                  color: postList.isNotEmpty ? ColorConfig().gray1() : null,
                )
              ]),
            ),
          ],
        ),
      ) : Container(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          animatedController.animateTo(0.5, curve: Curves.linear);
          
          floatingWidget(context);
        },
        child: floatingButtonWidget(false),
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
          title: isExpandedAppBar ? AutoSizeText(
            '${showCummunityData['name']} 커뮤니티',
            style: TextStyle(
              color: ColorConfig().dark(),
              fontSize: 16.0.sp,
              fontWeight: FontWeight.w800
            ),
            maxLines: 1,
          ) : null,
          background: Stack(
            children: [
              // background
              ClipRect(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Container(
                  decoration: BoxDecoration(
                    color: showCummunityData['image'] == null ? ColorConfig().gray2() : null,
                    image: showCummunityData['image'] != null ? DecorationImage(
                      image: NetworkImage(showCummunityData['image']),
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
              Column(
                children: [
                  // 공연 커뮤니티 정보 영역
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(20.0),
                    margin: EdgeInsets.only(top: const ig-publicAppBar().preferredSize.height),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 공연 포스터 영역
                        Container(
                          width: 120.0.w,
                          height: 172.0.w,
                          margin: const EdgeInsets.only(right: 16.0),
                          decoration: BoxDecoration(
                            color: showCummunityData['image'] == null ? ColorConfig().gray2() : null,
                            borderRadius: BorderRadius.circular(4.0.r),
                            image: showCummunityData['image'] != null ? DecorationImage(
                              image: NetworkImage(showCummunityData['image']),
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            ) : null,
                          ),
                          child: showCummunityData['image'] == null ? Center(
                            child: SVGBuilder(
                              image: 'assets/icon/album.svg',
                              width: 24.0.w,
                              height: 24.0.w,
                              color: ColorConfig().white(),
                            ),
                          ) : Container(),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 172.0.w,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 공연 커뮤니티 제목 영역
                                Container(
                                  margin: const EdgeInsets.only(left: 4.0),
                                  child: CustomTextBuilder(
                                    text: '${showCummunityData['name']}',
                                    fontColor: ColorConfig().white(),
                                    fontSize: 16.0.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                // 연도 영역
                                showCummunityData['description'] != null ? Container(
                                  margin: const EdgeInsets.only(left: 4.0, top: 4.0),
                                  child: CustomTextBuilder(
                                    text: '${showCummunityData['description']}',
                                    fontColor: ColorConfig().white(),
                                    fontSize: 14.0.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ) : Container(),
                                // sns 버튼 영역
                                Container(
                                  margin: const EdgeInsets.only(left: 4.0, top: 10.0, bottom: 20.0),
                                  child: Wrap(
                                    children: List.generate(snsLinks.length, (index) {
                                      if (snsLinks[index]['link'] == null) {
                                        return Container();
                                      }

                                      return InkWell(
                                        onTap: () {
                                          UrlLauncherBuilder().launchURL(snsLinks[index]['link']);
                                        },
                                        child: Container(
                                          margin: index != 0 ? const EdgeInsets.only(left: 12.0) : null,
                                          child: SVGBuilder(
                                            image: snsLinks[index]['image'],
                                            width: 24.0.w,
                                            height: 24.0.w,
                                            color: ColorConfig().white(),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 출연진 타이틀 영역
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    child: Row(
                      children: [
                        CustomTextBuilder(
                          text: TextConstant.cast,
                          fontColor: ColorConfig().white(),
                          fontSize: 16.0.sp,
                          fontWeight: FontWeight.w800,
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 4.0),
                          child: CustomTextBuilder(
                            text: '${SetIntl().numberFormat(showCummunityData['artists'].length)}',
                            fontColor: ColorConfig().primaryLight(),
                            fontSize: 16.0.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SVGBuilder(
                          image: 'assets/icon/arrow_right_light.svg',
                          width: 12.0.w,
                          height: 18.0.w,
                          color: ColorConfig().primaryLight(),
                        ),
                      ],
                    ),
                  ),
                  // 출연진 리스트 영역
                  Container(
                    height: 48.0.w,
                    margin: const EdgeInsets.only(top: 4.0),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      itemCount: showCummunityData['artists'].length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 48.0.w,
                          height: 48.0.w,
                          margin: index != showCummunityData['artists'].length - 1 ? const EdgeInsets.only(right: 8.0) : null,
                          decoration: BoxDecoration(
                            color: !(showCummunityData['artists'][index]['image'] == null || showCummunityData['artists'][index]['image'] == false) ? ColorConfig().gray2() : null,
                            border: Border.all(
                              width: 1.0,
                              color: ColorConfig().borderGray1(opacity: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(24.0.r),
                            image: !(showCummunityData['artists'][index]['image'] == null || showCummunityData['artists'][index]['image'] == false)
                              ? DecorationImage(
                                  image: NetworkImage(showCummunityData['artists'][index]['image']),
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
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }

  Future floatingWidget(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              right: 16.0,
              bottom: 16.0,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: floatingButtonWidget(true),
              ),
            ),
            Positioned(
              right: 16.0,
              bottom: 16.0 + 62.0 + 13.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MaterialButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, 'reviewWrite', arguments: {
                        'edit_data': null
                      }).then((value) {
                        if (value != null) {
                          initializeAPI();
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: ColorConfig().white(),
                        borderRadius: BorderRadius.circular(8.0.r),
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width / 1.5,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomTextBuilder(
                            text: TextConstant.writeReview,
                            fontColor: ColorConfig().dark(),
                            fontSize: 14.0.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 20.0),
                            child: SVGBuilder(
                              image: 'assets/icon/star.svg',
                              width: 28.0.w,
                              height: 28.0.w,
                              color: ColorConfig().primary(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  MaterialButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, 'communityWrite', arguments: {
                        'edit_data': null
                      }).then((value) {
                        if (value != null) {
                          initializeAPI();
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: ColorConfig().white(),
                        borderRadius: BorderRadius.circular(8.0.r),
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width / 1.5,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomTextBuilder(
                            text: TextConstant.write,
                            fontColor: ColorConfig().dark(),
                            fontSize: 14.0.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 20.0),
                            child: SVGBuilder(
                              image: 'assets/icon/edit.svg',
                              width: 28.0.w,
                              height: 28.0.w,
                              color: ColorConfig().primary(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ).then((_) {
      animatedController.animateTo(0.0, curve: Curves.linear);
    });
  }

  Widget floatingButtonWidget(bool isActive) {
    return Container(
      width: 62.0,
      height: 62.0,
      decoration: BoxDecoration(
        color: !isActive ? ColorConfig().primary() : ColorConfig().gray2(),
        borderRadius: BorderRadius.circular(31.0.r),
      ),
      child: Center(
        child: RotationTransition(
          turns: animatedAction,
          child: SVGBuilder(
            image: 'assets/icon/counter-plus.svg',
            width: 42.0,
            height: 42.0,
            color: !isActive ? ColorConfig().white() : ColorConfig().gray5(),
          ),
        ),
      ),
    );
  }
}