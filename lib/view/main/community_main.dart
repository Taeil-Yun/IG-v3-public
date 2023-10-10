import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/api/community/best_review.dart';
import 'package:ig-public_v3/api/community/hot_post.dart';
import 'package:ig-public_v3/api/main/main_community.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/view/main/community_widget/widgets.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:ig-public_v3/widget/loading_progress.dart';
import 'package:ig-public_v3/widget/sliver_tabbar_widget.dart';

class MainCommunityScreen extends StatefulWidget {
  const MainCommunityScreen({super.key});

  @override
  State<MainCommunityScreen> createState() => _MainCommunityScreenState();
}

class _MainCommunityScreenState extends State<MainCommunityScreen> with TickerProviderStateMixin {
  late ScrollController customScrollViewController;
  late TabController sliverTabBarController;

  late Animation<double> animatedAction;
  late AnimationController animatedController;

  int currentTabIndex = 0;

  bool isShowAppBar = true;
  bool loadingProgress = true;
  bool tapLoadingProgress = true;

  List communityListData = [];
  List communityReviewListData = [];
  List hotPostListData = [];
  List bestReviewListData = [];

  @override
  void initState() {
    super.initState();

    animatedController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    animatedAction = Tween<double>(begin: 1.0, end: 0.75).animate(animatedController);

    customScrollViewController = ScrollController();
    customScrollViewController.addListener(() {
      setState(() {
        if (customScrollViewController.hasClients) {
          if (customScrollViewController.position.userScrollDirection == ScrollDirection.forward && !isShowAppBar) {
            isShowAppBar = true;
          } else if (customScrollViewController.position.userScrollDirection == ScrollDirection.reverse && isShowAppBar) {
            isShowAppBar = false;
          }
        }
      });
    });

    sliverTabBarController = TabController(
      length: 2,
      vsync: this,  // vsync에 this 형태로 전달해줘야 애니메이션이 활성화됨
    );
    sliverTabBarController.addListener(handleTabSelection);

    initializeAPI();
  }

  @override
  void dispose() {
    super.dispose();

    animatedController.dispose();
  }

