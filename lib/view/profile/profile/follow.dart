import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/api/follow/all_follow_list.dart';
import 'package:ig-public_v3/api/follow/follow_add_cancel.dart';
import 'package:ig-public_v3/costant/build_config.dart';

import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/src/route_argument.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:ig-public_v3/widget/sliver_tabbar_widget.dart';

class FollowListScreen extends StatefulWidget {
  const FollowListScreen({super.key});

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen>
    with TickerProviderStateMixin {
  late TabController tabController;
  late TextEditingController followerSearchController;
  late TextEditingController followingSearchController;
  late TextEditingController recommendSearchController;
  late FocusNode followerSearchFocusNode;
  late FocusNode followingSearchFocusNode;
  late FocusNode recommendSearchFocusNode;

  bool followerSearchStatus = false;
  bool followingSearchStatus = false;
  bool recommendSearchStatus = false;

  List followerSearchData = [];
  List followingSearchData = [];

  Map<String, dynamic> followData = {};
  Map<String, List> recommendSearchData = {
    'artist': [],
    'show': [],
  };

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 3, vsync: this);

    followerSearchController = TextEditingController()
      ..addListener(() {
        setState(() {});
      });
    followingSearchController = TextEditingController()
      ..addListener(() {
        setState(() {});
      });
    recommendSearchController = TextEditingController()
      ..addListener(() {
        setState(() {});
      });
    followerSearchFocusNode = FocusNode();
    followingSearchFocusNode = FocusNode();
    recommendSearchFocusNode = FocusNode();

    Future.delayed(Duration.zero, () {
      setState(() {
        if (RouteGetArguments().getArgs(context)['click'] != null &&
            RouteGetArguments().getArgs(context)['click'] == 'following') {
          tabController.index = 1;
        }
      });
    });

