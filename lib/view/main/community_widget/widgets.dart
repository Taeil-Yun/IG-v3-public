import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/api/like/add_like.dart';
import 'package:ig-public_v3/api/like/cancel_like.dart';
import 'package:ig-public_v3/api/main/main_community.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/costant/build_config.dart';

import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/costant/exception_data.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/util/share.dart';
import 'package:ig-public_v3/view/main/profile_main.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:intl/intl.dart';

class MainCommunityWidgetBuilder {
  /// 리얼후기 위젯
  Widget realReviewListWidget({required List data}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0.0, 9.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    CustomTextBuilder(
                      text: TextConstant.bestRealReview,
                      fontColor: ColorConfig().white(),
                      fontSize: 16.0.sp,
                      fontWeight: FontWeight.w800,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 4.0),
                      child: SVGBuilder(
                        image: 'assets/icon/arrow_right_light.svg',
                        width: 12.0.w,
                        height: 16.0.w,
                        color: ColorConfig().white(),
                      ),
                    ),
                  ],
                ),
              ),
              CustomTextBuilder(
                text: 'ig-public 회원님들이 직접 관람하고 남긴 공연후기를 볼 수 있어요',
                fontColor: ColorConfig().white(),
                fontSize: 12.0.sp,
                fontWeight: FontWeight.w400,
              ),
            ],
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 126.0.w),
          child: ListView.builder(
            itemCount: data.length,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.pushNamed(context, 'postDetail', arguments: {
                    'community_index': data[index]['community_index'],
                  });
                },
                child: Container(
                  width: 208.0.w,
                  padding: const EdgeInsets.fromLTRB(20.0, 12.0, 8.0, 14.0),
                  margin: EdgeInsets.only(right: index != 4 ? 8.0 : 0.0),
                  decoration: BoxDecoration(
                    color: ColorConfig().white(),
                    borderRadius: BorderRadius.circular(6.0.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 프로필, 닉네임, 리얼후기 뱃지
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 프로필, 닉네임
                          Row(
                            children: [
                              Container(
                                width: 20.0.w,
                                height: 20.0.w,
                                margin: const EdgeInsets.only(right: 4.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0.r),
                                  image: data[index]['image'] == null
                                      ? const DecorationImage(
                                          image: AssetImage(
                                              'assets/img/profile_default.png'),
                                          fit: BoxFit.cover,
                                          filterQuality: FilterQuality.high,
                                        )
                                      : DecorationImage(
                                          image: NetworkImage(
                                              data[index]['image']),
                                          fit: BoxFit.cover,
                                          filterQuality: FilterQuality.high,
                                        ),
                                ),
                              ),
                              CustomTextBuilder(
                                text: '${data[index]['nick']}',
                                fontColor: ColorConfig().primaryLight(),
                                fontSize: 10.0.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ],
                          ),
                          // 리얼후기 뱃지
                          SVGStringBuilder(
                            image: 'assets/icon/cms_management.svg',
                            width: 24.0.w,
                            height: 24.0.w,
                          ),
                        ],
                      ),
                      // 공연 이름
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: CustomTextBuilder(
                          text: '${data[index]['show_name']}',
                          fontColor: ColorConfig().dark(),
                          fontSize: 14.0.sp,
                          fontWeight: FontWeight.w800,
                          maxLines: 1,
                          textOverflow: TextOverflow.visible,
                        ),
                      ),
                      // 후기 내용
                      CustomTextBuilder(
                        text: '${data[index]['content']}',
                        fontColor: ColorConfig().gray5(),
                        fontSize: 12.0.sp,
                        fontWeight: FontWeight.w400,
                        maxLines: 3,
                        textOverflow: TextOverflow.ellipsis,
                        height: 1.1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 실시간 HOT글 위젯
  Widget realtimeHOTPostWidget({required List data}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                CustomTextBuilder(
                  text: TextConstant.realtimeHOT,
                  fontColor: ColorConfig().white(),
                  fontSize: 16.0.sp,
                  fontWeight: FontWeight.w800,
                ),
                Container(
                  margin: const EdgeInsets.only(left: 4.0),
                  child: SVGBuilder(
                    image: 'assets/icon/arrow_right_light.svg',
                    width: 12.0.w,
                    height: 16.0.w,
                    color: ColorConfig().white(),
                  ),
                ),
              ],
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 209.0.w + 16.0),
          child: ListView.builder(
            itemCount: data.length,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.pushNamed(context, 'postDetail', arguments: {
                    'community_index': data[index]['community_index'],
                  });
                },
                child: Container(
                  width: 140.0.w,
                  padding: const EdgeInsets.all(8.0),
                  margin: EdgeInsets.only(right: index != 4 ? 8.0 : 0.0),
                  decoration: BoxDecoration(
                    color: ColorConfig().white(),
                    borderRadius: BorderRadius.circular(6.0.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 이미지
                      Container(
                        width: 124.0.w,
                        height: 100.0.w,
                        decoration: BoxDecoration(
                          color: data[index]['image1'] == null
                              ? ColorConfig().gray2()
                              : null,
                          borderRadius: BorderRadius.circular(6.0.r),
                          image: data[index]['image1'] != null
                              ? DecorationImage(
                                  image: NetworkImage(data[index]['image1']),
                                  fit: BoxFit.cover,
                                  filterQuality: FilterQuality.high,
                                )
                              : null,
                        ),
                        child: data[index]['image1'] == null
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
                      // 내용
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: CustomTextBuilder(
                            text: '${data[index]['content']}',
                            fontColor: ColorConfig().gray5(),
                            fontSize: 11.0.sp,
                            fontWeight: FontWeight.w400,
                            maxLines: 5,
                            textOverflow: TextOverflow.ellipsis,
                            height: 1.0,
                          ),
                        ),
                      ),
                      // 사용자 정보, 업로드 날짜
                      Row(
                        children: [
                          Container(
                            width: 30.0.w,
                            height: 30.0.w,
                            margin: const EdgeInsets.only(right: 4.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0.r),
                              image: data[index]['image'] == null
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
                                    ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 4.0),
                                  child: CustomTextBuilder(
                                    text: '${data[index]['nick']}',
                                    fontColor: ColorConfig().dark(),
                                    fontSize: 10.0.sp,
                                    fontWeight: FontWeight.w700,
                                    maxLines: 1,
                                    textOverflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                CustomTextBuilder(
                                  text: DateFormat('yyyy.MM.dd HH:mm').format(
                                      DateTime.parse(data[index]['modify_dt'])
                                          .toLocal()),
                                  fontColor: ColorConfig().gray3(),
                                  fontSize: 9.0.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 게시물 리스트
  Widget feedList(BuildContext context,
      {required List data,
      bool onProfile = false,
      String? type,
      int? typeIndex}) {
    List ldata = data;
    int dotsIndex = 0;

    return StatefulBuilder(builder: (context, state) {
      return Column(
        children: List.generate(ldata.length, (index) {
          return InkWell(
            onTap: () {
              Navigator.pushNamed(context, 'postDetail', arguments: {
                'community_index': ldata[index]['community_index'],
              }).then((rt) async {
                if (type == null) {
                  MainCommunityListAPI()
                      .communityList(
                          accessToken: await SecureStorageConfig()
                              .storage
                              .read(key: 'access_token'),
                          type: 1)
                      .then((value) {
                    state(() {
                      ldata = value.result['data'];
                    });
                  });
                } else if (type == 'S') {
                  MainCommunityListAPI()
                      .communityList(
                          accessToken: await SecureStorageConfig()
                              .storage
                              .read(key: 'access_token'),
                          type: 1,
                          showIndex: typeIndex)
                      .then((value) {
                    state(() {
                      ldata = value.result['data'];
                    });
                  });
                } else if (type == 'A') {
                  MainCommunityListAPI()
                      .communityList(
                          accessToken: await SecureStorageConfig()
                              .storage
                              .read(key: 'access_token'),
                          type: 1,
                          artistIndex: typeIndex)
                      .then((value) {
                    state(() {
                      ldata = value.result['data'];
                    });
                  });
                } else if (type == 'U') {
                  MainCommunityListAPI()
                      .communityList(
                          accessToken: await SecureStorageConfig()
                              .storage
                              .read(key: 'access_token'),
                          type: 1,
                          userIndex: typeIndex)
                      .then((value) {
                    state(() {
                      ldata = value.result['data'];
                    });
                  });
                }
              });
            },
            child: Container(
              margin: EdgeInsets.only(bottom: !onProfile ? 16.0 : 8.0),
              color: ColorConfig().white(),
              child: Column(
                children: [
                  // 피드영역
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 사용자 이미지, 닉네임, 공연종류
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 이미지, 닉네임
                            InkWell(
                              onTap: () {
                                if (ldata[index]['is_mine'] == false) {
                                  Navigator.pushNamed(
                                      context, 'otherUserProfile',
                                      arguments: {
                                        'user_index': ldata[index]
                                            ['user_index'],
                                      }).then((rt) async {
                                    MainCommunityListAPI()
                                        .communityList(
                                            accessToken:
                                                await SecureStorageConfig()
                                                    .storage
                                                    .read(key: 'access_token'),
                                            type: 1)
                                        .then((result) {
                                      state(() {
                                        ldata = result.result['data'];
                                      });
                                    });
                                  });
                                } else {
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MainMyProfileScreen(
                                                      isNavigator: true)))
                                      .then((rt) async {
                                    MainCommunityListAPI()
                                        .communityList(
                                            accessToken:
                                                await SecureStorageConfig()
                                                    .storage
                                                    .read(key: 'access_token'),
                                            type: 1)
                                        .then((result) {
                                      state(() {
                                        ldata = result.result['data'];
                                      });
                                    });
                                  });
                                }
                              },
                              child: Row(
                                children: [
                                  // 이미지
                                  Container(
                                    width: 30.0.w,
                                    height: 30.0.w,
                                    margin: const EdgeInsets.only(right: 8.0),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(15.0.r),
                                        image: ldata[index]['image'] != null
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                    ldata[index]['image']),
                                                fit: BoxFit.cover,
                                                filterQuality:
                                                    FilterQuality.high,
                                              )
                                            : const DecorationImage(
                                                image: AssetImage(
                                                    'assets/img/profile_default.png'),
                                                fit: BoxFit.cover,
                                                filterQuality:
                                                    FilterQuality.high,
                                              )),
                                  ),
                                  // 닉네임, 업로드 날짜
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 4.0),
                                        child: CustomTextBuilder(
                                          text: '${ldata[index]['nick']}',
                                          fontColor: ColorConfig().gray3(),
                                          fontSize: 12.0.sp,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      CustomTextBuilder(
                                        text: DateFormat('yyyy.MM.dd HH:mm')
                                            .format(DateTime.parse(
                                                    ldata[index]['modify_dt'])
                                                .toLocal()),
                                        fontColor: ColorConfig().gray3(),
                                        fontSize: 9.0.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            // 공연종류
                            InkWell(
                              onTap: () {
                                if (ldata[index]['type'] == 'S') {
                                  Navigator.pushNamed(context, 'showCommunity',
                                      arguments: {
                                        'show_index': ldata[index]
                                            ['show_index'],
                                      });
                                } else if (ldata[index]['type'] == 'A') {
                                  Navigator.pushNamed(
                                      context, 'artistCommunity',
                                      arguments: {
                                        'artist_index': ldata[index]
                                            ['artist_index'],
                                      });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4.0, vertical: 6.0),
                                decoration: BoxDecoration(
                                  color: ColorConfig().primary(),
                                  borderRadius: BorderRadius.circular(3.0.r),
                                ),
                                child: Center(
                                  child: CustomTextBuilder(
                                    text: '${ldata[index]['item_name']}',
                                    fontColor: ColorConfig().white(),
                                    fontSize: 11.0.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 사진 이미지 영역
                      ldata[index]['images'].where((e) => e != null).length != 0
                          ? Container(
                              height: 235.0.w,
                              margin: const EdgeInsets.only(top: 12.0),
                              child: PageView.builder(
                                controller: PageController(
                                    viewportFraction: 0.9, keepPage: false),
                                scrollDirection: Axis.horizontal,
                                itemCount: ldata[index]['images']
                                    .where(
                                        (e) => e != null && e != imageException)
                                    .length,
                                onPageChanged: (value) {
                                  state(() {
                                    dotsIndex = value;
                                  });
                                },
                                itemBuilder: (context, imageIndex) {
                                  ldata[index]['images'].remove(imageException);
                                  return Container(
                                    margin: EdgeInsets.only(
                                        left: imageIndex == 0 ? 0.0 : 0.0,
                                        right: imageIndex !=
                                                ldata[index]['images']
                                                        .where((e) =>
                                                            e != null &&
                                                            e != imageException)
                                                        .length -
                                                    1
                                            ? 8.0
                                            : 0.0),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(4.0.r),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            ldata[index]['images'][imageIndex]),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(),
                      // dots paging
                      ldata[index]['images'].where((e) => e != null).length > 1
                          ? Container(
                              margin: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                    ldata[index]['images']
                                        .where((e) =>
                                            e != null && e != imageException)
                                        .length, (dots) {
                                  ldata[index]['images'].remove(imageException);
                                  return Container(
                                    width: 6.0.w,
                                    height: 6.0.w,
                                    margin: dots !=
                                            ldata[index]['images']
                                                    .where((e) =>
                                                        e != null &&
                                                        e != imageException)
                                                    .length -
                                                1
                                        ? const EdgeInsets.only(right: 4.0)
                                        : null,
                                    decoration: BoxDecoration(
                                      color: dots == dotsIndex
                                          ? ColorConfig().primary()
                                          : ColorConfig().gray3(),
                                      borderRadius:
                                          BorderRadius.circular(3.0.r),
                                    ),
                                  );
                                }),
                              ),
                            )
                          : Container(),
                      // 제목영역
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                        child: CustomTextBuilder(
                          text: '${ldata[index]['title']}',
                          fontColor: ColorConfig().dark(),
                          fontSize: 14.0.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      // 내용영역
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                        child: CustomTextBuilder(
                          text: '${ldata[index]['content']}',
                          fontColor: ColorConfig().dark(),
                          fontSize: 12.0.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
                        child: Row(
                          children: [
                            // 댓글 개수 영역
                            Row(
                              children: [
                                SVGBuilder(
                                  image: 'assets/icon/reply.svg',
                                  width: 16.0.w,
                                  height: 16.0.w,
                                  color: ColorConfig().gray3(),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 4.0),
                                  child: CustomTextBuilder(
                                    text: '${ldata[index]['reply_count']}',
                                    fontColor: ColorConfig().gray3(),
                                    fontSize: 12.0.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16.0),
                            // 좋아요 개수 영역
                            Row(
                              children: [
                                SVGBuilder(
                                  image: 'assets/icon/favorite.svg',
                                  width: 16.0.w,
                                  height: 16.0.w,
                                  color: ColorConfig().gray3(),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 4.0),
                                  child: CustomTextBuilder(
                                    text: '${ldata[index]['like_count']}',
                                    fontColor: ColorConfig().gray3(),
                                    fontSize: 12.0.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // 좋아요, 댓글달기, 공유하기 레이어
                  userActionAreaWidget(context, data: ldata[index]),
                ],
              ),
            ),
          );
        }),
      );
    });
  }

  // 공연후기 리스트
  Widget showReviewList(BuildContext context,
      {required List data, bool onProfile = false}) {
    List ldata = data;

    return StatefulBuilder(builder: (context, state) {
      return Column(
        children: List.generate(ldata.length, (index) {
          int dotsIndex = 0;

          return InkWell(
            onTap: () {
              Navigator.pushNamed(context, 'postDetail', arguments: {
                'community_index': ldata[index]['community_index'],
              }).then((rt) async {
                if (ldata[index]['is_mine'] == false) {
                  MainCommunityListAPI()
                      .communityList(
                          accessToken: await SecureStorageConfig()
                              .storage
                              .read(key: 'access_token'),
                          type: 2)
                      .then((result) {
                    state(() {
                      ldata = result.result['data'];
                    });
                  });
                }
              });
            },
            child: Container(
              margin: EdgeInsets.only(bottom: !onProfile ? 16.0 : 8.0),
              color: ColorConfig().white(),
              child: Column(
                children: [
                  // 피드영역
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 사용자 이미지, 닉네임, 공연종류
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 이미지, 닉네임
                            InkWell(
                              onTap: () {
                                if (ldata[index]['is_mine'] == false) {
                                  Navigator.pushNamed(
                                      context, 'otherUserProfile',
                                      arguments: {
                                        'user_index': ldata[index]
                                            ['user_index'],
                                      }).then((rt) async {
                                    MainCommunityListAPI()
                                        .communityList(
                                            accessToken:
                                                await SecureStorageConfig()
                                                    .storage
                                                    .read(key: 'access_token'),
                                            type: 2)
                                        .then((result) {
                                      state(() {
                                        ldata = result.result['data'];
                                      });
                                    });
                                  });
                                } else {
                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MainMyProfileScreen(
                                                      isNavigator: true)))
                                      .then((rt) async {
                                    MainCommunityListAPI()
                                        .communityList(
                                            accessToken:
                                                await SecureStorageConfig()
                                                    .storage
                                                    .read(key: 'access_token'),
                                            type: 2)
                                        .then((result) {
                                      state(() {
                                        ldata = result.result['data'];
                                      });
                                    });
                                  });
                                }
                              },
                              child: Row(
                                children: [
                                  // 이미지
                                  Container(
                                    width: 30.0.w,
                                    height: 30.0.w,
                                    margin: const EdgeInsets.only(right: 8.0),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(15.0.r),
                                        image: ldata[index]['image'] != null
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                    ldata[index]['image']),
                                                fit: BoxFit.cover,
                                                filterQuality:
                                                    FilterQuality.high,
                                              )
                                            : const DecorationImage(
                                                image: AssetImage(
                                                    'assets/img/profile_default.png'),
                                                fit: BoxFit.cover,
                                                filterQuality:
                                                    FilterQuality.high,
                                              )),
                                  ),
                                  // 닉네임, 업로드 날짜
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 4.0),
                                        child: CustomTextBuilder(
                                          text: '${ldata[index]['nick']}',
                                          fontColor: ColorConfig().gray3(),
                                          fontSize: 12.0.sp,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      CustomTextBuilder(
                                        text: DateFormat('yyyy.MM.dd HH:mm')
                                            .format(DateTime.parse(
                                                    ldata[index]['modify_dt'])
                                                .toLocal()),
                                        fontColor: ColorConfig().gray3(),
                                        fontSize: 9.0.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 공연 이름 영역
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
                        child: CustomTextBuilder(
                          text: '${ldata[index]['item_name']}',
                          fontColor: ColorConfig().dark(),
                          fontSize: 14.0.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      // 별점 영역
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: RatingBar.builder(
                          initialRating: ldata[index]['star'] / 10,
                          minRating: 1,
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
                      ),
                      // 장소 영역
                      ldata[index]['location'].isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 4.0),
                              child: Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 4.0),
                                    child: SVGBuilder(
                                      image: 'assets/icon/location.svg',
                                      width: 12.0.w,
                                      height: 12.0.w,
                                      color: ColorConfig().dark(),
                                    ),
                                  ),
                                  CustomTextBuilder(
                                    text: '${ldata[index]['location']}',
                                    fontColor: ColorConfig().dark(),
                                    fontSize: 12.0.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      // 출연진 영역
                      ldata[index]['casting'].isNotEmpty
                          ? Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 4.0),
                                    child: SVGBuilder(
                                      image: 'assets/icon/cast.svg',
                                      width: 12.0.w,
                                      height: 12.0.w,
                                      color: ColorConfig().dark(),
                                    ),
                                  ),
                                  Expanded(
                                    child: CustomTextBuilder(
                                      text: '${ldata[index]['casting']}',
                                      fontColor: ColorConfig().gray4(),
                                      fontSize: 12.0.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      // 사진 이미지 영역
                      ldata[index]['images'].where((e) => e != null).length != 0
                          ? Container(
                              height: 235.0.w,
                              margin: const EdgeInsets.only(top: 12.0),
                              child: PageView.builder(
                                controller: PageController(
                                    viewportFraction: 0.9, keepPage: false),
                                scrollDirection: Axis.horizontal,
                                itemCount: ldata[index]['images']
                                    .where(
                                        (e) => e != null && e != imageException)
                                    .length,
                                onPageChanged: (value) {
                                  state(() {
                                    dotsIndex = value;
                                  });
                                },
                                itemBuilder: (context, imageIndex) {
                                  ldata[index]['images'].remove(imageException);
                                  return Container(
                                    margin: EdgeInsets.only(
                                        left: imageIndex == 0 ? 0.0 : 0.0,
                                        right: imageIndex !=
                                                ldata[index]['images']
                                                        .where((e) =>
                                                            e != null &&
                                                            e != imageException)
                                                        .length -
                                                    1
                                            ? 8.0
                                            : 0.0),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(4.0.r),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            ldata[index]['images'][imageIndex]),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(),
                      // dots paging
                      ldata[index]['images']
                                  .where(
                                      (e) => e != null && e != imageException)
                                  .length >
                              1
                          ? Container(
                              margin: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                    ldata[index]['images']
                                        .where((e) =>
                                            e != null && e != imageException)
                                        .length, (dots) {
                                  ldata[index]['images'].remove(imageException);
                                  return Container(
                                    width: 6.0.w,
                                    height: 6.0.w,
                                    margin: dots !=
                                            ldata[index]['images']
                                                    .where((e) =>
                                                        e != null &&
                                                        e != imageException)
                                                    .length -
                                                1
                                        ? const EdgeInsets.only(right: 4.0)
                                        : null,
                                    decoration: BoxDecoration(
                                      color: dots == dotsIndex
                                          ? ColorConfig().primary()
                                          : ColorConfig().gray3(),
                                      borderRadius:
                                          BorderRadius.circular(3.0.r),
                                    ),
                                  );
                                }),
                              ),
                            )
                          : Container(),
                      // 내용영역
                      ldata[index]['content'].isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16.0, 8.0, 16.0, 16.0),
                              child: CustomTextBuilder(
                                text: '${ldata[index]['content']}',
                                fontColor: ColorConfig().dark(),
                                fontSize: 12.0.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          : Container(),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
                        child: Row(
                          children: [
                            // 댓글 개수 영역
                            Row(
                              children: [
                                SVGBuilder(
                                  image: 'assets/icon/reply.svg',
                                  width: 16.0.w,
                                  height: 16.0.w,
                                  color: ColorConfig().gray3(),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 4.0),
                                  child: CustomTextBuilder(
                                    text: '${ldata[index]['reply_count']}',
                                    fontColor: ColorConfig().gray3(),
                                    fontSize: 12.0.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16.0),
                            // 좋아요 개수 영역
                            Row(
                              children: [
                                SVGBuilder(
                                  image: 'assets/icon/favorite.svg',
                                  width: 16.0.w,
                                  height: 16.0.w,
                                  color: ColorConfig().gray3(),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 4.0),
                                  child: CustomTextBuilder(
                                    text: '${ldata[index]['like_count']}',
                                    fontColor: ColorConfig().gray3(),
                                    fontSize: 12.0.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // 좋아요, 댓글달기, 공유하기 레이어
                  userActionAreaWidget(context, data: ldata[index]),
                ],
              ),
            ),
          );
        }),
      );
    });
  }

  /// 좋아요, 댓글달기, 공유하기등 유저 활동 위젯
  Widget userActionAreaWidget(BuildContext context, {dynamic data}) {
    Timer? _debounce;

    return StatefulBuilder(builder: (context, state) {
      return Row(
        children: [
          // 좋아요 버튼
          InkWell(
            onTap: () async {
              if (data['is_like'] == false) {
                AddLikeAPI()
                    .addLike(
                        accessToken: await SecureStorageConfig()
                            .storage
                            .read(key: 'access_token'),
                        communityIndex: data['community_index'])
                    .then((value) {
                  if (value.result['status'] == 1) {
                    state(() {
                      data['is_like'] = true;
                      data['like_count'] += 1;
                    });
                  }
                });
              } else {
                CancelLikeAPI()
                    .cancelLike(
                        accessToken: await SecureStorageConfig()
                            .storage
                            .read(key: 'access_token'),
                        communityIndex: data['community_index'])
                    .then((value) {
                  if (value.result['status'] == 1) {
                    state(() {
                      data['is_like'] = false;
                      data['like_count'] -= 1;
                    });
                  }
                });
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 3,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    width: 1.0,
                    color: ColorConfig().gray2(),
                  ),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 4.0),
                      child: SVGBuilder(
                        image: data['is_like'] == true
                            ? 'assets/icon/heart-on-disabled-bg.svg'
                            : 'assets/icon/heart-off-disabled-bg.svg',
                        width: 16.0.w,
                        height: 16.0.w,
                        color: ColorConfig().gray5(),
                      ),
                    ),
                    CustomTextBuilder(
                      text: TextConstant.addHeart,
                      fontColor: ColorConfig().gray5(),
                      fontSize: 12.0.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 댓글달기 버튼
          Container(
            width: MediaQuery.of(context).size.width / 3,
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 1.0,
                  color: ColorConfig().gray2(),
                ),
                left: BorderSide(
                  width: 1.0,
                  color: ColorConfig().gray2(),
                ),
                right: BorderSide(
                  width: 1.0,
                  color: ColorConfig().gray2(),
                ),
              ),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 4.0),
                    child: SVGBuilder(
                      image: 'assets/icon/chat-off.svg',
                      width: 16.0.w,
                      height: 16.0.w,
                      color: ColorConfig().gray5(),
                    ),
                  ),
                  CustomTextBuilder(
                    text: TextConstant.addComment,
                    fontColor: ColorConfig().gray5(),
                    fontSize: 12.0.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ],
              ),
            ),
          ),
          // 공유하기 버튼
          InkWell(
            onTap: () {
              if (_debounce?.isActive ?? false) _debounce!.cancel();

              _debounce = Timer(const Duration(milliseconds: 300), () async {
                shareBuilder(context,
                    type: 'community', index: data['community_index']);
              });
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 3,
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    width: 1.0,
                    color: ColorConfig().gray2(),
                  ),
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 4.0),
                      child: SVGBuilder(
                        image: 'assets/icon/share.svg',
                        width: 16.0.w,
                        height: 16.0.w,
                        color: ColorConfig().gray5(),
                      ),
                    ),
                    CustomTextBuilder(
                      text: TextConstant.share,
                      fontColor: ColorConfig().gray5(),
                      fontSize: 12.0.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
