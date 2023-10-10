import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/api/community/artist_community.dart';
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

class ArtistCommunityScreen extends StatefulWidget {
  const ArtistCommunityScreen({super.key});

  @override
  State<ArtistCommunityScreen> createState() => _ArtistCommunityScreenState();
}

class _ArtistCommunityScreenState extends State<ArtistCommunityScreen> with TickerProviderStateMixin {
  late ScrollController customScrollViewController;
  late Animation<double> animatedAction;
  late AnimationController animatedController;

  int currentTabIndex = 0;
  int artistIndex = 0;

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

  Map<String, dynamic> artistCummunityData = {};

  @override
  void initState() {
    super.initState();

    customScrollViewController = ScrollController();

    animatedController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    animatedAction = Tween<double>(begin: 1.0, end: 0.75).animate(animatedController);

    Future.delayed(Duration.zero, () {
      if (RouteGetArguments().getArgs(context)['artist_index'] != null) {
        setState(() {
          artistIndex = RouteGetArguments().getArgs(context)['artist_index'];
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
    animatedController.dispose();
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
    ArtistCommunityAPI().artistCommunity(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), artistIndex: artistIndex).then((value) {
      if (value.result['status'] == 1) {
        setState(() {
          artistCummunityData = value.result['data'];
          snsLinks[0]['link'] = value.result['data']['youtube'];
          snsLinks[1]['link'] = value.result['data']['facebook'];
          snsLinks[2]['link'] = value.result['data']['twitter'];
          snsLinks[3]['link'] = value.result['data']['instagram'];
        });
      }
    });
    MainCommunityListAPI().communityList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), type: 1, artistIndex: artistIndex).then((value) {
      if (value.result['status'] == 1) {
        setState(() {
          postList = value.result['data'];
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
      body: artistCummunityData.isNotEmpty ? SafeArea(
        child: CustomScrollView(
          controller: customScrollViewController,
          physics: const ClampingScrollPhysics(),
          slivers: [
            // sliver appbar
            SliverAppBar(
              toolbarHeight: const ig-publicAppBar().preferredSize.height,
              expandedHeight: const ig-publicAppBar().preferredSize.height + 58.0 + 96.0.w + 16.0.sp,
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
                                text: '${artistCummunityData['name']} 커뮤니티',
                                fontColor: ColorConfig().dark(),
                                fontSize: 16.0.sp,
                                fontWeight: FontWeight.w900,
                              ),
                              InkWell(
                                onTap: () async {
                                  if (artistCummunityData['is_follow'] == false) {
                                    FollowAddOrCancel().followApply(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), kind: 'f', type: 3, index: artistIndex).then((value) {
                                      if (value.result['status'] == 1) {
                                        setState(() {
                                          artistCummunityData['is_follow'] = true;
                                        });
                                      }
                                    });
                                  } else {
                                    FollowAddOrCancel().followApply(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), kind: 'u', type: 3, index: artistIndex).then((value) {
                                      if (value.result['status'] == 1) {
                                        setState(() {
                                          artistCummunityData['is_follow'] = false;
                                        });
                                      }
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                  decoration: BoxDecoration(
                                    color: artistCummunityData['is_follow'] == false ? ColorConfig().primary() : ColorConfig().primaryLight(),
                                    borderRadius: BorderRadius.circular(4.0.r),
                                  ),
                                  child: Center(
                                    child: CustomTextBuilder(
                                      text: artistCummunityData['is_follow'] == false ? TextConstant.follow : TextConstant.following,
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
                                  text: '${SetIntl().numberFormat(artistCummunityData['follow_count'])}',
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
                          //         text: '11위',
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
                    // 출연한 공연 타이틀 영역
                    artistCummunityData['shows'].isNotEmpty ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Row(
                        children: [
                          CustomTextBuilder(
                            text: TextConstant.performanceShow,
                            fontColor: ColorConfig().dark(),
                            fontSize: 16.0.sp,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 4.0),
                            child: CustomTextBuilder(
                              text: '${SetIntl().numberFormat(artistCummunityData['shows'].length)}',
                              fontColor: ColorConfig().primary(),
                              fontSize: 16.0.sp,
                              fontWeight: FontWeight.w800,
                              height: 1.0,
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
                    ) : Container(),
                    // 출연한 공연 리스트 영역
                    artistCummunityData['shows'].isNotEmpty ? SizedBox(
                      height: 172.0.w,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        itemCount: artistCummunityData['shows'].length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 120.0.w,
                            height: 170.0.w,
                            margin: index != artistCummunityData['shows'].length - 1 ? const EdgeInsets.only(right: 8.0) : null,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4.0.r),
                            ),
                          );
                        },
                      ),
                    ) : Container(),
                    artistCummunityData['shows'].isNotEmpty ? const SizedBox(height: 32.0) : Container(),
                    // 관련 영상 타이틀 영역
                    artistCummunityData['videos'].isNotEmpty ? InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RelativeVideoScreen(videos: artistCummunityData['videos'])));
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
                    artistCummunityData['videos'].isNotEmpty ? Container(
                      height: 90.0.w + 8.0 + ((13.0.sp * 1.2) * 2),
                      margin: const EdgeInsets.only(top: 4.0),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        itemCount: artistCummunityData['videos'].length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              UrlLauncherBuilder().launchURL(artistCummunityData['videos'][index]['url']);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 160.0.w,
                                  height: 90.0.w,
                                  margin: index != artistCummunityData['videos'].length - 1 ? const EdgeInsets.only(right: 8.0) : null,
                                  decoration: BoxDecoration(
                                    color: artistCummunityData['videos'][index]['thumbnail'] == null ? ColorConfig().gray2() : null,
                                    borderRadius: BorderRadius.circular(4.0.r),
                                    image: artistCummunityData['videos'][index]['thumbnail'] != null ? DecorationImage(
                                      image: NetworkImage(artistCummunityData['videos'][index]['thumbnail']),
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.high,
                                    ) : null,
                                  ),
                                  child: artistCummunityData['videos'][index]['thumbnail'] == null ? Center(
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
                                    text: '${artistCummunityData['videos'][index]['title']}',
                                    fontColor: ColorConfig().dark(),
                                    fontSize: 12.0.sp,
                                    fontWeight: FontWeight.w700,
                                    height: 1.2,
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
                    Container(
                      height: 32.0,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1.0,
                            color: ColorConfig().gray1(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
            // 피드 영역
            SliverList(
              delegate: SliverChildListDelegate([
                // CommunitySortingLayerWidget().sorting(context),
                Container(
                  color: ColorConfig().gray1(),
                  child: MainCommunityWidgetBuilder().feedList(context, data: postList, type: 'A', typeIndex: artistIndex),
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
            '${artistCummunityData['name']} 커뮤니티',
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
                    color: artistCummunityData['image'] == null ? ColorConfig().gray2() : null,
                    image: artistCummunityData['image'] != null ? DecorationImage(
                      image: NetworkImage(artistCummunityData['image']),
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
                  // 아티스트 커뮤니티 정보 영역
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.fromLTRB(20.0, 18.0, 20.0, 40.0),
                    margin: EdgeInsets.only(top: const ig-publicAppBar().preferredSize.height),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 아티스트 이미지 영역
                        Container(
                          width: 96.0.w,
                          height: 96.0.w,
                          margin: const EdgeInsets.only(right: 16.0),
                          decoration: BoxDecoration(
                            color: artistCummunityData['image'] == null ? ColorConfig().gray2() : null,
                            borderRadius: BorderRadius.circular(48.0.r),
                            image: artistCummunityData['image'] != null
                              ? DecorationImage(
                                  image: NetworkImage(artistCummunityData['image']),
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
                        Expanded(
                          child: SizedBox(
                            height: 96.0.w,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 아티스트 커뮤니티 제목 영역
                                Container(
                                  margin: const EdgeInsets.only(left: 4.0),
                                  child: CustomTextBuilder(
                                    text: '${artistCummunityData['name']}',
                                    fontColor: ColorConfig().white(),
                                    fontSize: 16.0.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                // 아티스트 소개 영역
                                artistCummunityData['description'] != null ? Container(
                                  margin: const EdgeInsets.only(left: 4.0, top: 4.0),
                                  child: CustomTextBuilder(
                                    text: '${artistCummunityData['description']}',
                                    fontColor: ColorConfig().white(),
                                    fontSize: 14.0.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ) : Container(),
                                // sns 버튼 영역
                                Container(
                                  margin: const EdgeInsets.only(left: 4.0, top: 10.0, bottom: 12.0),
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
                                // // tag label 영역
                                // Wrap(
                                //   children: List.generate(5, (index) {
                                //     return IntrinsicWidth(
                                //       child: Container(
                                //         margin: const EdgeInsets.only(left: 4.0, top: 4.0),
                                //         padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                                //         decoration: BoxDecoration(
                                //           color: ColorConfig().tagLabelBackground(),
                                //           borderRadius: BorderRadius.circular(1.0.r),
                                //         ),
                                //         child: Center(
                                //           child: CustomTextBuilder(
                                //             text: '쪼고미도',
                                //             fontColor: ColorConfig().white(),
                                //             fontSize: 12.0.sp,
                                //             fontWeight: FontWeight.w700,
                                //           ),
                                //         ),
                                //       ),
                                //     );
                                //   }),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ],
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