import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/api/community/other_user_profile.dart';
import 'package:ig-public_v3/api/follow/follow_add_cancel.dart';
import 'package:ig-public_v3/api/main/main_community.dart';
import 'package:ig-public_v3/api/profile/add_blacklist.dart';
import 'package:ig-public_v3/api/profile/delete_blacklist.dart';
import 'package:ig-public_v3/costant/build_config.dart';

import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/src/route_argument.dart';
import 'package:ig-public_v3/util/set_intl.dart';
import 'package:ig-public_v3/util/share.dart';
import 'package:ig-public_v3/util/toast.dart';
import 'package:ig-public_v3/view/main/community_widget/widgets.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:ig-public_v3/widget/sliver_tabbar_widget.dart';

class OtherUserProfileScreen extends StatefulWidget {
  const OtherUserProfileScreen({super.key});

  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> with TickerProviderStateMixin {
  late ScrollController customScrollViewController;
  late TabController sliverTabBarController;

  Timer? _debounce;

  int currentTabIndex = 0;
  int userIndex = 0;

  bool isExpandedAppBar = false;
  bool sstatus = false;

  Color appBarActionColor = ColorConfig.defaultWhite;

  List postList = [];
  List reviewList = [];

  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();

    customScrollViewController = ScrollController();

    sliverTabBarController = TabController(
      length: 2,
      vsync: this,  // vsync에 this 형태로 전달해줘야 애니메이션이 활성화됨
    );
    sliverTabBarController.addListener(handleTabSelection);

    Future.delayed(Duration.zero, () {
      if (RouteGetArguments().getArgs(context)['user_index'] != null) {
        setState(() {
          userIndex = RouteGetArguments().getArgs(context)['user_index'];
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
    OtherUserProfileAPI().otherUserProfile(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), userIndex: userIndex).then((value) {
      setState(() {
        userData = value.result['data'];
      });
    });
    MainCommunityListAPI().communityList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), type: 1, userIndex: userIndex).then((value) {
      if (value.result['status'] == 1) {
        setState(() {
          postList = value.result['data'];
        });
      }
    });
    MainCommunityListAPI().communityList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), type: 2, userIndex: userIndex).then((value) {
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
      body: userData.isNotEmpty ? SafeArea(
        child: CustomScrollView(
          controller: customScrollViewController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            // sliver appbar
            SliverAppBar(
              toolbarHeight: const ig-publicAppBar().preferredSize.height,
              expandedHeight: const ig-publicAppBar().preferredSize.height + 150.0.w,
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
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(4.0.r),
                          topRight: Radius.circular(4.0.r),
                        ),
                      ),
                      builder: (context1) {
                        return SafeArea(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 상단 영역
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomTextBuilder(
                                      text: '${userData['nick']}',
                                      fontColor: ColorConfig().dark(),
                                      fontSize: 16.0.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context1);
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
                              // 차단하기 영역
                              InkWell(
                                onTap: () async {
                                  Navigator.pop(context1);

                                  if (userData['is_block'] == false) {
                                    AddBlackListAPI().blacklistAdd(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), userIndex: userIndex).then((value) {
                                      if (value.result['status'] == 1) {
                                        ToastModel().iconToast(value.result['message']);

                                        setState(() {
                                          userData['is_block'] = true;
                                        });
                                      }
                                    });
                                  } else {
                                    DeleteBlackListAPI().blacklistDelete(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), userIndex: userIndex).then((value) {
                                      if (value.result['status'] == 1) {
                                        ToastModel().iconToast(value.result['message']);

                                        setState(() {
                                          userData['is_block'] = false;
                                        });
                                      }
                                    });
                                  }

                                },
                                child: Container(
                                  padding: const EdgeInsets.all(20.0),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        width: 1.0,
                                        color: ColorConfig().gray1(),
                                      ),
                                    ),
                                  ),
                                  child: CustomTextBuilder(
                                    text: userData['is_block'] == false ? TextConstant.doBlacklist : TextConstant.unblock,
                                    fontColor: ColorConfig().dark(),
                                    fontSize: 14.0.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              // 공유하기 영역
                              InkWell(
                                onTap: () async {
                                  Navigator.pop(context1);

                                  if (_debounce?.isActive ?? false) _debounce!.cancel();

                                  _debounce = Timer(const Duration(milliseconds: 300), () async {
                                    shareBuilder(context, type: 'user', index: userIndex);
                                  });

                                },
                                child: Container(
                                  padding: const EdgeInsets.all(20.0),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        width: 1.0,
                                        color: ColorConfig().gray1(),
                                      ),
                                    ),
                                  ),
                                  child: CustomTextBuilder(
                                    text: TextConstant.share,
                                    fontColor: ColorConfig().dark(),
                                    fontSize: 14.0.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  icon: SVGBuilder(
                    image: 'assets/icon/more_vertical.svg',
                    color: isExpandedAppBar ? ColorConfig().dark() : ColorConfig().white(),
                  ),
                ),
              ],
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      // // 뱃지 영역
                      // badgeListWidget(),
                      // 팔로우한 아티스트 타이틀 영역
                      feedContentsTitleWidget(text: TextConstant.followArtist, count: userData['artists'].length),
                      // 팔로우한 아티스트 리스트 영역
                      userData['artists'].isNotEmpty ? followArtistListWidget() : Container(),
                      // 팔로우한 공연 타이틀 영역
                      feedContentsTitleWidget(text: TextConstant.folllowShow, count: userData['shows'].length),
                      // 팔로우한 공연 리스트 영역
                      userData['shows'].isNotEmpty ? followShowListWidget() : Container(),
                    ],
                  ),
                ),
                Container(
                  height: 8.0,
                  color: ColorConfig().gray1(),
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
                  color: ColorConfig().gray2(),
                  child: [
                    // 게시물 영역
                    MainCommunityWidgetBuilder().feedList(context, data: postList, type: 'U', typeIndex: userIndex),
                    // 공연 후기 영역
                    MainCommunityWidgetBuilder().feedList(context, data: reviewList, type: 'U', typeIndex: userIndex),
                  ][currentTabIndex],
                ),
                Container(
                  height: 62.0 + 16.0,
                  color: ColorConfig().gray2(),
                )
              ]),
            ),
          ],
        ),
      ) : Container(),
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
                    color: userData['background'] == null ? ColorConfig().gray2() : null,
                    image: userData['background'] != null ? DecorationImage(
                      image: NetworkImage(userData['background']),
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
                        image: userData['image'] == null
                          ? const DecorationImage(
                              image: AssetImage('assets/img/profile_default.png'),
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            )
                          : DecorationImage(
                              image: NetworkImage(userData['image']),
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            ),
                      ),
                    ),
                    Expanded(
                      child: userData.isNotEmpty ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextBuilder(
                            text: '${userData['nick']}',
                            fontColor: ColorConfig().white(),
                            fontSize: 16.0.sp,
                            fontWeight: FontWeight.w800,
                            height: null,
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 8.0, bottom: 12.0),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    // Navigator.pushNamed(context, 'followList', arguments: {
                                    //   'click': 'follower',
                                    // });
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
                                        text: '${SetIntl().numberFormat(userData['follower_count'])}',
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
                                      // Navigator.pushNamed(context, 'followList', arguments: {
                                      //   'click': 'following',
                                      // });
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
                                          text: '${SetIntl().numberFormat(userData['following_count'])}',
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
                          Container(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            child: CustomTextBuilder(
                              text: userData['description'] != null ? '${userData['description']}' : '',
                              fontColor: userData['description'] != null ? ColorConfig().white() : ColorConfig().borderGray1(),
                              fontSize: 12.0.sp,
                              fontWeight: FontWeight.w700,
                              height: null,
                            ),
                          ),
                          // 팔로우 버튼 영역
                          InkWell(
                            onTap: () async {
                              if (userData['is_follow'] == false) {
                                FollowAddOrCancel().followApply(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), kind: 'f', type: 1, index: userData['user_index']).then((value) {
                                  if (value.result['status'] == 1) {
                                    setState(() {
                                      userData['is_follow'] = true;
                                    });
                                  }
                                });
                              } else {
                                FollowAddOrCancel().followApply(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), kind: 'u', type: 1, index: userData['user_index']).then((value) {
                                  if (value.result['status'] == 1) {
                                    setState(() {
                                      userData['is_follow'] = false;
                                    });
                                  }
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              decoration: BoxDecoration(
                                color: userData['is_follow'] == false ? ColorConfig().primary() : ColorConfig.transparent,
                                border: Border.all(
                                  width: 1.0,
                                  color: userData['is_follow'] == false ? ColorConfig.transparent : ColorConfig().white(),
                                ),
                                borderRadius: BorderRadius.circular(4.0.r),
                              ),
                              child: Center(
                                child: CustomTextBuilder(
                                  text: userData['is_follow'] == false ? TextConstant.follow : TextConstant.cancelFollow,
                                  fontColor: ColorConfig().white(),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
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
        itemCount: userData['artists'].length,
        itemBuilder: (context, index) {
          return Container(
            width: 48.0.w,
            height: 48.0.w,
            margin: index != userData['artists'].length ? const EdgeInsets.only(right: 8.0) : null,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.0.r),
              image: userData['artists'][index]['image'] != null
                ? DecorationImage(
                    image: NetworkImage(userData['artists'][index]['image']),
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

  // 팔로우한 공연 리스트 위젯
  Widget followShowListWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 4.0),
      constraints: BoxConstraints(
        maxHeight: 172.0.w
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: userData['shows'].length,
        itemBuilder: (context, index) {
          return Container(
            width: 120.0.w,
            height: 172.0.w,
            margin: const EdgeInsets.only(right: 12.0),
            decoration: BoxDecoration(
              color: userData['shows'][index]['image'] == null ? ColorConfig().gray2() : null,
              borderRadius: BorderRadius.circular(6.0.r),
              image: userData['shows'][index]['image'] != null ? DecorationImage(
                image: NetworkImage(userData['shows'][index]['image']),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ) : null,
            ),
            child: userData['shows'][index]['image'] == null ? Center(
              child: SVGBuilder(
                image: 'assets/icon/album.svg',
                width: 24.0.w,
                height: 24.0.w,
                color: ColorConfig().white(),
              ),
            ) : Container(),
          );
        },
      ),
    );
  }
}