    initializeAPI();
  }

  @override
  void dispose() {
    super.dispose();

    tabController.dispose();
    followerSearchController.dispose();
    followingSearchController.dispose();
    recommendSearchController.dispose();
    followerSearchFocusNode.dispose();
    followingSearchFocusNode.dispose();
    recommendSearchFocusNode.dispose();
  }

  Future<void> initializeAPI() async {
    AllFollowListAPI()
        .allFollows(
            accessToken:
                await SecureStorageConfig().storage.read(key: 'access_token'))
        .then((value) {
      setState(() {
        followData = value.result['data'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (followerSearchFocusNode.hasFocus) {
          followerSearchFocusNode.unfocus();
        }

        if (followingSearchFocusNode.hasFocus) {
          followingSearchFocusNode.unfocus();
        }

        if (recommendSearchFocusNode.hasFocus) {
          recommendSearchFocusNode.unfocus();
        }
      },
      child: Scaffold(
        appBar: ig -
            publicAppBar(
              leading: ig -
                  publicAppBarLeading(
                    press: () => Navigator.pop(context),
                  ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(46.0),
                child: Container(
                  color: ColorConfig().gray1(),
                  child: TabBar(
                    controller: tabController,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    isScrollable: false,
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
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 4.0),
                              child: CustomTextBuilder(
                                text: TextConstant.follower,
                              ),
                            ),
                            CustomTextBuilder(
                              text:
                                  '${followData.isNotEmpty ? followData['follower'].length : 0}',
                              fontColor: ColorConfig().primary(),
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(right: 4.0),
                              child: CustomTextBuilder(
                                text: TextConstant.following,
                              ),
                            ),
                            CustomTextBuilder(
                                text:
                                    '${followData.isNotEmpty ? followData['following'].length : 0}',
                                fontColor: ColorConfig().primary(),
                                fontSize: 14.0.sp,
                                fontWeight: FontWeight.w800),
                          ],
                        ),
                      ),
                      const Tab(
                        text: TextConstant.recommend,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: ColorConfig().gray1(),
          child: SafeArea(
            child: TabBarView(
              controller: tabController,
              children: [
                // 팔로우 탭
                SingleChildScrollView(
                  child: Column(
                    children: [
                      // 검색 영역
                      searchWidget(
                          type: 'follower',
                          data: {'follower': followData['follower']}),
                      // // sorting 영역
                      // sortingWidget(),
                      // 팔로우 공연, 아티스트, 회원 리스트 영역
                      followData.isNotEmpty
                          ? followListWidget(
                              data: followerSearchStatus == false
                                  ? followData['follower']
                                  : followerSearchData)
                          : Container(),
                      const SizedBox(height: 40.0),
                    ],
                  ),
                ),
                // 팔로잉 탭
                SingleChildScrollView(
                  child: Column(
                    children: [
                      // 검색 영역
                      searchWidget(
                          type: 'following',
                          data: {'following': followData['following']}),
                      // // sorting 영역
                      // sortingWidget(),
                      // 팔로잉 공연, 아티스트, 회원 리스트 영역
                      followData.isNotEmpty
                          ? followingListWidget(
                              data: followingSearchStatus == false
                                  ? followData['following']
                                  : followingSearchData)
                          : Container(),
                      const SizedBox(height: 40.0),
                    ],
                  ),
                ),
                // 추천 탭
                SingleChildScrollView(
                  child: Column(
                    children: [
                      // 검색 영역
                      searchWidget(type: 'recommend', data: {
                        'show': followData['recommend_show'],
                        'artist': followData['recommend_artist']
                      }),
                      // // sorting 영역
                      // sortingWidget(),
                      // 추천 리스트 영역
                      followData.isNotEmpty
                          ? recommendListWidget()
                          : Container(),
                      const SizedBox(height: 40.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 검색창 위젯
  Widget searchWidget(
      {required String type, required Map<String, dynamic> data}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: TextFormField(
        controller: type == 'follower'
            ? followerSearchController
            : type == 'following'
                ? followingSearchController
                : recommendSearchController,
        focusNode: type == 'follower'
            ? followerSearchFocusNode
            : type == 'following'
                ? followingSearchFocusNode
                : recommendSearchFocusNode,
        onEditingComplete: () {
          setState(() {
            if (type == 'follower') {
              for (int i = 0; i < data['follower'].length; i++) {
                if (data['follower'][i]['nick']
                    .toString()
                    .contains(followerSearchController.text.trim())) {
                  followerSearchData.add(data['follower'][i]);
                }
              }
              followerSearchStatus = true;
            } else if (type == 'following') {
              for (int i = 0; i < data['following'].length; i++) {
                if (data['following'][i]['kind'] == 'u' &&
                    data['following'][i]['nick']
                        .toString()
                        .contains(followingSearchController.text.trim())) {
                  followingSearchData.add(data['following'][i]);
                } else if (data['following'][i]['kind'] == 's' &&
                    data['following'][i]['name']
                        .toString()
                        .contains(followingSearchController.text.trim())) {
                  followingSearchData.add(data['following'][i]);
                } else if (data['following'][i]['kind'] == 'a' &&
                    data['following'][i]['name']
                        .toString()
                        .contains(followingSearchController.text.trim())) {
                  followingSearchData.add(data['following'][i]);
                }
              }
              followingSearchStatus = true;
            } else if (type == 'recommend') {
              for (int i = 0; i < data['artist'].length; i++) {
                if (data['artist'][i]['name']
                    .toString()
                    .contains(recommendSearchController.text.trim())) {
                  recommendSearchData['artist']?.add(data['artist'][i]);
                }
              }

              for (int i = 0; i < data['show'].length; i++) {
                if (data['show'][i]['kind'] == 's' &&
                    data['show'][i]['name']
                        .toString()
                        .contains(recommendSearchController.text.trim())) {
                  recommendSearchData['show']?.add(data['show'][i]);
                }
              }
              recommendSearchStatus = true;
            }
          });

          if (type == 'follower') {
            followerSearchFocusNode.unfocus();
          } else if (type == 'following') {
            followingSearchFocusNode.unfocus();
          } else if (type == 'recommend') {
            recommendSearchFocusNode.unfocus();
          }
        },
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          filled: true,
          fillColor: ColorConfig().gray2(),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(4.0.r),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(4.0.r),
          ),
          hintText: '아이디 검색',
          hintStyle: TextStyle(
            color: ColorConfig().gray3(),
            fontSize: 12.0.sp,
            fontWeight: FontWeight.w700,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.only(left: 12.0, right: 4.0),
            child: SVGBuilder(
              image: 'assets/icon/search.svg',
              width: 24.0.w,
              height: 24.0.w,
              color: ColorConfig().gray3(),
            ),
          ),
          prefixIconConstraints: BoxConstraints(
            maxWidth: 24.0.w + 12.0,
            maxHeight: 24.0.w,
          ),
          suffixIcon:
              type == 'follower' && followerSearchController.text.isNotEmpty ||
                      type == 'following' &&
                          followingSearchController.text.isNotEmpty ||
                      type == 'recommend' &&
                          recommendSearchController.text.isNotEmpty
                  ? InkWell(
                      onTap: () {
                        if (type == 'follower') {
                          followerSearchController.clear();
                          followerSearchData.clear();
                          setState(() {
                            followerSearchStatus = false;
                          });
                        } else if (type == 'following') {
                          followingSearchController.clear();
                          followingSearchData.clear();
                          setState(() {
                            followingSearchStatus = false;
                          });
                        } else if (type == 'recommend') {
                          recommendSearchController.clear();
                          recommendSearchData.clear();
                          setState(() {
                            recommendSearchStatus = false;
                          });
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 4.0, right: 12.0),
                        child: SVGBuilder(
                          image: 'assets/icon/close_normal.svg',
                          width: 24.0.w,
                          height: 24.0.w,
                          color: ColorConfig().gray3(),
                        ),
                      ),
                    )
                  : Container(),
          suffixIconConstraints: BoxConstraints(
            maxWidth: type == 'follower' &&
                        followerSearchController.text.isNotEmpty ||
                    type == 'following' &&
                        followingSearchController.text.isNotEmpty ||
                    type == 'recommend' &&
                        recommendSearchController.text.isNotEmpty
                ? 24.0.w + 12.0
                : 0.0,
            maxHeight: type == 'follower' &&
                        followerSearchController.text.isNotEmpty ||
                    type == 'following' &&
                        followingSearchController.text.isNotEmpty ||
                    type == 'recommend' &&
                        recommendSearchController.text.isNotEmpty
                ? 24.0.w
                : 0.0,
          ),
        ),
        style: TextStyle(
          color: ColorConfig().gray5(),
          fontSize: 12.0.sp,
          fontWeight: FontWeight.w700,
        ),
        cursorColor: ColorConfig().primary(),
      ),
    );
  }

  // sorting 위젯
  Widget sortingWidget() {
    if (followData.isEmpty) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: IntrinsicWidth(
          child: Container(
            padding: const EdgeInsets.fromLTRB(10.0, 8.0, 8.0, 8.0),
            decoration: BoxDecoration(
              color: ColorConfig().white(),
              border: Border.all(
                width: 1.0,
                color: ColorConfig().gray2(),
              ),
              borderRadius: BorderRadius.circular(4.0.r),
            ),
            child: Row(
              children: [
                CustomTextBuilder(
                  text: TextConstant.all,
                  fontColor: ColorConfig().gray5(),
                  fontSize: 12.0.sp,
                  fontWeight: FontWeight.w700,
                ),
                Container(
                  margin: const EdgeInsets.only(left: 4.0),
                  child: SVGBuilder(
                    image: 'assets/icon/arrow_down_light.svg',
                    width: 16.0.w,
                    height: 16.0.w,
                    color: ColorConfig().gray5(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 팔로우 아티스트, 공연, 회원 리스트 위젯
  Widget followListWidget({dynamic data}) {
    if (followerSearchController.text.isEmpty && data.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height / 1.5,
        child: Column(
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
              text: '아직 팔로우중인 사용자가 없어요.',
              fontColor: ColorConfig().gray4(),
              fontSize: 14.0.sp,
              fontWeight: FontWeight.w400,
              height: 1.2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(data.length, (index) {
        return InkWell(
          onTap: () {
            if (data[index]['kind'] == 's') {
              Navigator.pushNamed(context, 'showCommunity', arguments: {
                'show_index': data[index]['idx'],
              }).then((value) async {
                AllFollowListAPI()
                    .allFollows(
                        accessToken: await SecureStorageConfig()
                            .storage
                            .read(key: 'access_token'))
                    .then((value) {
                  setState(() {
                    followData = value.result['data'];
                  });
                });
              });
            } else if (data[index]['kind'] == 'a') {
              Navigator.pushNamed(context, 'artistCommunity', arguments: {
                'artist_index': data[index]['idx'],
              }).then((value) async {
                AllFollowListAPI()
                    .allFollows(
                        accessToken: await SecureStorageConfig()
                            .storage
                            .read(key: 'access_token'))
                    .then((value) {
                  setState(() {
                    followData = value.result['data'];
                  });
                });
              });
            } else if (data[index]['kind'] == 'u') {
              Navigator.pushNamed(context, 'otherUserProfile', arguments: {
                'user_index': data[index]['idx'],
              }).then((value) async {
                AllFollowListAPI()
                    .allFollows(
                        accessToken: await SecureStorageConfig()
                            .storage
                            .read(key: 'access_token'))
                    .then((value) {
                  setState(() {
                    followData = value.result['data'];
                  });
                });
              });
            }
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 이미지, 닉네임 영역
                Row(
                  children: [
                    // 이미지
                    Container(
                      width: index != 1 ? 48.0.w : 42.0.w,
                      height: 48.0.w,
                      margin: EdgeInsets.only(right: index != 1 ? 8.0 : 14.0),
                      decoration: BoxDecoration(
                        color: data[index]['kind'] == 's' &&
                                data[index]['image'] == null
                            ? ColorConfig().gray2()
                            : null,
                        borderRadius: index != 1
                            ? BorderRadius.circular(24.0.r)
                            : BorderRadius.circular(10.0.r),
                        image: data[index]['kind'] != 's'
                            ? data[index]['image'] != null
                                ? DecorationImage(
                                    image: NetworkImage(data[index]['image']),
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.high,
                                  )
                                : const DecorationImage(
                                    image: AssetImage(
                                        'assets/img/profile_default.png'),
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.high,
                                  )
                            : data[index]['image'] != null
                                ? DecorationImage(
                                    image: NetworkImage(data[index]['image']),
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.high,
                                  )
                                : null,
                      ),
                    ),
                    // 닉네임
                    CustomTextBuilder(
                      text:
                          '${data[index]['kind'] == 'u' ? data[index]['nick'] : data[index]['name']}',
                      fontColor: data[index]['kind'] != 'u'
                          ? ColorConfig().primary()
                          : ColorConfig().gray5(),
                      fontSize: 12.0.sp,
                      fontWeight: data[index]['kind'] != 'u'
                          ? FontWeight.w900
                          : FontWeight.w700,
                    ),
                  ],
                ),
                // 팔로잉 버튼 영역
                InkWell(
                  onTap: () async {
                    if (data[index]['is_follow'] == true) {
                      FollowAddOrCancel()
                          .followApply(
                              accessToken: await SecureStorageConfig()
                                  .storage
                                  .read(key: 'access_token'),
                              kind: 'u',
                              type: data[index]['kind'] == 'u'
                                  ? 1
                                  : data[index]['kind'] == 's'
                                      ? 2
                                      : 3,
                              index: data[index]['idx'])
                          .then((value) {
                        if (value.result['status'] == 1) {
                          setState(() {
                            data[index]['is_follow'] = false;
                          });
                        }
                      });
                    } else {
                      FollowAddOrCancel()
                          .followApply(
                              accessToken: await SecureStorageConfig()
                                  .storage
                                  .read(key: 'access_token'),
                              kind: 'f',
                              type: data[index]['kind'] == 'u'
                                  ? 1
                                  : data[index]['kind'] == 's'
                                      ? 2
                                      : 3,
                              index: data[index]['idx'])
                          .then((value) {
                        if (value.result['status'] == 1) {
                          setState(() {
                            data[index]['is_follow'] = true;
                          });
                        }
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: data[index]['is_follow'] == false
                          ? ColorConfig().primary()
                          : ColorConfig().primaryLight(),
                      borderRadius: BorderRadius.circular(4.0.r),
                    ),
                    child: Center(
                      child: CustomTextBuilder(
                        text: data[index]['is_follow'] == false
                            ? TextConstant.follow
                            : TextConstant.following,
                        fontColor: ColorConfig().white(),
                        fontSize: 12.0.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // 팔로잉 아티스트, 공연, 회원 리스트 위젯
  Widget followingListWidget({dynamic data}) {
    if (followingSearchController.text.isEmpty && data.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height / 1.5,
        child: Column(
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
              text: '회원님이 팔로우하는 사용자가 없습니다.',
              fontColor: ColorConfig().gray4(),
              fontSize: 14.0.sp,
              fontWeight: FontWeight.w400,
              height: 1.2,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: List.generate(data.length, (index) {
        return InkWell(
          onTap: () {
            if (data[index]['kind'] == 's') {
              Navigator.pushNamed(context, 'showCommunity', arguments: {
                'show_index': data[index]['idx'],
              }).then((value) async {
                AllFollowListAPI()
                    .allFollows(
                        accessToken: await SecureStorageConfig()
                            .storage
                            .read(key: 'access_token'))
                    .then((value) {
                  setState(() {
                    followData = value.result['data'];
                  });
                });
              });
            } else if (data[index]['kind'] == 'a') {
              Navigator.pushNamed(context, 'artistCommunity', arguments: {
                'artist_index': data[index]['idx'],
              }).then((value) async {
                AllFollowListAPI()
                    .allFollows(
                        accessToken: await SecureStorageConfig()
                            .storage
                            .read(key: 'access_token'))
                    .then((value) {
                  setState(() {
                    followData = value.result['data'];
                  });
                });
              });
            } else if (data[index]['kind'] == 'u') {
              Navigator.pushNamed(context, 'otherUserProfile', arguments: {
                'user_index': data[index]['idx'],
              }).then((value) async {
                AllFollowListAPI()
                    .allFollows(
                        accessToken: await SecureStorageConfig()
                            .storage
                            .read(key: 'access_token'))
                    .then((value) {
                  setState(() {
                    followData = value.result['data'];
                  });
                });
              });
            }
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 이미지, 닉네임 영역
                Expanded(
                  child: Row(
                    children: [
                      // 이미지
                      Container(
                        width: data[index]['kind'] != 's' ? 48.0.w : 42.0.w,
                        height: 48.0.w,
                        margin: EdgeInsets.only(
                            right: data[index]['kind'] != 's' ? 8.0 : 14.0),
                        decoration: BoxDecoration(
                          color: data[index]['kind'] == 's' &&
                                  data[index]['image'] == null
                              ? ColorConfig().gray2()
                              : null,
                          borderRadius: data[index]['kind'] != 's'
                              ? BorderRadius.circular(24.0.r)
                              : BorderRadius.circular(10.0.r),
                          image: data[index]['kind'] != 's'
                              ? data[index]['image'] == null
                                  ? const DecorationImage(
                                      image: AssetImage(
                                          'assets/img/profile_default.png'),
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.high,
                                    )
                                  : DecorationImage(
                                      image: NetworkImage(data[index]['image']),
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.high,
                                    )
                              : data[index]['image'] != null
                                  ? DecorationImage(
                                      image: NetworkImage(data[index]['image']),
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.high,
                                    )
                                  : null,
                        ),
                        child: data[index]['kind'] == 's' &&
                                data[index]['image'] == null
                            ? Center(
                                child: SVGBuilder(
                                  image: 'assets/icon/album.svg',
                                  width: 22.0.w,
                                  height: 22.0.w,
                                  color: ColorConfig().white(),
                                ),
                              )
                            : Container(),
                      ),
                      // 닉네임
                      Expanded(
                        child: CustomTextBuilder(
                          text:
                              '${data[index]['name']} ${data[index]['kind'] != 'u' ? TextConstant.communityText : ''}',
                          fontColor: data[index]['kind'] != 'u'
                              ? ColorConfig().primary()
                              : ColorConfig().gray5(),
                          fontSize: 12.0.sp,
                          fontWeight: data[index]['kind'] != 'u'
                              ? FontWeight.w900
                              : FontWeight.w700,
                          maxLines: 1,
                          textOverflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // 팔로잉 버튼 영역
                InkWell(
                  onTap: () async {
                    FollowAddOrCancel()
                        .followApply(
                            accessToken: await SecureStorageConfig()
                                .storage
                                .read(key: 'access_token'),
                            kind: 'u',
                            type: data[index]['kind'] == 'u'
                                ? 1
                                : data[index]['kind'] == 's'
                                    ? 2
                                    : 3,
                            index: data[index]['idx'])
                        .then((value) {
                      if (value.result['status'] == 1) {
                        setState(() {
                          data.removeAt(index);
                        });
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: ColorConfig().primaryLight(),
                      borderRadius: BorderRadius.circular(4.0.r),
                    ),
                    child: Center(
                      child: CustomTextBuilder(
                        text: TextConstant.following,
                        fontColor: ColorConfig().white(),
                        fontSize: 12.0.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // 추천 리스트 위젯
  Widget recommendListWidget() {
    return Column(
      children: [
        recommendSearchStatus == false
            ? recommendListTitleWidget(
                title: TextConstant.artist,
                count: followData['recommend_artist'].length)
            : recommendListTitleWidget(
                title: TextConstant.artist,
                count: recommendSearchData['artist']?.length),
        recommendListDataWidget(
            type: 'artist',
            dataCount: followData['recommend_artist'].length,
            data: recommendSearchStatus == false
                ? followData['recommend_artist']
                : recommendSearchData['artist']),
        recommendSearchStatus == false
            ? recommendListTitleWidget(
                title: TextConstant.show,
                count: followData['recommend_show'].length)
            : recommendListTitleWidget(
                title: TextConstant.show,
                count: recommendSearchData['show']?.length),
        recommendListDataWidget(
            type: 'show',
            dataCount: followData['recommend_show'].length,
            data: recommendSearchStatus == false
                ? followData['recommend_show']
                : recommendSearchData['show']),
      ],
    );
  }

  // 추천 리스트 타이틀 위젯
  Widget recommendListTitleWidget(
      {required String title, required int? count}) {
    if (count == 0) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.5),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 4.0),
            child: CustomTextBuilder(
              text: title,
              fontColor: ColorConfig().dark(),
              fontSize: 14.0.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          CustomTextBuilder(
            text: '$count',
            fontColor: ColorConfig().primary(),
            fontSize: 14.0.sp,
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }

  // 추천 리스트 데이터 위젯
  Widget recommendListDataWidget(
      {required String type, required int dataCount, dynamic data}) {
    return Column(
      children: List.generate(data.length, (index) {
        return InkWell(
          onTap: () {
            if (type == 'show') {
              Navigator.pushNamed(context, 'showCommunity', arguments: {
                'show_index': data[index]['idx'],
              }).then((value) async {
                AllFollowListAPI()
                    .allFollows(
                        accessToken: await SecureStorageConfig()
                            .storage
                            .read(key: 'access_token'))
                    .then((value) {
                  setState(() {
                    followData = value.result['data'];
                  });
                });
              });
            } else if (type == 'artist') {
              Navigator.pushNamed(context, 'artistCommunity', arguments: {
                'artist_index': data[index]['idx'],
              }).then((value) async {
                AllFollowListAPI()
                    .allFollows(
                        accessToken: await SecureStorageConfig()
                            .storage
                            .read(key: 'access_token'))
                    .then((value) {
                  setState(() {
                    followData = value.result['data'];
                  });
                });
              });
            }
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 이미지, 닉네임 영역
                Row(
                  children: [
                    // 이미지
                    Container(
                      width: type != 'show' ? 48.0.w : 42.0.w,
                      height: 48.0.w,
                      margin:
                          EdgeInsets.only(right: type != 'show' ? 8.0 : 14.0),
                      decoration: BoxDecoration(
                        color: type == 'show' && data[index]['image'] == null
                            ? ColorConfig().gray2()
                            : null,
                        borderRadius: type != 'show'
                            ? BorderRadius.circular(24.0.r)
                            : BorderRadius.circular(10.0.r),
                        image: type == 'artist'
                            ? data[index]['image'] != null
                                ? DecorationImage(
                                    image: NetworkImage(data[index]['image']),
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.high,
                                  )
                                : const DecorationImage(
                                    image: AssetImage(
                                        'assets/img/profile_default.png'),
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.high,
                                  )
                            : data[index]['image'] != null
                                ? DecorationImage(
                                    image: NetworkImage(data[index]['image']),
                                    fit: BoxFit.cover,
                                    filterQuality: FilterQuality.high,
                                  )
                                : null,
                      ),
                    ),
                    // 닉네임
                    CustomTextBuilder(
                      text: type == 'artist'
                          ? '${data[index]['name']}'
                          : '${data[index]['name']}',
                      fontColor: ColorConfig().primary(),
                      fontSize: 12.0.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ],
                ),
                // 팔로잉 버튼 영역
                InkWell(
                  onTap: () async {
                    if (type == 'artist') {
                      if (data[index]['is_follow'] == true) {
                        FollowAddOrCancel()
                            .followApply(
                                accessToken: await SecureStorageConfig()
                                    .storage
                                    .read(key: 'access_token'),
                                kind: 'u',
                                type: data[index]['kind'] == 'u'
                                    ? 1
                                    : data[index]['kind'] == 's'
                                        ? 2
                                        : 3,
                                index: data[index]['idx'])
                            .then((value) {
                          if (value.result['status'] == 1) {
                            setState(() {
                              data[index]['is_follow'] = false;
                            });
                          }
                        });
                      } else {
                        FollowAddOrCancel()
                            .followApply(
                                accessToken: await SecureStorageConfig()
                                    .storage
                                    .read(key: 'access_token'),
                                kind: 'f',
                                type: data[index]['kind'] == 'u'
                                    ? 1
                                    : data[index]['kind'] == 's'
                                        ? 2
                                        : 3,
                                index: data[index]['idx'])
                            .then((value) {
                          if (value.result['status'] == 1) {
                            setState(() {
                              data[index]['is_follow'] = true;
                            });
                          }
                        });
                      }
                    } else {
                      if (data[index]['is_follow'] == true) {
                        FollowAddOrCancel()
                            .followApply(
                                accessToken: await SecureStorageConfig()
                                    .storage
                                    .read(key: 'access_token'),
                                kind: 'u',
                                type: data[index]['kind'] == 'u'
                                    ? 1
                                    : data[index]['kind'] == 's'
                                        ? 2
                                        : 3,
                                index: data[index]['idx'])
                            .then((value) {
                          if (value.result['status'] == 1) {
                            setState(() {
                              data[index]['is_follow'] = false;
                            });
                          }
                        });
                      } else {
                        FollowAddOrCancel()
                            .followApply(
                                accessToken: await SecureStorageConfig()
                                    .storage
                                    .read(key: 'access_token'),
                                kind: 'f',
                                type: data[index]['kind'] == 'u'
                                    ? 1
                                    : data[index]['kind'] == 's'
                                        ? 2
                                        : 3,
                                index: data[index]['idx'])
                            .then((value) {
                          if (value.result['status'] == 1) {
                            setState(() {
                              data[index]['is_follow'] = true;
                            });
                          }
                        });
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: type == 'artist'
                          ? data[index]['is_follow'] == false
                              ? ColorConfig().primary()
                              : ColorConfig().primaryLight()
                          : data[index]['is_follow'] == false
                              ? ColorConfig().primary()
                              : ColorConfig().primaryLight(),
                      borderRadius: BorderRadius.circular(4.0.r),
                    ),
                    child: Center(
                      child: CustomTextBuilder(
                        text: type == 'artist'
                            ? data[index]['is_follow'] == false
                                ? TextConstant.follow
                                : TextConstant.following
                            : data[index]['is_follow'] == false
                                ? TextConstant.follow
                                : TextConstant.following,
                        fontColor: ColorConfig().white(),
                        fontSize: 12.0.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