  Future<void> initializeAPI() async {
    Future.wait([
      MainCommunityListAPI().communityList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), type: 1).then((value) {
        setState(() {
          communityListData = value.result['data'];
        });
      }),
      CommunityHotPostListAPI().hot(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
        setState(() {
          hotPostListData = value.result['data'];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: !isShowAppBar,
        child: loadingProgress == false ? Container(
          color: ColorConfig().gray2(),
          child: CustomScrollView(
            controller: customScrollViewController,
            slivers: [
              // sliver appbar
              SliverAppBar(
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
                toolbarHeight: const ig-publicAppBar().preferredSize.height,
                floating: true,
                snap: true,
                elevation: 0.0,
                backgroundColor: ColorConfig().primary(),
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
              // tabbar sliver header
              SliverPersistentHeader(
                pinned: true,
                delegate: SliverAppBarDelegate(
                  TabBar(
                    controller: sliverTabBarController,
                    isScrollable: false,
                    labelColor: isShowAppBar == false ? ColorConfig().dark() : ColorConfig().white(),
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
                      color: isShowAppBar == false ? ColorConfig().dark() : ColorConfig().white(),
                      height: 4.0,
                      tabPosition: TabPosition.bottom,
                      horizontalPadding: 12.0,
                    ),
                    onTap: (value) async {
                      setState(() {
                        isShowAppBar = true;
                        customScrollViewController.jumpTo(0.0);
                        tapLoadingProgress = true;
                      });
        
        
                      if (value + 1 == 1) {
                        Future.wait([
                          MainCommunityListAPI().communityList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), type: 1).then((value) {
                            setState(() {
                              communityListData = value.result['data'];
                            });
                          }),
                          CommunityHotPostListAPI().hot(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
                            setState(() {
                              hotPostListData = value.result['data'];
                            });
                          }),
                        ]).then((_) {
                          setState(() {
                            tapLoadingProgress = false;
                          });
                        });
                      } else {
                        Future.wait([
                          MainCommunityListAPI().communityList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), type: 2).then((result) {
                            setState(() {
                              communityReviewListData = result.result['data'];
                            });
                          }),
                          CommunityBestReviewListAPI().bestReview(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((result) {
                            setState(() {
                              bestReviewListData = result.result['data'];
                            });
                          }),
                        ]).then((_) {
                          setState(() {
                            tapLoadingProgress = false;
                          });
                        });
                      }
                    },
                    tabs: const [
                      Tab(
                        text: TextConstant.post,
                      ),
                      Tab(
                        text: TextConstant.showReview,
                      ),
                    ],
                  ),
                  /** isSliverAppBarExpanded */ false,
                  backgroundColor: isShowAppBar == true ? ColorConfig().primary() : ColorConfig().white(),
                  border: isShowAppBar == true ? Border(
                    bottom: BorderSide(
                      width: 1.0,
                      color: ColorConfig().primaryLight(),
                    ),
                  ) : null,
                ),
              ),
              CupertinoSliverRefreshControl(
                onRefresh: () async {
                  if (currentTabIndex == 0) {
                    MainCommunityListAPI().communityList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), type: 1).then((value) {
                      setState(() {
                        communityListData = value.result['data'];
                      });
                    });
                    CommunityHotPostListAPI().hot(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
                      setState(() {
                        hotPostListData = value.result['data'];
                      });
                    });
                  } else {
                    MainCommunityListAPI().communityList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), type: 2).then((result) {
                      setState(() {
                        communityReviewListData = result.result['data'];
                      });
                    });
                    CommunityBestReviewListAPI().bestReview(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((result) {
                      setState(() {
                        bestReviewListData = result.result['data'];
                      });
                    });
                  }
                },
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Column(
                      children: [
                        communityListData.isNotEmpty ? Container(
                          width: MediaQuery.of(context).size.width,
                          color: ColorConfig().gray2(),
                          child: [
                            mainShowCommunityWidget(),
                            communityReviewListData.isNotEmpty ? mainArtistCommunityWidget() : Container(),
                          ][currentTabIndex],
                        ) : Container(),
                        Container(
                          height: 62.0 + 16.0,
                          color: ColorConfig().gray2(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ) : const LoadingProgressBuilder(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          animatedController.animateTo(0.5, curve: Curves.linear);
          
          floatingWidget(context);
        },
        child: floatingButtonWidget(false),
      ),
    );
  }

// String assd = '';
//   void asd() {
//     DefaultAssetBundle.of(context).loadString("assets/icon/add.svg").then((value) {
//       print(value.replaceAll("#2E3A59", '#${ColorConfig().accent().value.toRadixString(16).padLeft(6, '0').toUpperCase()}'),);
//       print('${ColorConfig().accent().value.toRadixString(16).substring(2).toUpperCase()}');
//       setState(() {
//         assd = value.replaceAll("#2E3A59", '#${ColorConfig().accent().value.toRadixString(16).substring(2).toUpperCase()}');
//       });
//     });
//   }

  Widget mainShowCommunityWidget() {
    return tapLoadingProgress == false || loadingProgress == false ? Column(
      children: [
        // 실시간 hot글
        hotPostListData.isNotEmpty ? Container(
          width: MediaQuery.of(context).size.width,
          color: ColorConfig().primary(),
          padding: const EdgeInsets.only(top: 20.0, bottom: 24.0),
          child: MainCommunityWidgetBuilder().realtimeHOTPostWidget(data: hotPostListData),
        ) : Container(),
        const SizedBox(height: 16.0),
        // feed list
        MainCommunityWidgetBuilder().feedList(context, data: communityListData),
      ],
    ) : const LoadingProgressBuilder();
  }

  Widget mainArtistCommunityWidget() {
    return tapLoadingProgress == false ? Column(
      children: [
        // 리얼후기
        bestReviewListData.isNotEmpty ? Container(
          width: MediaQuery.of(context).size.width,
          color: ColorConfig().primary(),
          padding: const EdgeInsets.only(top: 20.0, bottom: 24.0),
          child: MainCommunityWidgetBuilder().realReviewListWidget(data: bestReviewListData),
        ) : Container(),
        const SizedBox(height: 16.0),
        // feed list
        MainCommunityWidgetBuilder().showReviewList(context, data: communityReviewListData),
      ],
    ) : const LoadingProgressBuilder();
  }

  Future floatingWidget(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              right: 16.0,
              bottom: kBottomNavigationBarHeight + 16.0,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: floatingButtonWidget(true),
              ),
            ),
            Positioned(
              right: 16.0,
              bottom: kBottomNavigationBarHeight + 16.0 + 62.0 + 13.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
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
                  GestureDetector(
                    onTap: () {
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