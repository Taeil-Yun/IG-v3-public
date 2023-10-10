import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/api/follow/follow_add_cancel.dart';
import 'package:ig-public_v3/api/search/search.dart';
import 'package:ig-public_v3/api/search/search_recommend.dart';
import 'package:ig-public_v3/costant/build_config.dart';

import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:ig-public_v3/widget/sliver_tabbar_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHomeScreen extends StatefulWidget {
  const SearchHomeScreen({super.key});

  @override
  State<SearchHomeScreen> createState() => _SearchHomeScreenState();
}

class _SearchHomeScreenState extends State<SearchHomeScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController searchController;
  late FocusNode searchFocusNode;
  late TabController tabController;

  List<String> searchHistories = [];

  Map<String, dynamic> recommendData = {};
  Map<String, dynamic> searchData = {};

  bool isSearchComplete = false;

  @override
  void initState() {
    super.initState();

    searchController = TextEditingController()
      ..addListener(() {
        setState(() {});
      });
    searchFocusNode = FocusNode();
    tabController = TabController(length: 2, vsync: this);

    searchHistoryLoad();
    initializeAPI();
  }

  @override
  void dispose() {
    super.dispose();

    searchController.dispose();
    searchFocusNode.dispose();
    tabController.dispose();
  }

  Future<void> initializeAPI() async {
    SearchRecommendAPI()
        .searchSecommend(
            accessToken:
                await SecureStorageConfig().storage.read(key: 'access_token'))
        .then((value) {
      setState(() {
        recommendData = value.result['data'];
      });
    });
  }

  Future<void> searchHistoryLoad() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getStringList('SearchList') != null) {
      setState(() {
        searchHistories = prefs.getStringList('SearchList')!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (searchFocusNode.hasFocus) {
          searchFocusNode.unfocus();
        }
      },
      child: Scaffold(
        appBar: ig -
            publicAppBar(
              backgroundColor: ColorConfig().primary(),
              toolbarHeight: 27.0 + 24.0.w + 8.0,
              leading: ig -
                  publicAppBarLeading(
                    using: false,
                    press: () {},
                  ),
              leadingWidth: 0.0,
              title: ig -
                  publicAppBarTitle(
                    onWidget: true,
                    wd: Row(
                      children: [
                        InkWell(
                          splashColor: ColorConfig.transparent,
                          highlightColor: ColorConfig.transparent,
                          onTap: () {
                            if (isSearchComplete == true) {
                              setState(() {
                                searchController.clear();
                                isSearchComplete = false;
                              });
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: SVGBuilder(
                              image: 'assets/icon/arrow_left_bold.svg',
                              width: 28.0.w,
                              height: 28.0.w,
                              color: ColorConfig().white(),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width -
                              (32.0 + 12.0 + 28.0.w + 24.0),
                          height: 24.0.w + 8.0,
                          child: TextFormField(
                            controller: searchController,
                            focusNode: searchFocusNode,
                            onEditingComplete: () async {
                              if (searchController.text.isNotEmpty &&
                                  searchController.text.length >= 2) {
                                final prefs =
                                    await SharedPreferences.getInstance();

                                bool flag = false;

                                if (!searchHistories
                                    .contains(searchController.text)) {
                                  flag = true;
                                  searchHistories.insert(
                                      0, searchController.text);
                                }

                                if (flag) {
                                  prefs.setStringList(
                                      'SearchList', searchHistories);
                                }

                                SearchAPI()
                                    .search(
                                        accessToken: await SecureStorageConfig()
                                            .storage
                                            .read(key: 'access_token'),
                                        keyword: searchController.text)
                                    .then((value) {
                                  setState(() {
                                    searchData = value.result['data'];
                                    isSearchComplete = true;
                                  });
                                });
                              }
                            },
                            decoration: InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: ColorConfig().gray1(),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(4.0.r),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(4.0.r),
                              ),
                              hintText: TextConstant.searchPlaceholderText,
                              hintStyle: TextStyle(
                                color: ColorConfig().gray3(),
                                fontSize: 12.0.sp,
                                fontWeight: FontWeight.w700,
                              ),
                              prefixIcon: Container(
                                margin: const EdgeInsets.only(
                                    left: 12.0, right: 4.0),
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
                              suffixIcon: searchController.text.isNotEmpty
                                  ? InkWell(
                                      onTap: () {
                                        setState(() {
                                          searchController.clear();
                                          isSearchComplete = false;
                                        });
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            left: 4.0, right: 12.0),
                                        child: SVGBuilder(
                                          image: 'assets/icon/close_normal.svg',
                                          width: 24.0.w,
                                          height: 24.0.w,
                                          color: ColorConfig().gray3(),
                                        ),
                                      ),
                                    )
                                  : null,
                              suffixIconConstraints: BoxConstraints(
                                maxWidth: 24.0.w + 12.0,
                                maxHeight: 24.0.w,
                              ),
                            ),
                            style: TextStyle(
                              color: ColorConfig().dark(),
                              fontSize: 12.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                            cursorColor: ColorConfig().primary(),
                            keyboardType: TextInputType.text,
                          ),
                        ),
                      ],
                    ),
                  ),
              bottom: isSearchComplete == true
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(46.0),
                      child: Container(
                        color: ColorConfig().white(),
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
                          tabs: const [
                            Tab(
                              text: TextConstant.ticketingText,
                            ),
                            Tab(
                              text: TextConstant.communityText,
                            ),
                          ],
                        ),
                      ),
                    )
                  : null,
            ),
        body: recommendData.isNotEmpty
            ? isSearchComplete == false
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: ColorConfig().white(),
                    child: SafeArea(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // 최근 검색어 타이틀 영역
                            categoryTitleWidget(
                                title: TextConstant.recentlySearch),
                            // 최근 검색어 리스트 영역
                            recentlySearchWordListWidget(),
                            // 추천 아티스트 타이틀 영역
                            categoryTitleWidget(
                                title: TextConstant.recommendArtist),
                            // 추천 아티스트 리스트 영역
                            recommendArtistListWidget(),
                            // 추천 공연 타이틀 영역
                            categoryTitleWidget(
                                title: TextConstant.recommendShow),
                            // 추천 공연 리스트 영역
                            recommendShowListWidget(),
                          ],
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: ColorConfig().gray1(),
                    child: SafeArea(
                      child: TabBarView(
                        controller: tabController,
                        children: [
                          // 티켓팅 영역
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                  color: Colors.amber,
                                ),
                              ],
                            ),
                          ),
                          // 커뮤니티 영역
                          SingleChildScrollView(
                            child:
                                searchData['shows'].isNotEmpty ||
                                        searchData['artists'].isNotEmpty ||
                                        searchData['users'].isNotEmpty
                                    ? Column(
                                        children: [
                                          // 공연 커뮤니티 타이틀 영역
                                          searchData['shows'].isNotEmpty
                                              ? categoryTitleWidget(
                                                  title: TextConstant
                                                      .showCommunity,
                                                  useCount: true,
                                                  count: searchData['shows']
                                                      .length)
                                              : Container(),
                                          // 공연 커뮤니티 리스트 영역
                                          searchData['shows'].isNotEmpty
                                              ? Column(
                                                  children: List.generate(
                                                      searchData['shows']
                                                          .length, (index) {
                                                    return InkWell(
                                                      onTap: () {
                                                        Navigator.pushNamed(
                                                            context,
                                                            'showCommunity',
                                                            arguments: {
                                                              'show_index': searchData[
                                                                          'shows']
                                                                      [index][
                                                                  'show_index'],
                                                            }).then((rt) async {
                                                          SearchAPI()
                                                              .search(
                                                                  accessToken:
                                                                      await SecureStorageConfig()
                                                                          .storage
                                                                          .read(
                                                                              key:
                                                                                  'access_token'),
                                                                  keyword:
                                                                      searchController
                                                                          .text)
                                                              .then((value) {
                                                            setState(() {
                                                              searchData =
                                                                  value.result[
                                                                      'data'];
                                                              isSearchComplete =
                                                                  true;
                                                            });
                                                          });
                                                        });
                                                      },
                                                      child: Container(
                                                        color: ColorConfig()
                                                            .white(),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    20.0,
                                                                vertical: 8.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: Row(
                                                                children: [
                                                                  // 포스터 이미지 영역
                                                                  Container(
                                                                    width:
                                                                        42.0.w,
                                                                    height:
                                                                        48.0.w,
                                                                    margin: EdgeInsets.only(
                                                                        left: 3.0
                                                                            .w,
                                                                        right: (15.0 +
                                                                            3.0.w)),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: searchData['shows'][index]['image'] ==
                                                                              null
                                                                          ? ColorConfig()
                                                                              .gray2()
                                                                          : null,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10.0.r),
                                                                      image: searchData['shows'][index]['image'] !=
                                                                              null
                                                                          ? DecorationImage(
                                                                              image: NetworkImage(searchData['shows'][index]['image']),
                                                                              fit: BoxFit.cover,
                                                                              filterQuality: FilterQuality.high,
                                                                            )
                                                                          : null,
                                                                    ),
                                                                    child: searchData['shows'][index]['image'] ==
                                                                            null
                                                                        ? Center(
                                                                            child:
                                                                                SVGBuilder(
                                                                              image: 'assets/icon/album.svg',
                                                                              width: 22.0.w,
                                                                              height: 22.0.w,
                                                                              color: ColorConfig().white(),
                                                                            ),
                                                                          )
                                                                        : Container(),
                                                                  ),
                                                                  // 제목 영역
                                                                  Expanded(
                                                                    child:
                                                                        CustomTextBuilder(
                                                                      text:
                                                                          '${searchData['shows'][index]['name']}',
                                                                      fontColor:
                                                                          ColorConfig()
                                                                              .gray5(),
                                                                      fontSize:
                                                                          12.0.sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      maxLines:
                                                                          1,
                                                                      textOverflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            // 팔로우 버튼 영역
                                                            InkWell(
                                                              onTap: () async {
                                                                if (searchData['shows']
                                                                            [
                                                                            index]
                                                                        [
                                                                        'is_follow'] ==
                                                                    false) {
                                                                  FollowAddOrCancel()
                                                                      .followApply(
                                                                          accessToken: await SecureStorageConfig().storage.read(
                                                                              key:
                                                                                  'access_token'),
                                                                          kind:
                                                                              'f',
                                                                          type:
                                                                              2,
                                                                          index: searchData['shows'][index]
                                                                              [
                                                                              'show_index'])
                                                                      .then(
                                                                          (value) {
                                                                    if (value.result[
                                                                            'status'] ==
                                                                        1) {
                                                                      setState(
                                                                          () {
                                                                        searchData['shows'][index]['is_follow'] =
                                                                            true;
                                                                      });
                                                                    }
                                                                  });
                                                                } else {
                                                                  FollowAddOrCancel()
                                                                      .followApply(
                                                                          accessToken: await SecureStorageConfig().storage.read(
                                                                              key:
                                                                                  'access_token'),
                                                                          kind:
                                                                              'u',
                                                                          type:
                                                                              2,
                                                                          index: searchData['shows'][index]
                                                                              [
                                                                              'show_index'])
                                                                      .then(
                                                                          (value) {
                                                                    if (value.result[
                                                                            'status'] ==
                                                                        1) {
                                                                      setState(
                                                                          () {
                                                                        searchData['shows'][index]['is_follow'] =
                                                                            false;
                                                                      });
                                                                    }
                                                                  });
                                                                }
                                                              },
                                                              child: Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            12.0),
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        12.0,
                                                                    vertical:
                                                                        8.0),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: searchData['shows'][index]
                                                                              [
                                                                              'is_follow'] ==
                                                                          false
                                                                      ? ColorConfig()
                                                                          .primary()
                                                                      : ColorConfig()
                                                                          .primaryLight(),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4.0.r),
                                                                ),
                                                                child: Center(
                                                                  child:
                                                                      CustomTextBuilder(
                                                                    text: searchData['shows'][index]['is_follow'] ==
                                                                            false
                                                                        ? TextConstant
                                                                            .follow
                                                                        : TextConstant
                                                                            .following,
                                                                    fontColor:
                                                                        ColorConfig()
                                                                            .white(),
                                                                    fontSize:
                                                                        12.0.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                )
                                              : Container(),
                                          // margin 영역
                                          searchData['shows'].isNotEmpty
                                              ? const SizedBox(height: 8.0)
                                              : Container(),
                                          // 아티스트 커뮤니티 타이틀 영역
                                          searchData['artists'].isNotEmpty
                                              ? categoryTitleWidget(
                                                  title: TextConstant
                                                      .artistCommunity,
                                                  useCount: true,
                                                  count: searchData['artists']
                                                      .length)
                                              : Container(),
                                          // 아티스트 커뮤니티 리스트 영역
                                          searchData['artists'].isNotEmpty
                                              ? Column(
                                                  children: List.generate(
                                                      searchData['artists']
                                                          .length, (index) {
                                                    return InkWell(
                                                      onTap: () {
                                                        Navigator.pushNamed(
                                                            context,
                                                            'artistCommunity',
                                                            arguments: {
                                                              'artist_index':
                                                                  searchData['artists']
                                                                          [
                                                                          index]
                                                                      [
                                                                      'artist_index'],
                                                            }).then((rt) async {
                                                          SearchAPI()
                                                              .search(
                                                                  accessToken:
                                                                      await SecureStorageConfig()
                                                                          .storage
                                                                          .read(
                                                                              key:
                                                                                  'access_token'),
                                                                  keyword:
                                                                      searchController
                                                                          .text)
                                                              .then((value) {
                                                            setState(() {
                                                              searchData =
                                                                  value.result[
                                                                      'data'];
                                                              isSearchComplete =
                                                                  true;
                                                            });
                                                          });
                                                        });
                                                      },
                                                      child: Container(
                                                        color: ColorConfig()
                                                            .white(),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    20.0,
                                                                vertical: 8.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: Row(
                                                                children: [
                                                                  // 프로필 이미지 영역
                                                                  Container(
                                                                    width:
                                                                        48.0.w,
                                                                    height:
                                                                        48.0.w,
                                                                    margin: const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            12.0),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              24.0.r),
                                                                      image: searchData['artists'][index]['image'] ==
                                                                              null
                                                                          ? const DecorationImage(
                                                                              image: AssetImage('assets/img/profile_default.png'),
                                                                              fit: BoxFit.cover,
                                                                              filterQuality: FilterQuality.high,
                                                                            )
                                                                          : DecorationImage(
                                                                              image: NetworkImage(searchData['artists'][index]['image']),
                                                                              fit: BoxFit.cover,
                                                                              filterQuality: FilterQuality.high,
                                                                            ),
                                                                    ),
                                                                  ),
                                                                  // 이름 영역
                                                                  Expanded(
                                                                    child:
                                                                        CustomTextBuilder(
                                                                      text:
                                                                          '${searchData['artists'][index]['name']}',
                                                                      fontColor:
                                                                          ColorConfig()
                                                                              .gray5(),
                                                                      fontSize:
                                                                          12.0.sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      maxLines:
                                                                          1,
                                                                      textOverflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            // 팔로우 버튼 영역
                                                            InkWell(
                                                              onTap: () async {
                                                                if (searchData['artists']
                                                                            [
                                                                            index]
                                                                        [
                                                                        'is_follow'] ==
                                                                    false) {
                                                                  FollowAddOrCancel()
                                                                      .followApply(
                                                                          accessToken: await SecureStorageConfig().storage.read(
                                                                              key:
                                                                                  'access_token'),
                                                                          kind:
                                                                              'f',
                                                                          type:
                                                                              3,
                                                                          index: searchData['artists'][index]
                                                                              [
                                                                              'artist_index'])
                                                                      .then(
                                                                          (value) {
                                                                    if (value.result[
                                                                            'status'] ==
                                                                        1) {
                                                                      setState(
                                                                          () {
                                                                        searchData['artists'][index]['is_follow'] =
                                                                            true;
                                                                      });
                                                                    }
                                                                  });
                                                                } else {
                                                                  FollowAddOrCancel()
                                                                      .followApply(
                                                                          accessToken: await SecureStorageConfig().storage.read(
                                                                              key:
                                                                                  'access_token'),
                                                                          kind:
                                                                              'u',
                                                                          type:
                                                                              3,
                                                                          index: searchData['artists'][index]
                                                                              [
                                                                              'artist_index'])
                                                                      .then(
                                                                          (value) {
                                                                    if (value.result[
                                                                            'status'] ==
                                                                        1) {
                                                                      setState(
                                                                          () {
                                                                        searchData['artists'][index]['is_follow'] =
                                                                            false;
                                                                      });
                                                                    }
                                                                  });
                                                                }
                                                              },
                                                              child: Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            12.0),
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        12.0,
                                                                    vertical:
                                                                        8.0),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: searchData['artists'][index]
                                                                              [
                                                                              'is_follow'] ==
                                                                          false
                                                                      ? ColorConfig()
                                                                          .primary()
                                                                      : ColorConfig()
                                                                          .primaryLight(),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4.0.r),
                                                                ),
                                                                child: Center(
                                                                  child:
                                                                      CustomTextBuilder(
                                                                    text: searchData['artists'][index]['is_follow'] ==
                                                                            false
                                                                        ? TextConstant
                                                                            .follow
                                                                        : TextConstant
                                                                            .following,
                                                                    fontColor:
                                                                        ColorConfig()
                                                                            .white(),
                                                                    fontSize:
                                                                        12.0.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                )
                                              : Container(),
                                          // margin 영역
                                          searchData['artists'].isNotEmpty
                                              ? const SizedBox(height: 8.0)
                                              : Container(),
                                          // 회원 타이틀 영역
                                          searchData['users'].isNotEmpty
                                              ? categoryTitleWidget(
                                                  title: TextConstant.user,
                                                  useCount: true,
                                                  count: searchData['users']
                                                      .length)
                                              : Container(),
                                          // 회원 리스트 영역
                                          searchData['users'].isNotEmpty
                                              ? Column(
                                                  children: List.generate(
                                                      searchData['users']
                                                          .length, (index) {
                                                    return InkWell(
                                                      onTap: () {
                                                        Navigator.pushNamed(
                                                            context,
                                                            'otherUserProfile',
                                                            arguments: {
                                                              'user_index': searchData[
                                                                          'users']
                                                                      [index][
                                                                  'user_index'],
                                                            }).then((rt) async {
                                                          SearchAPI()
                                                              .search(
                                                                  accessToken:
                                                                      await SecureStorageConfig()
                                                                          .storage
                                                                          .read(
                                                                              key:
                                                                                  'access_token'),
                                                                  keyword:
                                                                      searchController
                                                                          .text)
                                                              .then((value) {
                                                            setState(() {
                                                              searchData =
                                                                  value.result[
                                                                      'data'];
                                                              isSearchComplete =
                                                                  true;
                                                            });
                                                          });
                                                        });
                                                      },
                                                      child: Container(
                                                        color: ColorConfig()
                                                            .white(),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    20.0,
                                                                vertical: 8.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child: Row(
                                                                children: [
                                                                  // 프로필 이미지 영역
                                                                  Container(
                                                                    width:
                                                                        48.0.w,
                                                                    height:
                                                                        48.0.w,
                                                                    margin: const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            12.0),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              24.0.r),
                                                                      image: searchData['users'][index]['image'] ==
                                                                              null
                                                                          ? const DecorationImage(
                                                                              image: AssetImage('assets/img/profile_default.png'),
                                                                              fit: BoxFit.cover,
                                                                              filterQuality: FilterQuality.high,
                                                                            )
                                                                          : DecorationImage(
                                                                              image: NetworkImage(searchData['users'][index]['image']),
                                                                              fit: BoxFit.cover,
                                                                              filterQuality: FilterQuality.high,
                                                                            ),
                                                                    ),
                                                                  ),
                                                                  // 이름 영역
                                                                  Expanded(
                                                                    child:
                                                                        CustomTextBuilder(
                                                                      text:
                                                                          '${searchData['users'][index]['nick']}',
                                                                      fontColor:
                                                                          ColorConfig()
                                                                              .gray5(),
                                                                      fontSize:
                                                                          12.0.sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      maxLines:
                                                                          1,
                                                                      textOverflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            // 팔로우 버튼 영역
                                                            InkWell(
                                                              onTap: () async {
                                                                if (searchData['users']
                                                                            [
                                                                            index]
                                                                        [
                                                                        'is_follow'] ==
                                                                    false) {
                                                                  FollowAddOrCancel()
                                                                      .followApply(
                                                                          accessToken: await SecureStorageConfig().storage.read(
                                                                              key:
                                                                                  'access_token'),
                                                                          kind:
                                                                              'f',
                                                                          type:
                                                                              1,
                                                                          index: searchData['users'][index]
                                                                              [
                                                                              'user_index'])
                                                                      .then(
                                                                          (value) {
                                                                    if (value.result[
                                                                            'status'] ==
                                                                        1) {
                                                                      setState(
                                                                          () {
                                                                        searchData['users'][index]['is_follow'] =
                                                                            true;
                                                                      });
                                                                    }
                                                                  });
                                                                } else {
                                                                  FollowAddOrCancel()
                                                                      .followApply(
                                                                          accessToken: await SecureStorageConfig().storage.read(
                                                                              key:
                                                                                  'access_token'),
                                                                          kind:
                                                                              'u',
                                                                          type:
                                                                              1,
                                                                          index: searchData['users'][index]
                                                                              [
                                                                              'user_index'])
                                                                      .then(
                                                                          (value) {
                                                                    if (value.result[
                                                                            'status'] ==
                                                                        1) {
                                                                      setState(
                                                                          () {
                                                                        searchData['users'][index]['is_follow'] =
                                                                            false;
                                                                      });
                                                                    }
                                                                  });
                                                                }
                                                              },
                                                              child: Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            12.0),
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        12.0,
                                                                    vertical:
                                                                        8.0),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: searchData['users'][index]
                                                                              [
                                                                              'is_follow'] ==
                                                                          false
                                                                      ? ColorConfig()
                                                                          .primary()
                                                                      : ColorConfig()
                                                                          .primaryLight(),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              4.0.r),
                                                                ),
                                                                child: Center(
                                                                  child:
                                                                      CustomTextBuilder(
                                                                    text: searchData['users'][index]['is_follow'] ==
                                                                            false
                                                                        ? TextConstant
                                                                            .follow
                                                                        : TextConstant
                                                                            .following,
                                                                    fontColor:
                                                                        ColorConfig()
                                                                            .white(),
                                                                    fontSize:
                                                                        12.0.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                )
                                              : Container(),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 32.0),
                                            child: Column(
                                              children: [
                                                CustomTextBuilder(
                                                  text:
                                                      '\'${searchController.text}\'에 대한 검색결과가 없습니다.',
                                                  fontColor:
                                                      ColorConfig().dark(),
                                                  fontSize: 14.0.sp,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      top: 8.0),
                                                  child: CustomTextBuilder(
                                                    text:
                                                        '다양한 공연과 아티스트를 팔로우해보세요!',
                                                    fontColor:
                                                        ColorConfig().dark(),
                                                    fontSize: 12.0.sp,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // 추천 공연 타이틀 영역
                                          categoryTitleWidget(
                                              title:
                                                  TextConstant.recommendShow),
                                          // 추천 공연 리스트 영역
                                          recommendShowListWidget(),
                                          // 추천 아티스트 타이틀 영역
                                          categoryTitleWidget(
                                              title:
                                                  TextConstant.recommendArtist),
                                          // 추천 아티스트 리스트 영역
                                          recommendArtistListWidget(),
                                        ],
                                      ),
                          ),
                        ],
                      ),
                    ),
                  )
            : Container(),
      ),
    );
  }

  // 구분 타이틀 위젯
  Widget categoryTitleWidget(
      {required String title, bool useCount = false, int count = 0}) {
    if (useCount == true) {
      return Container(
        width: MediaQuery.of(context).size.width,
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
              text: count.toString(),
              fontColor: ColorConfig().primary(),
              fontSize: 14.0.sp,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.5),
      child: CustomTextBuilder(
        text: title,
        fontColor: ColorConfig().dark(),
        fontSize: 14.0.sp,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // 최근 검색어 리스트 위젯
  Widget recentlySearchWordListWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 12.0, 4.0),
      child: Wrap(
        children: List.generate(searchHistories.length, (index) {
          return InkWell(
            onTap: () async {
              SearchAPI()
                  .search(
                      accessToken: await SecureStorageConfig()
                          .storage
                          .read(key: 'access_token'),
                      keyword: searchHistories[index])
                  .then((value) {
                setState(() {
                  searchController.text = searchHistories[index];
                  searchData = value.result['data'];
                  isSearchComplete = true;
                });
              });
            },
            child: IntrinsicWidth(
              child: Container(
                margin: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: ColorConfig().tagLabelBackground(opacity: 0.6),
                  borderRadius: BorderRadius.circular(1.0.r),
                ),
                child: Row(
                  children: [
                    CustomTextBuilder(
                      text: searchHistories[index],
                      fontColor: ColorConfig().white(),
                      fontSize: 12.0.sp,
                      fontWeight: FontWeight.w700,
                      height: null,
                    ),
                    InkWell(
                      onTap: () async {
                        final prefs = await SharedPreferences.getInstance();

                        setState(() {
                          searchHistories.removeAt(index);
                        });

                        prefs.setStringList('SearchList', searchHistories);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 4.0),
                        child: SVGBuilder(
                          image: 'assets/icon/close_normal.svg',
                          width: 16.0.w,
                          height: 16.0.w,
                          color: ColorConfig().white(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // 아티스트 리스트 위젯
  Widget recommendArtistListWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 16.0 + 72.0.w + 10.0 + 12.0.sp + 4.0,
      padding: const EdgeInsets.only(top: 4.0, bottom: 12.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        itemCount: recommendData['artists'].length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.pushNamed(context, 'artistCommunity', arguments: {
                'artist_index': recommendData['artists'][index]['artist_index'],
              });
            },
            child: Container(
              margin: index != recommendData['artists'].length - 1
                  ? const EdgeInsets.only(right: 16.0)
                  : null,
              child: Column(
                children: [
                  // 아티스트 이미지 영역
                  Container(
                    width: 72.0.w,
                    height: 72.0.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36.0.r),
                      image: recommendData['artists'][index]['image'] == null
                          ? const DecorationImage(
                              image:
                                  AssetImage('assets/img/profile_default.png'),
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            )
                          : DecorationImage(
                              image: NetworkImage(
                                  recommendData['artists'][index]['image']),
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            ),
                    ),
                  ),
                  // 아티스트 이름 영역
                  Container(
                    margin: const EdgeInsets.only(top: 10.0, bottom: 4.0),
                    child: CustomTextBuilder(
                      text: '${recommendData['artists'][index]['name']}',
                      fontColor: ColorConfig().dark(),
                      fontSize: 12.0.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 추천 공연 리스트 위젯
  Widget recommendShowListWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 4.0 + 172.0.w,
      margin: const EdgeInsets.only(top: 4.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        itemCount: recommendData['shows'].length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.pushNamed(context, 'showCommunity', arguments: {
                'show_index': recommendData['shows'][index]['show_index'],
              });
            },
            child: Container(
              width: 120.0.w,
              height: 172.0.w,
              margin: index != recommendData['shows'].length - 1
                  ? const EdgeInsets.only(right: 8.0)
                  : null,
              decoration: BoxDecoration(
                color: recommendData['shows'][index]['image'] == null
                    ? ColorConfig().gray2()
                    : null,
                borderRadius: BorderRadius.circular(4.0.r),
                image: recommendData['shows'][index]['image'] != null
                    ? DecorationImage(
                        image: NetworkImage(
                            recommendData['shows'][index]['image']),
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      )
                    : null,
              ),
              child: recommendData['shows'][index]['image'] == null
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
          );
        },
      ),
    );
  }
}
