import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/api/drawer/end_drawer.dart';
import 'package:ig-public_v3/costant/build_config.dart';

import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/costant/enumerated.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/util/set_intl.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';

class ig-publicEndDrawerWidget extends StatefulWidget {
  const ig-publicEndDrawerWidget({super.key});

  @override
  State<ig-publicEndDrawerWidget> createState() => _ig-publicEndDrawerWidgetState();
}

class _ig-publicEndDrawerWidgetState extends State<ig-publicEndDrawerWidget> {
  Map<String, dynamic> myData = {};

  @override
  void initState() {
    super.initState();

    initializeAPI();
  }

  Future<void> initializeAPI() async {
    EndDrawerDataAPI().endDrawer(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) {
      setState(() {
        myData = value.result['data'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (myData.isNotEmpty) {
      return SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Container(
          width: MediaQuery.of(context).size.width / 1.2,
          height: MediaQuery.of(context).size.height + 36.0 + 4.0 + 14.0.sp + 16.0.w,
          color: ColorConfig.defaultWhite,
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      // 닫기 버튼 영역
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        onPressed: () {
                          Scaffold.of(context).closeEndDrawer();
                        },
                        icon: const Icon(Icons.close),
                      ),
                    ),
                    // 프로필 영역
                    profileDataWidget(),
                    // ig-public머니, ig-public포인트 영역
                    ig-publicMoneyAndPointWidget(),
                    // 알림함, 예매내역, 글쓰기 영역
                    utilizationWidget(),
                    // 공연 콘텐츠
                    myData['shows'].isNotEmpty ? followContentsTitle(title: TextConstant.folllowShow, count: myData['shows'].length) : Container(),
                    myData['shows'].isNotEmpty ? followContentsData(type: EndDrawerTicketContentType.ticketing) : Container(),
                    myData['shows'].isNotEmpty ? emptySpace(height: 20.0) : Container(),
                    myData['artists'].isNotEmpty ? followContentsTitle(title: TextConstant.followArtist, count: myData['artists'].length) : Container(),
                    myData['artists'].isNotEmpty ? followContentsData(type: EndDrawerTicketContentType.artist) : Container(),
                    myData['artists'].isNotEmpty ? emptySpace(height: 20.0) : Container(),
                    SizedBox(height: 36.0 + 4.0 + 14.0.sp + 16.0.w),
                  ],
                ),
                // 배너
                Positioned(
                  bottom: 0.0,
                  child: bannerWidget(),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  // 프로필 위젯
  Widget profileDataWidget() {
    return Column(
      children: [
        // 프로필 이미지 영역
        Container(
          width: 64.0.w,
          height: 64.0.w,
          margin: const EdgeInsets.only(bottom: 4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32.0.r),
            image: myData['image'] == null
              ? const DecorationImage(
                  image: AssetImage('assets/img/profile_default.png'),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                )
              : DecorationImage(
                  image: NetworkImage(myData['image']),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
          ),
        ),
        // 닉네임 영역
        CustomTextBuilder(
          text: '${myData['nick']}',
          fontColor: ColorConfig().dark(),
          fontSize: 16.0.sp,
          fontWeight: FontWeight.w800,
        ),
        // 팔로워, 팔로잉 영역
        Container(
          margin: const EdgeInsets.only(top: 22.0, bottom: 20.0),
          child: Row(
            children: [
              // 팔로워 영역
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, 'followList', arguments: {
                      'click': 'follower',
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomTextBuilder(
                        text: TextConstant.follower,
                        fontColor: ColorConfig().primary(),
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 4.0),
                        child: CustomTextBuilder(
                          text: '${SetIntl().numberFormat(myData['follower_count'])}',
                          fontColor: ColorConfig().dark(),
                          fontSize: 14.0.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              // 팔로잉 영역
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, 'followList', arguments: {
                      'click': 'following',
                    });
                  },
                  child: Row(
                    children: [
                      CustomTextBuilder(
                        text: TextConstant.following,
                        fontColor: ColorConfig().primary(),
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 4.0),
                        child: CustomTextBuilder(
                          text: '${SetIntl().numberFormat(myData['following_count'])}',
                          fontColor: ColorConfig().dark(),
                          fontSize: 14.0.sp,
                          fontWeight: FontWeight.w700,
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
  }

  // ig-public머니, 포인트 위젯
  Widget ig-publicMoneyAndPointWidget() {
    return Container(
      color: ColorConfig().primaryLight3(),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          // ig-public머니 영역
          Expanded(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 4.0),
                  child: CustomTextBuilder(
                    text: TextConstant.ig-publicMoney,
                    fontColor: ColorConfig().gray5(),
                    fontSize: 12.0.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                      text: '${SetIntl().numberFormat(myData['money'])}',
                      fontColor: ColorConfig.wonIconColor,
                      fontSize: 16.0.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ig-public포인트 영역
          // Expanded(
          //   child: Column(
          //     children: [
          //       Container(
          //         margin: const EdgeInsets.only(bottom: 4.0),
          //         child: CustomTextBuilder(
          //           text: TextConstant.ig-publicPoint,
          //           fontColor: ColorConfig().gray5(),
          //           fontSize: 12.0.sp,
          //           fontWeight: FontWeight.w700,
          //         ),
          //       ),
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           Container(
          //             margin: const EdgeInsets.only(right: 4.0),
          //             child: SVGStringBuilder(
          //               image: 'assets/icon/money_point.svg',
          //               width: 16.0.w,
          //               height: 16.0.w,
          //             ),
          //           ),
          //           CustomTextBuilder(
          //             text: '${SetIntl().numberFormat(myData['point'])}',
          //             fontColor: ColorConfig.pointIconColor,
          //             fontSize: 16.0.sp,
          //             fontWeight: FontWeight.w800,
          //           ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  // 알림, 예매내역, 글쓰기 위젯
  Widget utilizationWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 16.0),
      child: Row(
        children: [
          // 알림함 영역
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, 'notificationList');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 14.0),
                      child: SVGBuilder(
                        image: 'assets/icon/notification-on-disabled-bg.svg',
                        width: 24.0.w,
                        height: 24.0.w,
                        color: ColorConfig().dark(),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 4.0),
                          child: CustomTextBuilder(
                            text: TextConstant.notificationList,
                            fontColor: ColorConfig().gray5(),
                            fontSize: 14.0.sp,
                            fontWeight: FontWeight.w700,
                            height: null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 예매내역 영역
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, 'ticketHistory', arguments: {
                  "tabIndex": 0,
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 14.0),
                      child: SVGBuilder(
                        image: 'assets/icon/ticket-fill.svg',
                        width: 24.0.w,
                        height: 24.0.w,
                        color: ColorConfig().dark(),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 4.0),
                      child: CustomTextBuilder(
                        text: TextConstant.ticketHistory,
                        fontColor: ColorConfig().gray5(),
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w700,
                        height: null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 글쓰기 영역
          Expanded(
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, 'communityWrite', arguments: {
                  'edit_data': null
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 14.0),
                      child: SVGBuilder(
                        image: 'assets/icon/edit.svg',
                        width: 24.0.w,
                        height: 24.0.w,
                        color: ColorConfig().dark(),
                      ),
                    ),
                    CustomTextBuilder(
                      text: TextConstant.writing,
                      fontColor: ColorConfig().gray5(),
                      fontSize: 14.0.sp,
                      fontWeight: FontWeight.w700,
                      height: null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 콘텐츠 타이틀 위젯
  Widget followContentsTitle({required String title, required int count}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      margin: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          CustomTextBuilder(
            text: title,
            fontColor: const Color(0xFF121016),
            fontSize: 16.0.sp,
            fontWeight: FontWeight.w800,
            height: null,
          ),
          const SizedBox(width: 4.0),
          CustomTextBuilder(
            text: count.toString(),
            fontColor: ColorConfig().primaryLight(),
            fontSize: 16.0.sp,
            fontWeight: FontWeight.w800,
            height: null,
          ),
          // SVGBuilder(
          //   image: 'assets/icon/arrow_right_light.svg',
          //   width: 12.0.w,
          //   height: 16.0.w,
          //   color: ColorConfig().primaryLight(),
          // ),
        ],
      ),
    );
  }

  // 팔로우 콘텐츠 위젯
  Widget followContentsData({required EndDrawerTicketContentType type}) {
    if (type == EndDrawerTicketContentType.artist) {
      return myData['artists'].isNotEmpty ? Container(
        height: 102.0.w,
        constraints: BoxConstraints(
          minHeight: 102.0.w,
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: myData['artists'].length,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.pushNamed(context, 'artistCommunity', arguments: {
                  'artist_index': myData['artists'][index]['artist_index'],
                });
              },
              child: Container(
                margin: EdgeInsets.only(right: index != 5 ? 16.0 : 0.0),
                child: Column(
                  children: [
                    Container(
                      width: 72.0.w,
                      height: 72.0.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(36.0.r),
                        image: myData['artists'][index]['image'] == null
                          ? const DecorationImage(
                              image: AssetImage('assets/img/profile_default.png'),
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            )
                          : DecorationImage(
                              image: NetworkImage(myData['artists'][index]['image']),
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10.0, bottom: 4.0),
                      child: CustomTextBuilder(
                        text: '${myData['artists'][index]['name']}',
                        fontColor: ColorConfig().gray5(),
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
      ) : Container();
    }

    return myData['shows'].isNotEmpty ? Container(
      height: 114.0.w,
      constraints: const BoxConstraints(
        minHeight: 114.0,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: myData['shows'].length,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.pushNamed(context, 'showCommunity', arguments: {
                'show_index': myData['shows'][index]['show_index'],
              });
            },
            child: Container(
              width: 80.0.w,
              height: 114.0.w,
              margin: EdgeInsets.only(right: index != myData['shows'].length - 1 ? 8.0 : 0.0),
              decoration: BoxDecoration(
                color: myData['shows'][index]['image'] == null ? ColorConfig().gray2() : null,
                borderRadius: BorderRadius.circular(4.0.r),
                image: myData['shows'][index]['image'] != null
                  ? DecorationImage(
                      image: NetworkImage(myData['shows'][index]['image']),
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    )
                  : null,
              ),
              child: myData['shows'][index]['image'] == null ? Center(
                child: SVGBuilder(
                  image: 'assets/icon/album.svg',
                  width: 22.0.w,
                  height: 22.0.w,
                  color: ColorConfig().white(),
                ),
              ) : Container(),
            ),
          );
        },
      ),
    ) : Container();
  }

  // 공백 위젟
  Widget emptySpace({double? width, double? height}) {
    return SizedBox(
      width: width,
      height: height,
    );
  }

  // 배너 위젯
  Widget bannerWidget() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
      color: ColorConfig().gray5(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 4.0),
            child: CustomTextBuilder(
              text: '더 많은 정보가 궁금하다면?',
              fontColor: ColorConfig().white(),
              fontSize: 14.0.sp,
              fontWeight: FontWeight.w800,
              height: null,
            ),
          ),
          Row(
            children: [
              CustomTextBuilder(
                text: '커뮤니티 바로가기 ',
                fontColor: ColorConfig().borderGray2(),
                fontSize: 12.0.sp,
                fontWeight: FontWeight.w400,
                height: null,
              ),
              SVGBuilder(
                image: 'assets/icon/arrow_right_light.svg',
                width: 16.0.w,
                height: 16.0.w,
                color: ColorConfig().borderGray2(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}