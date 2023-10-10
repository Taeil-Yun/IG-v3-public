import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/api/community/community_post_detail.dart';
import 'package:ig-public_v3/api/community/delete_post.dart';
import 'package:ig-public_v3/api/community/report_community.dart';
import 'package:ig-public_v3/api/community/report_reply.dart';
import 'package:ig-public_v3/api/follow/follow_add_cancel.dart';
import 'package:ig-public_v3/api/like/add_like.dart';
import 'package:ig-public_v3/api/like/cancel_like.dart';
import 'package:ig-public_v3/api/main/main_myprofile.dart';
import 'package:ig-public_v3/api/profile/add_scrap.dart';
import 'package:ig-public_v3/api/reply/patch_reply.dart';
import 'package:ig-public_v3/api/reply/reply_add_like.dart';
import 'package:ig-public_v3/api/reply/reply_cancel_like.dart';
import 'package:ig-public_v3/api/reply/reply_delete.dart';
import 'package:ig-public_v3/api/reply/reply_list.dart';
import 'package:ig-public_v3/api/reply/write_reply.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/date_calculator/date_calculator.dart';
import 'package:ig-public_v3/component/popup/popup.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/costant/exception_data.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/src/route_argument.dart';
import 'package:ig-public_v3/util/set_intl.dart';
import 'package:ig-public_v3/util/share.dart';
import 'package:ig-public_v3/util/toast.dart';
import 'package:ig-public_v3/view/main/profile_main.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';
import 'package:intl/intl.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late TextEditingController replyTextController;
  late TextEditingController reportTextController;
  late FocusNode replyFocusNode;
  late FocusNode reportFocusNode;
  // margin: replyFocusNode.hasFocus ? EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom) : null,

  Timer? _debounce;

  int dotsIndex = 0;
  int communityIndex = 0;
  int editReplyIndex = -1;

  bool onEdit = false;
  bool sstatus = false;
  bool replyRegistStatus = false;

  List replyList = [];
  List<bool> reportChecked = [false, false, false, false, false];
  List<String> reportTexts = ['영리목적/홍보성', '음란성/선정성', '욕설/인신공격', '도배', '기타'];

  Map<String, dynamic> detailData = {};
  Map<String, dynamic> myProfileData = {};

  @override
  void initState() {
    super.initState();

    replyTextController = TextEditingController()
      ..addListener(() {
        setState(() {});
      });
    reportTextController = TextEditingController()
      ..addListener(() {
        setState(() {});
      });

    replyFocusNode = FocusNode();
    reportFocusNode = FocusNode();

    Future.delayed(Duration.zero, () {
      if (RouteGetArguments().getArgs(context)['community_index'] != null) {
        setState(() {
          communityIndex =
              RouteGetArguments().getArgs(context)['community_index'];
        });
      }
    }).then((_) {
      initializeAPI();
    });
  }

  @override
  void dispose() {
    super.dispose();

    replyTextController.dispose();
    reportTextController.dispose();
    replyFocusNode.dispose();
    reportFocusNode.dispose();
  }

  Future<void> initializeAPI() async {
    CommunityPostDetailAPI()
        .postDetail(
            accessToken:
                await SecureStorageConfig().storage.read(key: 'access_token'),
            communityIndex: communityIndex)
        .then((value) {
      setState(() {
        detailData = value.result['data'];

        if (detailData['images'] != null) {
          detailData['images'].remove(imageException);
        }
      });
    });
    ReplyListAPI()
        .replyList(
            accessToken:
                await SecureStorageConfig().storage.read(key: 'access_token'),
            communityIndex: communityIndex)
        .then((value) {
      setState(() {
        replyList = value.result['data'];
      });
    });
    MainMyProfileAPI()
        .myProfile(
            accessToken:
                await SecureStorageConfig().storage.read(key: 'access_token'))
        .then((value) async {
      setState(() {
        myProfileData = value.result['data'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (replyFocusNode.hasFocus) {
          replyFocusNode.unfocus();

          if (onEdit == true) {
            setState(() {
              onEdit = false;
              replyTextController.clear();
              editReplyIndex = -1;
            });
          }
        }
      },
      child: Scaffold(
        appBar: onEdit == false
            ? ig -
                publicAppBar(
                  leading: ig -
                      publicAppBarLeading(
                        press: () => Navigator.pop(context),
                      ),
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
                          builder: (context) {
                            return SafeArea(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 상단 영역
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomTextBuilder(
                                          text: detailData['is_mine'] == true
                                              ? '내 게시글'
                                              : '상대 게시글',
                                          fontColor: ColorConfig().dark(),
                                          fontSize: 16.0.sp,
                                          fontWeight: FontWeight.w800,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: SVGBuilder(
                                            image:
                                                'assets/icon/close_normal.svg',
                                            width: 24.0.w,
                                            height: 24.0.w,
                                            color: ColorConfig().gray3(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // 삭제하기 영역
                                  detailData['is_mine'] == true
                                      ? InkWell(
                                          onTap: () {
                                            PopupBuilder(
                                                  title: TextConstant
                                                      .deletePostTitle,
                                                  content: TextConstant
                                                      .deletePostContent,
                                                  actions: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          splashColor:
                                                              ColorConfig
                                                                  .transparent,
                                                          child: Container(
                                                            width: (MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width -
                                                                    120.0.w) /
                                                                2,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        16.5),
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 8.0),
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  ColorConfig()
                                                                      .gray3(),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4.0.r),
                                                            ),
                                                            child: Center(
                                                              child:
                                                                  CustomTextBuilder(
                                                                text:
                                                                    TextConstant
                                                                        .close,
                                                                fontColor:
                                                                    ColorConfig()
                                                                        .white(),
                                                                fontSize:
                                                                    14.0.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        InkWell(
                                                          onTap: () async {
                                                            PostDeleteAPI()
                                                                .postDelete(
                                                                    accessToken: await SecureStorageConfig()
                                                                        .storage
                                                                        .read(
                                                                            key:
                                                                                'access_token'),
                                                                    communityIndex:
                                                                        communityIndex)
                                                                .then((value) {
                                                              if (value.result[
                                                                      'status'] ==
                                                                  1) {
                                                                Navigator.pop(
                                                                    context);
                                                                Navigator.pop(
                                                                    context);
                                                                Navigator.pop(
                                                                    context);
                                                                ToastModel().iconToast(
                                                                    value.result[
                                                                        'message']);
                                                              } else {
                                                                Navigator.pop(
                                                                    context);
                                                                Navigator.pop(
                                                                    context);
                                                                ToastModel().iconToast(
                                                                    value.result[
                                                                        'message'],
                                                                    iconType:
                                                                        2);
                                                              }
                                                            });
                                                          },
                                                          splashColor:
                                                              ColorConfig
                                                                  .transparent,
                                                          child: Container(
                                                            width: (MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width -
                                                                    120.0.w) /
                                                                2,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        16.5),
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  ColorConfig()
                                                                      .dark(),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4.0.r),
                                                            ),
                                                            child: Center(
                                                              child:
                                                                  CustomTextBuilder(
                                                                text: TextConstant
                                                                    .doDelete,
                                                                fontColor:
                                                                    ColorConfig()
                                                                        .white(),
                                                                fontSize:
                                                                    14.0.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ).ig -
                                                publicDialog(context);
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
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
                                              text: TextConstant.doDelete,
                                              fontColor: ColorConfig().dark(),
                                              fontSize: 14.0.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  // 수정하기 영역
                                  detailData['is_mine'] == true
                                      ? InkWell(
                                          onTap: () {
                                            Navigator.pop(context);

                                            detailData['community_index'] =
                                                communityIndex;

                                            if (detailData['type'] == 'S' ||
                                                detailData['type'] == 'A') {
                                              Navigator.pushNamed(
                                                  context, 'communityWrite',
                                                  arguments: {
                                                    'edit_data': detailData,
                                                  }).then((value) {
                                                if (value != null) {
                                                  initializeAPI();
                                                }
                                              });
                                            } else {
                                              Navigator.pushNamed(
                                                  context, 'reviewWrite',
                                                  arguments: {
                                                    'edit_data': detailData,
                                                  }).then((value) {
                                                if (value != null) {
                                                  initializeAPI();
                                                }
                                              });
                                            }
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
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
                                              text: TextConstant.doEdit,
                                              fontColor: ColorConfig().dark(),
                                              fontSize: 14.0.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  // 신고하기 영역
                                  detailData['is_mine'] == false
                                      ? InkWell(
                                          onTap: () {
                                            Navigator.pop(context);

                                            reportTextController.clear();
                                            setState(() {
                                              reportChecked = [
                                                false,
                                                false,
                                                false,
                                                false,
                                                false
                                              ];
                                            });

                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        4.0.r),
                                              ),
                                              builder: (context) {
                                                return GestureDetector(
                                                  onTap: () {
                                                    if (reportFocusNode
                                                        .hasFocus) {
                                                      reportFocusNode.unfocus();
                                                    }
                                                  },
                                                  child: StatefulBuilder(
                                                      builder:
                                                          (context, state) {
                                                    return Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      margin: EdgeInsets.only(
                                                          bottom: reportFocusNode
                                                                  .hasFocus
                                                              ? MediaQuery.of(
                                                                      context)
                                                                  .viewInsets
                                                                  .bottom
                                                              : 0.0),
                                                      child: SafeArea(
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              // 상단 영역
                                                              Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        20.0,
                                                                    vertical:
                                                                        16.0),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    CustomTextBuilder(
                                                                      text: TextConstant
                                                                          .reportReason,
                                                                      fontColor:
                                                                          ColorConfig()
                                                                              .dark(),
                                                                      fontSize:
                                                                          16.0.sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800,
                                                                    ),
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child:
                                                                          SVGBuilder(
                                                                        image:
                                                                            'assets/icon/close_normal.svg',
                                                                        width:
                                                                            24.0.w,
                                                                        height:
                                                                            24.0.w,
                                                                        color: ColorConfig()
                                                                            .gray3(),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: List.generate(
                                                                    reportChecked
                                                                        .length,
                                                                    (reportIndex) {
                                                                  return InkWell(
                                                                    onTap: () {
                                                                      if (!reportChecked
                                                                          .contains(
                                                                              true)) {
                                                                        state(
                                                                            () {
                                                                          reportChecked[reportIndex] =
                                                                              !reportChecked[reportIndex];
                                                                        });
                                                                      } else {
                                                                        state(
                                                                            () {
                                                                          reportChecked =
                                                                              [
                                                                            false,
                                                                            false,
                                                                            false,
                                                                            false,
                                                                            false
                                                                          ];
                                                                          reportChecked[reportIndex] =
                                                                              !reportChecked[reportIndex];
                                                                        });
                                                                      }
                                                                    },
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .fromLTRB(
                                                                          20.0,
                                                                          20.0,
                                                                          20.0,
                                                                          12.0),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Container(
                                                                            width:
                                                                                24.0.w,
                                                                            height:
                                                                                24.0.w,
                                                                            margin:
                                                                                const EdgeInsets.only(right: 8.0),
                                                                            child:
                                                                                Checkbox(
                                                                              activeColor: ColorConfig().primary(),
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(100.0.r),
                                                                              ),
                                                                              value: reportChecked[reportIndex],
                                                                              onChanged: (ck) {
                                                                                if (!reportChecked.contains(true)) {
                                                                                  state(() {
                                                                                    reportChecked[reportIndex] = ck!;
                                                                                  });
                                                                                } else {
                                                                                  state(() {
                                                                                    reportChecked = [
                                                                                      false,
                                                                                      false,
                                                                                      false,
                                                                                      false,
                                                                                      false
                                                                                    ];
                                                                                    reportChecked[reportIndex] = ck!;
                                                                                  });
                                                                                }
                                                                              },
                                                                            ),
                                                                          ),
                                                                          CustomTextBuilder(
                                                                            text:
                                                                                reportTexts[reportIndex],
                                                                            fontColor:
                                                                                ColorConfig().gray5(),
                                                                            fontSize:
                                                                                14.0.sp,
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                }),
                                                              ),
                                                              Container(
                                                                height: 130.0,
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        20.0),
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            12.0),
                                                                child:
                                                                    TextFormField(
                                                                  controller:
                                                                      reportTextController,
                                                                  focusNode:
                                                                      reportFocusNode,
                                                                  maxLines:
                                                                      null,
                                                                  keyboardType:
                                                                      TextInputType
                                                                          .multiline,
                                                                  expands: true,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    contentPadding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    isDense:
                                                                        true,
                                                                    isCollapsed:
                                                                        true,
                                                                    constraints:
                                                                        const BoxConstraints(
                                                                      maxHeight:
                                                                          130.0,
                                                                      minHeight:
                                                                          130.0,
                                                                    ),
                                                                    enabledBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        width:
                                                                            1.0,
                                                                        color: ColorConfig()
                                                                            .gray2(),
                                                                      ),
                                                                    ),
                                                                    focusedBorder:
                                                                        OutlineInputBorder(
                                                                      borderSide:
                                                                          BorderSide(
                                                                        width:
                                                                            1.0,
                                                                        color: ColorConfig()
                                                                            .gray2(),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  style:
                                                                      TextStyle(
                                                                    color: ColorConfig()
                                                                        .dark(),
                                                                    fontSize:
                                                                        12.0.sp,
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        20.0),
                                                                child: Row(
                                                                  children: [
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            (MediaQuery.of(context).size.width - (40.0 + 8.0)) /
                                                                                2,
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                20.0),
                                                                        margin: const EdgeInsets
                                                                            .only(
                                                                            right:
                                                                                8.0),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              ColorConfig().gray3(),
                                                                          borderRadius:
                                                                              BorderRadius.circular(4.0.r),
                                                                        ),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              CustomTextBuilder(
                                                                            text:
                                                                                TextConstant.cancel,
                                                                            fontColor:
                                                                                ColorConfig().white(),
                                                                            fontSize:
                                                                                14.0.sp,
                                                                            fontWeight:
                                                                                FontWeight.w800,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    InkWell(
                                                                      onTap:
                                                                          () {
                                                                        if (reportChecked.contains(true) ==
                                                                            false) {
                                                                          ToastModel()
                                                                              .toast('신고항목을 선택해주세요');
                                                                        } else if (reportTextController
                                                                            .text
                                                                            .trim()
                                                                            .isEmpty) {
                                                                          ToastModel()
                                                                              .toast('신고사유를 입력해주세요');
                                                                        } else {
                                                                          PopupBuilder(
                                                                                title: TextConstant.reportTitle,
                                                                                content: TextConstant.reportDescription,
                                                                                actions: [
                                                                                  Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      InkWell(
                                                                                        onTap: () {
                                                                                          Navigator.pop(context);
                                                                                        },
                                                                                        splashColor: ColorConfig.transparent,
                                                                                        child: Container(
                                                                                          width: (MediaQuery.of(context).size.width - 120.0.w) / 2,
                                                                                          padding: const EdgeInsets.symmetric(vertical: 16.5),
                                                                                          margin: const EdgeInsets.only(right: 8.0),
                                                                                          decoration: BoxDecoration(
                                                                                            color: ColorConfig().gray3(),
                                                                                            borderRadius: BorderRadius.circular(4.0.r),
                                                                                          ),
                                                                                          child: Center(
                                                                                            child: CustomTextBuilder(
                                                                                              text: TextConstant.close,
                                                                                              fontColor: ColorConfig().white(),
                                                                                              fontSize: 14.0.sp,
                                                                                              fontWeight: FontWeight.w800,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      InkWell(
                                                                                        onTap: () async {
                                                                                          Navigator.pop(context);

                                                                                          ReportCommunity().reportCommunity(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), communityIndex: communityIndex, type: reportChecked.indexOf(true), description: reportTextController.text).then((value) {
                                                                                            if (value.result['status'] == 1) {
                                                                                              Navigator.pop(context);
                                                                                              ToastModel().iconToast(value.result['message']);
                                                                                            } else {
                                                                                              ToastModel().iconToast(value.result['message'], iconType: 2);
                                                                                            }
                                                                                          });
                                                                                        },
                                                                                        splashColor: ColorConfig.transparent,
                                                                                        child: Container(
                                                                                          width: (MediaQuery.of(context).size.width - 120.0.w) / 2,
                                                                                          padding: const EdgeInsets.symmetric(vertical: 16.5),
                                                                                          decoration: BoxDecoration(
                                                                                            color: ColorConfig().dark(),
                                                                                            borderRadius: BorderRadius.circular(4.0.r),
                                                                                          ),
                                                                                          child: Center(
                                                                                            child: CustomTextBuilder(
                                                                                              text: TextConstant.doReport,
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
                                                                              ).ig -
                                                                              publicDialog(context);
                                                                        }
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        width:
                                                                            (MediaQuery.of(context).size.width - (40.0 + 8.0)) /
                                                                                2,
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            vertical:
                                                                                20.0),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              ColorConfig().dark(),
                                                                          borderRadius:
                                                                              BorderRadius.circular(4.0.r),
                                                                        ),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              CustomTextBuilder(
                                                                            text:
                                                                                TextConstant.doReport,
                                                                            fontColor:
                                                                                ColorConfig().white(),
                                                                            fontSize:
                                                                                14.0.sp,
                                                                            fontWeight:
                                                                                FontWeight.w800,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
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
                                              text: TextConstant.doReport,
                                              fontColor: ColorConfig().dark(),
                                              fontSize: 14.0.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  // 저장하기 영역
                                  InkWell(
                                    onTap: () async {
                                      Navigator.pop(context);

                                      AddScrapAPI()
                                          .addScrap(
                                              accessToken:
                                                  await SecureStorageConfig()
                                                      .storage
                                                      .read(
                                                          key: 'access_token'),
                                              communityIndex: communityIndex)
                                          .then((value) {
                                        if (value.result['status'] == 1) {
                                          ToastModel().iconToast(
                                              value.result['message']);
                                        }
                                      });
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
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
                                        text: TextConstant.doSave,
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
                        color: ColorConfig().dark(),
                      ),
                    ),
                  ],
                )
            : null,
        body: detailData.isNotEmpty
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: ColorConfig().white(),
                child: SafeArea(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            // 공연후기일 때 포스터 영역
                            detailData['type'] == 'T' ||
                                    detailData['type'] == 'R'
                                ? InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, 'showCommunity',
                                          arguments: {
                                            'show_index':
                                                detailData['show_index'],
                                          });
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0, vertical: 16.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // 공연 정보 영역
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // 공연 제목 영역
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      bottom: 4.0),
                                                  child: CustomTextBuilder(
                                                    text:
                                                        '${detailData['item_name']}',
                                                    fontColor:
                                                        ColorConfig().gray5(),
                                                    fontSize: 14.0.sp,
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.2,
                                                  ),
                                                ),
                                                // 별점 영역
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      bottom: 4.0),
                                                  child: RatingBar.builder(
                                                    initialRating:
                                                        detailData['star'] / 10,
                                                    minRating: 1,
                                                    ignoreGestures: true,
                                                    direction: Axis.horizontal,
                                                    allowHalfRating: true,
                                                    itemCount: 5,
                                                    itemSize: 18.0.w,
                                                    unratedColor:
                                                        ColorConfig().gray2(),
                                                    // itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                                    itemBuilder: (context, _) =>
                                                        SVGBuilder(
                                                      image:
                                                          'assets/icon/star.svg',
                                                      width: 18.0.w,
                                                      height: 18.0.w,
                                                      color: ColorConfig()
                                                          .primary(),
                                                    ),
                                                    onRatingUpdate: (rating) {},
                                                  ),
                                                ),
                                                // 출연진 영역
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      bottom: 8.0),
                                                  child: CustomTextBuilder(
                                                    text:
                                                        '${detailData['casting']} 외',
                                                    fontColor:
                                                        ColorConfig().gray4(),
                                                    fontSize: 11.0.sp,
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.2,
                                                  ),
                                                ),
                                                // 관람날짜 영역
                                                Row(
                                                  children: [
                                                    // 찐후기 뱃지 영역
                                                    detailData['type'] == 'T'
                                                        ? Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    right: 4.0),
                                                            child:
                                                                SVGStringBuilder(
                                                              image:
                                                                  'assets/icon/cms_management.svg',
                                                              width: 24.0.w,
                                                              height: 24.0.w,
                                                            ),
                                                          )
                                                        : Container(),
                                                    // 관람날짜 영역
                                                    detailData['watch_date'] !=
                                                            null
                                                        ? Expanded(
                                                            child:
                                                                CustomTextBuilder(
                                                              text: DateFormat(
                                                                      'yyyy. MM. dd. 관람')
                                                                  .format(DateTime
                                                                          .parse(
                                                                              detailData['watch_date'])
                                                                      .toLocal()),
                                                              fontColor:
                                                                  ColorConfig()
                                                                      .gray3(),
                                                              fontSize: 12.0.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                          )
                                                        : Container(),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          // 공연 포스터 영역
                                          Container(
                                            width: 60.0.w,
                                            height: 86.0.w,
                                            margin: const EdgeInsets.only(
                                                left: 16.0),
                                            decoration: BoxDecoration(
                                              color: detailData['item_image'] ==
                                                      null
                                                  ? ColorConfig().gray2()
                                                  : null,
                                              borderRadius:
                                                  BorderRadius.circular(4.0.r),
                                              image: detailData['item_image'] !=
                                                      null
                                                  ? DecorationImage(
                                                      image: NetworkImage(
                                                          detailData[
                                                              'item_image']),
                                                      fit: BoxFit.cover,
                                                      filterQuality:
                                                          FilterQuality.high,
                                                    )
                                                  : null,
                                            ),
                                            child: detailData['item_image'] ==
                                                    null
                                                ? Center(
                                                    child: SVGBuilder(
                                                      image:
                                                          'assets/icon/album.svg',
                                                      width: 24.0.w,
                                                      height: 24.0.w,
                                                      color:
                                                          ColorConfig().white(),
                                                    ),
                                                  )
                                                : Container(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(),
                            // 사용자 정보 영역
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 16.0, 20.0, 8.0),
                              child: Row(
                                children: [
                                  // 프로필 이미지 영역
                                  InkWell(
                                    onTap: () {
                                      if (detailData['is_mine'] == false) {
                                        Navigator.pushNamed(
                                            context, 'otherUserProfile',
                                            arguments: {
                                              'user_index':
                                                  detailData['user_index'],
                                            }).then((rt) async {
                                          CommunityPostDetailAPI()
                                              .postDetail(
                                                  accessToken:
                                                      await SecureStorageConfig()
                                                          .storage
                                                          .read(
                                                              key:
                                                                  'access_token'),
                                                  communityIndex:
                                                      communityIndex)
                                              .then((value) {
                                            setState(() {
                                              detailData = value.result['data'];

                                              if (detailData['images'] !=
                                                  null) {
                                                detailData['images']
                                                    .remove(imageException);
                                              }
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
                                          CommunityPostDetailAPI()
                                              .postDetail(
                                                  accessToken:
                                                      await SecureStorageConfig()
                                                          .storage
                                                          .read(
                                                              key:
                                                                  'access_token'),
                                                  communityIndex:
                                                      communityIndex)
                                              .then((value) {
                                            setState(() {
                                              detailData = value.result['data'];

                                              if (detailData['images'] !=
                                                  null) {
                                                detailData['images']
                                                    .remove(imageException);
                                              }
                                            });
                                          });
                                        });
                                      }
                                    },
                                    child: Container(
                                      width: 36.0.w,
                                      height: 36.0.w,
                                      margin:
                                          const EdgeInsets.only(right: 12.0),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(18.0.r),
                                        image: detailData['image'] != null
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                    detailData['image']),
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
                                              ),
                                      ),
                                    ),
                                  ),
                                  // 사용자 닉네임, 등록날짜, 팔로우 버튼영역
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            if (detailData['is_mine'] ==
                                                false) {
                                              Navigator.pushNamed(
                                                  context, 'otherUserProfile',
                                                  arguments: {
                                                    'user_index': detailData[
                                                        'user_index'],
                                                  }).then((rt) async {
                                                CommunityPostDetailAPI()
                                                    .postDetail(
                                                        accessToken:
                                                            await SecureStorageConfig()
                                                                .storage
                                                                .read(
                                                                    key:
                                                                        'access_token'),
                                                        communityIndex:
                                                            communityIndex)
                                                    .then((value) {
                                                  setState(() {
                                                    detailData =
                                                        value.result['data'];

                                                    if (detailData['images'] !=
                                                        null) {
                                                      detailData['images']
                                                          .remove(
                                                              imageException);
                                                    }
                                                  });
                                                });
                                              });
                                            } else {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MainMyProfileScreen(
                                                              isNavigator:
                                                                  true))).then(
                                                  (rt) async {
                                                CommunityPostDetailAPI()
                                                    .postDetail(
                                                        accessToken:
                                                            await SecureStorageConfig()
                                                                .storage
                                                                .read(
                                                                    key:
                                                                        'access_token'),
                                                        communityIndex:
                                                            communityIndex)
                                                    .then((value) {
                                                  setState(() {
                                                    detailData =
                                                        value.result['data'];

                                                    if (detailData['images'] !=
                                                        null) {
                                                      detailData['images']
                                                          .remove(
                                                              imageException);
                                                    }
                                                  });
                                                });
                                              });
                                            }
                                          },
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // 닉네임 영역
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    bottom: 4.0),
                                                child: CustomTextBuilder(
                                                  text: '${detailData['nick']}',
                                                  fontColor:
                                                      ColorConfig().gray5(),
                                                  fontSize: 12.0.sp,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              // 등록날짜 영역
                                              CustomTextBuilder(
                                                text: detailData['create_dt'] ==
                                                        detailData['modify_dt']
                                                    ? DateFormat(
                                                            'yyyy. MM. dd.')
                                                        .format(DateTime.parse(
                                                                detailData[
                                                                    'create_dt'])
                                                            .toLocal())
                                                    : DateFormat(
                                                            'yyyy. MM. dd. (수정)')
                                                        .format(DateTime.parse(
                                                                detailData[
                                                                    'modify_dt'])
                                                            .toLocal()),
                                                fontColor:
                                                    ColorConfig().gray3(),
                                                fontSize: 12.0.sp,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ],
                                          ),
                                        ),
                                        detailData['is_mine'] == false
                                            ? InkWell(
                                                onTap: () async {
                                                  if (detailData['is_follow'] ==
                                                      false) {
                                                    FollowAddOrCancel()
                                                        .followApply(
                                                            accessToken:
                                                                await SecureStorageConfig()
                                                                    .storage
                                                                    .read(
                                                                        key:
                                                                            'access_token'),
                                                            kind: 'f',
                                                            type: 1,
                                                            index: detailData[
                                                                'user_index'])
                                                        .then((value) {
                                                      if (value.result[
                                                              'status'] ==
                                                          1) {
                                                        setState(() {
                                                          detailData[
                                                                  'is_follow'] =
                                                              true;
                                                        });
                                                      }
                                                    });
                                                  } else {
                                                    FollowAddOrCancel()
                                                        .followApply(
                                                            accessToken:
                                                                await SecureStorageConfig()
                                                                    .storage
                                                                    .read(
                                                                        key:
                                                                            'access_token'),
                                                            kind: 'u',
                                                            type: 1,
                                                            index: detailData[
                                                                'user_index'])
                                                        .then((value) {
                                                      if (value.result[
                                                              'status'] ==
                                                          1) {
                                                        setState(() {
                                                          detailData[
                                                                  'is_follow'] =
                                                              false;
                                                        });
                                                      }
                                                    });
                                                  }
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12.0,
                                                      vertical: 8.0),
                                                  decoration: BoxDecoration(
                                                    color: detailData[
                                                                'is_follow'] ==
                                                            false
                                                        ? ColorConfig()
                                                            .primary()
                                                        : ColorConfig()
                                                            .primaryLight(),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4.0.r),
                                                  ),
                                                  child: CustomTextBuilder(
                                                    text: detailData[
                                                                'is_follow'] ==
                                                            false
                                                        ? TextConstant.follow
                                                        : TextConstant
                                                            .following,
                                                    fontColor:
                                                        ColorConfig().white(),
                                                    fontSize: 12.0.sp,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 이미지 영역
                            detailData['images'].isNotEmpty
                                ? Container(
                                    height: 222.0.w + 32.0 + (6.0.w + 10.0),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: PageView.builder(
                                            controller: PageController(
                                                viewportFraction: 0.9,
                                                keepPage: false),
                                            scrollDirection: Axis.horizontal,
                                            itemCount:
                                                detailData['images'].length,
                                            onPageChanged: (value) {
                                              setState(() {
                                                dotsIndex = value;
                                              });
                                            },
                                            itemBuilder: (context, imageIndex) {
                                              return Container(
                                                margin: EdgeInsets.only(
                                                    left: imageIndex == 0
                                                        ? 0.0
                                                        : 0.0,
                                                    right: imageIndex !=
                                                            detailData['images']
                                                                    .length -
                                                                1
                                                        ? 8.0
                                                        : 0.0),
                                                decoration: BoxDecoration(
                                                  color: detailData['images']
                                                              [imageIndex] ==
                                                          null
                                                      ? ColorConfig().gray2()
                                                      : null,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4.0.r),
                                                  image: detailData['images']
                                                              [imageIndex] !=
                                                          null
                                                      ? DecorationImage(
                                                          image: NetworkImage(
                                                              detailData[
                                                                      'images']
                                                                  [imageIndex]),
                                                          fit: BoxFit.cover,
                                                          filterQuality:
                                                              FilterQuality
                                                                  .high,
                                                        )
                                                      : null,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        // dots paging
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          margin:
                                              const EdgeInsets.only(top: 10.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: List.generate(
                                                detailData['images'].length,
                                                (dots) {
                                              return Container(
                                                width: 6.0.w,
                                                height: 6.0.w,
                                                margin: dots !=
                                                        detailData['images']
                                                                .length -
                                                            1
                                                    ? const EdgeInsets.only(
                                                        right: 4.0)
                                                    : null,
                                                decoration: BoxDecoration(
                                                  color: dots == dotsIndex
                                                      ? ColorConfig().dark()
                                                      : ColorConfig().gray3(),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          3.0.r),
                                                ),
                                              );
                                            }),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                            // 게시물 제목 영역
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 4.0),
                              child: CustomTextBuilder(
                                text: '${detailData['title']}',
                                fontColor: ColorConfig().dark(),
                                fontSize: 18.0.sp,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                            // 게시물 내용, 좋아요/댓글 개수 영역
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.fromLTRB(
                                  20.0, 8.0, 20.0, 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 게시물 내용 영역
                                  detailData['content'] != null
                                      ? Container(
                                          margin: const EdgeInsets.only(
                                              bottom: 16.0),
                                          child: CustomTextBuilder(
                                            text: '${detailData['content']}',
                                            fontColor: ColorConfig().dark(),
                                            fontSize: 14.0.sp,
                                            fontWeight: FontWeight.w400,
                                            height: 1.2,
                                          ),
                                        )
                                      : Container(),
                                  // 좋아요/댓글 개수 영역
                                  Row(
                                    children: [
                                      // 좋아요 개수 영역
                                      Row(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                right: 4.0),
                                            child: SVGBuilder(
                                              image:
                                                  'assets/icon/heart-off-disabled-bg.svg',
                                              width: 16.0.w,
                                              height: 16.0.w,
                                              color: ColorConfig().gray3(),
                                            ),
                                          ),
                                          CustomTextBuilder(
                                            text:
                                                '${SetIntl().numberFormat(detailData['like_count'])}',
                                            fontColor: ColorConfig().gray3(),
                                            fontSize: 12.0.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 16.0),
                                      // 댓글 개수 영역
                                      Row(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                right: 4.0),
                                            child: SVGBuilder(
                                              image: 'assets/icon/chat-off.svg',
                                              width: 16.0.w,
                                              height: 16.0.w,
                                              color: ColorConfig().gray3(),
                                            ),
                                          ),
                                          CustomTextBuilder(
                                            text:
                                                '${SetIntl().numberFormat(detailData['reply_count'])}',
                                            fontColor: ColorConfig().gray3(),
                                            fontSize: 12.0.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // 좋아요, 댓글, 공유하기 버튼 영역
                            Row(
                              children: [
                                // 좋아요 버튼
                                InkWell(
                                  onTap: () async {
                                    if (detailData['is_like'] == false) {
                                      AddLikeAPI()
                                          .addLike(
                                              accessToken:
                                                  await SecureStorageConfig()
                                                      .storage
                                                      .read(
                                                          key: 'access_token'),
                                              communityIndex: communityIndex)
                                          .then((value) {
                                        setState(() {
                                          detailData['is_like'] = true;
                                          detailData['like_count']++;
                                        });
                                      });
                                    } else {
                                      CancelLikeAPI()
                                          .cancelLike(
                                              accessToken:
                                                  await SecureStorageConfig()
                                                      .storage
                                                      .read(
                                                          key: 'access_token'),
                                              communityIndex: communityIndex)
                                          .then((value) {
                                        setState(() {
                                          detailData['is_like'] = false;
                                          detailData['like_count']--;
                                        });
                                      });
                                    }
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          width: 1.0,
                                          color: ColorConfig().gray2(),
                                        ),
                                        bottom: BorderSide(
                                          width: 1.0,
                                          color: ColorConfig().gray2(),
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                right: 4.0),
                                            child: SVGBuilder(
                                              image: detailData['is_like'] ==
                                                      true
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
                                InkWell(
                                  onTap: () {
                                    replyFocusNode.requestFocus();
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0),
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
                                        bottom: BorderSide(
                                          width: 1.0,
                                          color: ColorConfig().gray2(),
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                right: 4.0),
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
                                ),
                                // 공유하기 버튼
                                InkWell(
                                  onTap: () {
                                    if (_debounce?.isActive ?? false)
                                      _debounce!.cancel();

                                    _debounce =
                                        Timer(const Duration(milliseconds: 300),
                                            () async {
                                      shareBuilder(context,
                                          type: 'community',
                                          index: communityIndex);
                                    });
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12.0),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          width: 1.0,
                                          color: ColorConfig().gray2(),
                                        ),
                                        bottom: BorderSide(
                                          width: 1.0,
                                          color: ColorConfig().gray2(),
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                right: 4.0),
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
                            ),
                            // 댓글 타이틀 영역
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 12.0),
                              margin: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                children: [
                                  CustomTextBuilder(
                                    text: TextConstant.reply,
                                    fontColor: ColorConfig().dark(),
                                    fontSize: 16.0.sp,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: CustomTextBuilder(
                                      text:
                                          '${SetIntl().numberFormat(replyList.length)}',
                                      fontColor: ColorConfig().primary(),
                                      fontSize: 16.0.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 댓글 리스트 영역
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: replyList.length,
                              itemBuilder: (context, replyIndex) {
                                return Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0, vertical: 8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // 프로필 이미지 영역
                                          Container(
                                            width: 36.0.w,
                                            height: 36.0.w,
                                            margin: const EdgeInsets.only(
                                                right: 12.0),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(18.0.r),
                                              image: replyList[replyIndex]
                                                          ['image'] !=
                                                      null
                                                  ? DecorationImage(
                                                      image: NetworkImage(
                                                          replyList[replyIndex]
                                                              ['image']),
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
                                                    ),
                                            ),
                                          ),
                                          // 댓글 내용 영역
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // 사용자 아이디, 댓글등록날짜 영역
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 4.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      // 사용자 아이디 영역
                                                      Expanded(
                                                        child:
                                                            CustomTextBuilder(
                                                          text:
                                                              '${replyList[replyIndex]['nick']}',
                                                          fontColor: replyList[
                                                                          replyIndex]
                                                                      [
                                                                      'is_mine'] ==
                                                                  true
                                                              ? ColorConfig()
                                                                  .primary()
                                                              : ColorConfig()
                                                                  .gray5(),
                                                          fontSize: 12.0.sp,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                      // 댓글등록날짜 영역
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .only(left: 12.0),
                                                        child:
                                                            CustomTextBuilder(
                                                          text: replyList[replyIndex]
                                                                      [
                                                                      'create_dt'] ==
                                                                  replyList[
                                                                          replyIndex]
                                                                      [
                                                                      'modify_dt']
                                                              ? DateCalculatorWrapper()
                                                                  .daysCalculator(
                                                                      replyList[
                                                                              replyIndex]
                                                                          [
                                                                          'create_dt'])
                                                              : '${DateCalculatorWrapper().daysCalculator(replyList[replyIndex]['modify_dt'])} (수정됨)',
                                                          fontColor:
                                                              ColorConfig()
                                                                  .gray3(),
                                                          fontSize: 10.0.sp,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // 댓글내용 영역
                                                CustomTextBuilder(
                                                  text:
                                                      '${replyList[replyIndex]['content']}',
                                                  fontColor:
                                                      ColorConfig().gray5(),
                                                  fontSize: 12.0.sp,
                                                  fontWeight: FontWeight.w400,
                                                  height: 1.2,
                                                ),
                                                // 좋아요 수, 답글달기, 신고 영역
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 4.0),
                                                  child: Row(
                                                    children: [
                                                      // 좋아요 수 영역
                                                      InkWell(
                                                        onTap: () async {
                                                          if (replyList[
                                                                      replyIndex]
                                                                  ['is_like'] ==
                                                              false) {
                                                            ReplyAddLikeAPI()
                                                                .replyAddLike(
                                                                    accessToken: await SecureStorageConfig()
                                                                        .storage
                                                                        .read(
                                                                            key:
                                                                                'access_token'),
                                                                    replyIndex:
                                                                        replyList[replyIndex]
                                                                            [
                                                                            'reply_index'])
                                                                .then((value) {
                                                              setState(() {
                                                                replyList[replyIndex]
                                                                        [
                                                                        'is_like'] =
                                                                    true;
                                                                replyList[
                                                                        replyIndex]
                                                                    [
                                                                    'like_count']++;
                                                              });
                                                            });
                                                          } else {
                                                            ReplyCancelLikeAPI()
                                                                .replyCancelLike(
                                                                    accessToken: await SecureStorageConfig()
                                                                        .storage
                                                                        .read(
                                                                            key:
                                                                                'access_token'),
                                                                    replyIndex:
                                                                        replyList[replyIndex]
                                                                            [
                                                                            'reply_index'])
                                                                .then((value) {
                                                              setState(() {
                                                                replyList[replyIndex]
                                                                        [
                                                                        'is_like'] =
                                                                    false;
                                                                replyList[
                                                                        replyIndex]
                                                                    [
                                                                    'like_count']--;
                                                              });
                                                            });
                                                          }
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right:
                                                                          4.0),
                                                              child: SVGBuilder(
                                                                image: replyList[replyIndex]
                                                                            [
                                                                            'is_like'] ==
                                                                        true
                                                                    ? 'assets/icon/heart-on-disabled-bg.svg'
                                                                    : 'assets/icon/heart-off-disabled-bg.svg',
                                                                width: 16.0.w,
                                                                height: 16.0.w,
                                                                color:
                                                                    ColorConfig()
                                                                        .gray3(),
                                                              ),
                                                            ),
                                                            CustomTextBuilder(
                                                              text:
                                                                  '좋아요 ${replyList[replyIndex]['like_count']}',
                                                              fontColor:
                                                                  ColorConfig()
                                                                      .gray3(),
                                                              fontSize: 12.0.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 4.0),
                                                        child:
                                                            CustomTextBuilder(
                                                          text: '·',
                                                          fontColor:
                                                              ColorConfig()
                                                                  .gray3(),
                                                          fontSize: 12.0.sp,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                      // 답글달기 영역
                                                      InkWell(
                                                        onTap: () {
                                                          Navigator.pushNamed(
                                                              context,
                                                              'subReplyList',
                                                              arguments: {
                                                                'reply_data':
                                                                    replyList[
                                                                        replyIndex],
                                                                'my_profile':
                                                                    myProfileData,
                                                              }).then(
                                                              (rt) async {
                                                            ReplyListAPI()
                                                                .replyList(
                                                                    accessToken: await SecureStorageConfig()
                                                                        .storage
                                                                        .read(
                                                                            key:
                                                                                'access_token'),
                                                                    communityIndex:
                                                                        communityIndex)
                                                                .then((value) {
                                                              setState(() {
                                                                replyList =
                                                                    value.result[
                                                                        'data'];
                                                              });
                                                            });
                                                          });
                                                        },
                                                        child:
                                                            CustomTextBuilder(
                                                          text: '답글달기',
                                                          fontColor:
                                                              ColorConfig()
                                                                  .gray3(),
                                                          fontSize: 12.0.sp,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                      replyList[replyIndex]
                                                                  ['is_mine'] ==
                                                              false
                                                          ? Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          4.0),
                                                              child:
                                                                  CustomTextBuilder(
                                                                text: '·',
                                                                fontColor:
                                                                    ColorConfig()
                                                                        .gray3(),
                                                                fontSize:
                                                                    12.0.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            )
                                                          : Container(),
                                                      // 신고 영역
                                                      replyList[replyIndex]
                                                                  ['is_mine'] ==
                                                              false
                                                          ? InkWell(
                                                              onTap: () {
                                                                reportTextController
                                                                    .clear();
                                                                setState(() {
                                                                  reportChecked =
                                                                      [
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    false,
                                                                    false
                                                                  ];
                                                                });

                                                                showModalBottomSheet(
                                                                  context:
                                                                      context,
                                                                  isScrollControlled:
                                                                      true,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            4.0.r),
                                                                  ),
                                                                  builder:
                                                                      (context) {
                                                                    return GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        if (reportFocusNode
                                                                            .hasFocus) {
                                                                          reportFocusNode
                                                                              .unfocus();
                                                                        }
                                                                      },
                                                                      child: StatefulBuilder(builder:
                                                                          (context,
                                                                              state) {
                                                                        return Container(
                                                                          margin:
                                                                              EdgeInsets.only(bottom: reportFocusNode.hasFocus ? MediaQuery.of(context).viewInsets.bottom : 0.0),
                                                                          child:
                                                                              SafeArea(
                                                                            child:
                                                                                SingleChildScrollView(
                                                                              child: Column(
                                                                                mainAxisSize: MainAxisSize.min,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  // 상단 영역
                                                                                  Container(
                                                                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        CustomTextBuilder(
                                                                                          text: TextConstant.reportReason,
                                                                                          fontColor: ColorConfig().dark(),
                                                                                          fontSize: 16.0.sp,
                                                                                          fontWeight: FontWeight.w800,
                                                                                        ),
                                                                                        InkWell(
                                                                                          onTap: () {
                                                                                            Navigator.pop(context);
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
                                                                                  Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: List.generate(reportChecked.length, (reportIndex) {
                                                                                      return InkWell(
                                                                                        onTap: () {
                                                                                          if (!reportChecked.contains(true)) {
                                                                                            state(() {
                                                                                              reportChecked[reportIndex] = !reportChecked[reportIndex];
                                                                                            });
                                                                                          } else {
                                                                                            state(() {
                                                                                              reportChecked = [
                                                                                                false,
                                                                                                false,
                                                                                                false,
                                                                                                false,
                                                                                                false
                                                                                              ];
                                                                                              reportChecked[reportIndex] = !reportChecked[reportIndex];
                                                                                            });
                                                                                          }
                                                                                        },
                                                                                        child: Padding(
                                                                                          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 12.0),
                                                                                          child: Row(
                                                                                            children: [
                                                                                              Container(
                                                                                                width: 24.0.w,
                                                                                                height: 24.0.w,
                                                                                                margin: const EdgeInsets.only(right: 8.0),
                                                                                                child: Checkbox(
                                                                                                  activeColor: ColorConfig().primary(),
                                                                                                  shape: RoundedRectangleBorder(
                                                                                                    borderRadius: BorderRadius.circular(100.0.r),
                                                                                                  ),
                                                                                                  value: reportChecked[reportIndex],
                                                                                                  onChanged: (ck) {
                                                                                                    if (!reportChecked.contains(true)) {
                                                                                                      state(() {
                                                                                                        reportChecked[reportIndex] = ck!;
                                                                                                      });
                                                                                                    } else {
                                                                                                      state(() {
                                                                                                        reportChecked = [
                                                                                                          false,
                                                                                                          false,
                                                                                                          false,
                                                                                                          false,
                                                                                                          false
                                                                                                        ];
                                                                                                        reportChecked[reportIndex] = ck!;
                                                                                                      });
                                                                                                    }
                                                                                                  },
                                                                                                ),
                                                                                              ),
                                                                                              CustomTextBuilder(
                                                                                                text: reportTexts[reportIndex],
                                                                                                fontColor: ColorConfig().gray5(),
                                                                                                fontSize: 14.0.sp,
                                                                                                fontWeight: FontWeight.w700,
                                                                                              )
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      );
                                                                                    }),
                                                                                  ),
                                                                                  Container(
                                                                                    height: 130.0,
                                                                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                                                                    margin: const EdgeInsets.only(bottom: 12.0),
                                                                                    child: TextFormField(
                                                                                      controller: reportTextController,
                                                                                      focusNode: reportFocusNode,
                                                                                      maxLines: null,
                                                                                      keyboardType: TextInputType.multiline,
                                                                                      expands: true,
                                                                                      decoration: InputDecoration(
                                                                                        contentPadding: const EdgeInsets.all(8.0),
                                                                                        isDense: true,
                                                                                        isCollapsed: true,
                                                                                        constraints: const BoxConstraints(
                                                                                          maxHeight: 130.0,
                                                                                          minHeight: 130.0,
                                                                                        ),
                                                                                        enabledBorder: OutlineInputBorder(
                                                                                          borderSide: BorderSide(
                                                                                            width: 1.0,
                                                                                            color: ColorConfig().gray2(),
                                                                                          ),
                                                                                        ),
                                                                                        focusedBorder: OutlineInputBorder(
                                                                                          borderSide: BorderSide(
                                                                                            width: 1.0,
                                                                                            color: ColorConfig().gray2(),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      style: TextStyle(
                                                                                        color: ColorConfig().dark(),
                                                                                        fontSize: 12.0.sp,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                                                                    child: Row(
                                                                                      children: [
                                                                                        InkWell(
                                                                                          onTap: () {
                                                                                            Navigator.pop(context);
                                                                                          },
                                                                                          child: Container(
                                                                                            width: (MediaQuery.of(context).size.width - (40.0 + 8.0)) / 2,
                                                                                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                                                                                            margin: const EdgeInsets.only(right: 8.0),
                                                                                            decoration: BoxDecoration(
                                                                                              color: ColorConfig().gray3(),
                                                                                              borderRadius: BorderRadius.circular(4.0.r),
                                                                                            ),
                                                                                            child: Center(
                                                                                              child: CustomTextBuilder(
                                                                                                text: TextConstant.cancel,
                                                                                                fontColor: ColorConfig().white(),
                                                                                                fontSize: 14.0.sp,
                                                                                                fontWeight: FontWeight.w800,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        InkWell(
                                                                                          onTap: () {
                                                                                            if (reportChecked.contains(true) == false) {
                                                                                              ToastModel().toast('신고항목을 선택해주세요');
                                                                                            } else if (reportTextController.text.trim().isEmpty) {
                                                                                              ToastModel().toast('신고사유를 입력해주세요');
                                                                                            } else {
                                                                                              PopupBuilder(
                                                                                                    title: TextConstant.reportTitle,
                                                                                                    content: TextConstant.reportDescription,
                                                                                                    actions: [
                                                                                                      Row(
                                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                        children: [
                                                                                                          InkWell(
                                                                                                            onTap: () {
                                                                                                              Navigator.pop(context);
                                                                                                            },
                                                                                                            splashColor: ColorConfig.transparent,
                                                                                                            child: Container(
                                                                                                              width: (MediaQuery.of(context).size.width - 120.0.w) / 2,
                                                                                                              padding: const EdgeInsets.symmetric(vertical: 16.5),
                                                                                                              margin: const EdgeInsets.only(right: 8.0),
                                                                                                              decoration: BoxDecoration(
                                                                                                                color: ColorConfig().gray3(),
                                                                                                                borderRadius: BorderRadius.circular(4.0.r),
                                                                                                              ),
                                                                                                              child: Center(
                                                                                                                child: CustomTextBuilder(
                                                                                                                  text: TextConstant.close,
                                                                                                                  fontColor: ColorConfig().white(),
                                                                                                                  fontSize: 14.0.sp,
                                                                                                                  fontWeight: FontWeight.w800,
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                          InkWell(
                                                                                                            onTap: () async {
                                                                                                              Navigator.pop(context);

                                                                                                              ReportReply().reportReply(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), replyIndex: replyList[replyIndex]['reply_index'], type: reportChecked.indexOf(true), description: reportTextController.text).then((value) {
                                                                                                                if (value.result['status'] == 1) {
                                                                                                                  Navigator.pop(context);
                                                                                                                  ToastModel().iconToast(value.result['message']);
                                                                                                                } else {
                                                                                                                  ToastModel().iconToast(value.result['message'], iconType: 2);
                                                                                                                }
                                                                                                              });
                                                                                                            },
                                                                                                            splashColor: ColorConfig.transparent,
                                                                                                            child: Container(
                                                                                                              width: (MediaQuery.of(context).size.width - 120.0.w) / 2,
                                                                                                              padding: const EdgeInsets.symmetric(vertical: 16.5),
                                                                                                              decoration: BoxDecoration(
                                                                                                                color: ColorConfig().dark(),
                                                                                                                borderRadius: BorderRadius.circular(4.0.r),
                                                                                                              ),
                                                                                                              child: Center(
                                                                                                                child: CustomTextBuilder(
                                                                                                                  text: TextConstant.doReport,
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
                                                                                                  ).ig -
                                                                                                  publicDialog(context);
                                                                                            }
                                                                                          },
                                                                                          child: Container(
                                                                                            width: (MediaQuery.of(context).size.width - (40.0 + 8.0)) / 2,
                                                                                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                                                                                            decoration: BoxDecoration(
                                                                                              color: ColorConfig().dark(),
                                                                                              borderRadius: BorderRadius.circular(4.0.r),
                                                                                            ),
                                                                                            child: Center(
                                                                                              child: CustomTextBuilder(
                                                                                                text: TextConstant.doReport,
                                                                                                fontColor: ColorConfig().white(),
                                                                                                fontSize: 14.0.sp,
                                                                                                fontWeight: FontWeight.w800,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      }),
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              child:
                                                                  CustomTextBuilder(
                                                                text: '신고',
                                                                fontColor:
                                                                    ColorConfig()
                                                                        .gray3(),
                                                                fontSize:
                                                                    12.0.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            )
                                                          : Container(),
                                                      replyList[replyIndex]
                                                                  ['is_mine'] ==
                                                              true
                                                          ? Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          4.0),
                                                              child:
                                                                  CustomTextBuilder(
                                                                text: '·',
                                                                fontColor:
                                                                    ColorConfig()
                                                                        .gray3(),
                                                                fontSize:
                                                                    12.0.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            )
                                                          : Container(),
                                                      // 수정 영역
                                                      replyList[replyIndex]
                                                                  ['is_mine'] ==
                                                              true
                                                          ? InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  replyFocusNode
                                                                      .requestFocus();

                                                                  replyTextController
                                                                      .text = replyList[
                                                                          replyIndex]
                                                                      [
                                                                      'content'];
                                                                  onEdit = true;
                                                                  editReplyIndex =
                                                                      replyList[
                                                                              replyIndex]
                                                                          [
                                                                          'reply_index'];
                                                                });
                                                              },
                                                              child:
                                                                  CustomTextBuilder(
                                                                text: '수정',
                                                                fontColor:
                                                                    ColorConfig()
                                                                        .gray3(),
                                                                fontSize:
                                                                    12.0.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            )
                                                          : Container(),
                                                      replyList[replyIndex]
                                                                  ['is_mine'] ==
                                                              true
                                                          ? Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          4.0),
                                                              child:
                                                                  CustomTextBuilder(
                                                                text: '·',
                                                                fontColor:
                                                                    ColorConfig()
                                                                        .gray3(),
                                                                fontSize:
                                                                    12.0.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            )
                                                          : Container(),
                                                      // 삭제 영역
                                                      replyList[replyIndex]
                                                                  ['is_mine'] ==
                                                              true
                                                          ? InkWell(
                                                              onTap: () {
                                                                PopupBuilder(
                                                                      title: TextConstant
                                                                          .deleteReplyTitle,
                                                                      content:
                                                                          TextConstant
                                                                              .deleteReplyContent,
                                                                      actions: [
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            InkWell(
                                                                              onTap: () {
                                                                                Navigator.pop(context);
                                                                              },
                                                                              splashColor: ColorConfig.transparent,
                                                                              child: Container(
                                                                                width: (MediaQuery.of(context).size.width - 120.0.w) / 2,
                                                                                padding: const EdgeInsets.symmetric(vertical: 16.5),
                                                                                margin: const EdgeInsets.only(right: 8.0),
                                                                                decoration: BoxDecoration(
                                                                                  color: ColorConfig().gray3(),
                                                                                  borderRadius: BorderRadius.circular(4.0.r),
                                                                                ),
                                                                                child: Center(
                                                                                  child: CustomTextBuilder(
                                                                                    text: TextConstant.close,
                                                                                    fontColor: ColorConfig().white(),
                                                                                    fontSize: 14.0.sp,
                                                                                    fontWeight: FontWeight.w800,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            InkWell(
                                                                              onTap: () async {
                                                                                Navigator.pop(context);

                                                                                ReplyDeleteAPI().replyDelete(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), replyIndex: replyList[replyIndex]['reply_index']).then((value) {
                                                                                  if (value.result['status'] == 1) {
                                                                                    setState(() {
                                                                                      replyList.removeAt(replyIndex);
                                                                                    });
                                                                                  } else {
                                                                                    ToastModel().iconToast(value.result['message'], iconType: 2);
                                                                                  }
                                                                                });
                                                                              },
                                                                              splashColor: ColorConfig.transparent,
                                                                              child: Container(
                                                                                width: (MediaQuery.of(context).size.width - 120.0.w) / 2,
                                                                                padding: const EdgeInsets.symmetric(vertical: 16.5),
                                                                                decoration: BoxDecoration(
                                                                                  color: ColorConfig().dark(),
                                                                                  borderRadius: BorderRadius.circular(4.0.r),
                                                                                ),
                                                                                child: Center(
                                                                                  child: CustomTextBuilder(
                                                                                    text: TextConstant.doDelete,
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
                                                                    ).ig -
                                                                    publicDialog(
                                                                        context);
                                                              },
                                                              child:
                                                                  CustomTextBuilder(
                                                                text: '삭제',
                                                                fontColor:
                                                                    ColorConfig()
                                                                        .gray3(),
                                                                fontSize:
                                                                    12.0.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            )
                                                          : Container(),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // 답글 더보기 영역
                                    replyList[replyIndex]['child_list'].length >
                                            3
                                        ? InkWell(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                  context, 'subReplyList',
                                                  arguments: {
                                                    'reply_data':
                                                        replyList[replyIndex],
                                                    'my_profile': myProfileData,
                                                  }).then((rt) async {
                                                ReplyListAPI()
                                                    .replyList(
                                                        accessToken:
                                                            await SecureStorageConfig()
                                                                .storage
                                                                .read(
                                                                    key:
                                                                        'access_token'),
                                                        communityIndex:
                                                            communityIndex)
                                                    .then((value) {
                                                  setState(() {
                                                    replyList =
                                                        value.result['data'];
                                                  });
                                                });
                                              });
                                            },
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20.0,
                                                      vertical: 8.0),
                                              decoration: BoxDecoration(
                                                color: ColorConfig().white(),
                                                border: Border(
                                                  top: BorderSide(
                                                    width: 1.0,
                                                    color:
                                                        ColorConfig().gray1(),
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 4.0),
                                                    child: SVGBuilder(
                                                      image:
                                                          'assets/icon/plus.svg',
                                                      width: 16.0.w,
                                                      height: 16.0.w,
                                                      color:
                                                          ColorConfig().gray3(),
                                                    ),
                                                  ),
                                                  CustomTextBuilder(
                                                    text:
                                                        '답글 ${replyList[replyIndex]['child_list'].length}개',
                                                    fontColor:
                                                        ColorConfig().gray5(),
                                                    fontSize: 12.0.sp,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 4.0),
                                                    child: CustomTextBuilder(
                                                      text: TextConstant.more,
                                                      fontColor:
                                                          ColorConfig().gray3(),
                                                      fontSize: 12.0.sp,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, 'subReplyList',
                                            arguments: {
                                              'reply_data':
                                                  replyList[replyIndex],
                                              'my_profile': myProfileData,
                                            }).then((rt) async {
                                          ReplyListAPI()
                                              .replyList(
                                                  accessToken:
                                                      await SecureStorageConfig()
                                                          .storage
                                                          .read(
                                                              key:
                                                                  'access_token'),
                                                  communityIndex:
                                                      communityIndex)
                                              .then((value) {
                                            setState(() {
                                              replyList = value.result['data'];
                                            });
                                          });
                                        });
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: List.generate(
                                            replyList[replyIndex]['child_list']
                                                        .length >
                                                    3
                                                ? 3
                                                : replyList[replyIndex]
                                                        ['child_list']
                                                    .length, (childReply) {
                                          return Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                                vertical: 8.0),
                                            color: ColorConfig().gray1(),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Image(
                                                  image: const AssetImage(
                                                      'assets/img/child-reply-arrow.png'),
                                                  width: 20.0.w,
                                                  height: 36.0.w,
                                                  filterQuality:
                                                      FilterQuality.high,
                                                ),
                                                // 대댓글 프로필 이미지 영역
                                                Container(
                                                  width: 36.0.w,
                                                  height: 36.0.w,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      width: 1.0,
                                                      color: ColorConfig()
                                                          .borderGray1(
                                                              opacity: 0.3),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            18.0.r),
                                                    image: replyList[replyIndex]
                                                                        [
                                                                        'child_list']
                                                                    [childReply]
                                                                ['image'] !=
                                                            null
                                                        ? DecorationImage(
                                                            image: NetworkImage(
                                                                replyList[replyIndex]
                                                                            [
                                                                            'child_list']
                                                                        [
                                                                        childReply]
                                                                    ['image']),
                                                            fit: BoxFit.cover,
                                                            filterQuality:
                                                                FilterQuality
                                                                    .high,
                                                          )
                                                        : const DecorationImage(
                                                            image: AssetImage(
                                                                'assets/img/profile_default.png'),
                                                            fit: BoxFit.cover,
                                                            filterQuality:
                                                                FilterQuality
                                                                    .high),
                                                  ),
                                                ),
                                                const SizedBox(width: 12.0),
                                                // 대댓글 내용 영역
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // 사용자 닉네임, 업로드/수정날짜 영역
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            // 사용자 닉네임 영역
                                                            CustomTextBuilder(
                                                              text:
                                                                  '${replyList[replyIndex]['child_list'][childReply]['nick']}',
                                                              fontColor:
                                                                  ColorConfig()
                                                                      .gray5(),
                                                              fontSize: 12.0.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                            // 업로드/수정날짜 영역
                                                            CustomTextBuilder(
                                                              text: replyList[replyIndex]['child_list']
                                                                              [childReply]
                                                                          [
                                                                          'create_dt'] ==
                                                                      replyList[replyIndex]
                                                                              [
                                                                              'child_list'][childReply]
                                                                          [
                                                                          'modify_dt']
                                                                  ? DateCalculatorWrapper()
                                                                      .daysCalculator(
                                                                          replyList[replyIndex]
                                                                              [
                                                                              'create_dt'])
                                                                  : '${DateCalculatorWrapper().daysCalculator(replyList[replyIndex]['modify_dt'])} (수정됨)',
                                                              fontColor:
                                                                  ColorConfig()
                                                                      .gray3(),
                                                              fontSize: 10.0.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      // 대댓글 내용 영역
                                                      CustomTextBuilder(
                                                        text:
                                                            '${replyList[replyIndex]['child_list'][childReply]['content']}',
                                                        fontColor: ColorConfig()
                                                            .gray5(),
                                                        fontSize: 12.0.sp,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                      // 좋아요, 신고 영역
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .only(top: 8.0),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            InkWell(
                                                              onTap: () async {
                                                                if (replyList[replyIndex]['child_list']
                                                                            [
                                                                            childReply]
                                                                        [
                                                                        'is_like'] ==
                                                                    false) {
                                                                  ReplyAddLikeAPI()
                                                                      .replyAddLike(
                                                                          accessToken: await SecureStorageConfig().storage.read(
                                                                              key:
                                                                                  'access_token'),
                                                                          replyIndex: replyList[replyIndex]['child_list'][childReply]
                                                                              [
                                                                              'reply_index'])
                                                                      .then(
                                                                          (value) {
                                                                    setState(
                                                                        () {
                                                                      replyList[replyIndex]['child_list']
                                                                              [
                                                                              childReply]
                                                                          [
                                                                          'is_like'] = true;
                                                                      replyList[replyIndex]['child_list']
                                                                              [
                                                                              childReply]
                                                                          [
                                                                          'like_count']++;
                                                                    });
                                                                  });
                                                                } else {
                                                                  ReplyCancelLikeAPI()
                                                                      .replyCancelLike(
                                                                          accessToken: await SecureStorageConfig().storage.read(
                                                                              key:
                                                                                  'access_token'),
                                                                          replyIndex: replyList[replyIndex]['child_list'][childReply]
                                                                              [
                                                                              'reply_index'])
                                                                      .then(
                                                                          (value) {
                                                                    setState(
                                                                        () {
                                                                      replyList[replyIndex]['child_list'][childReply]
                                                                              [
                                                                              'is_like'] =
                                                                          false;
                                                                      replyList[replyIndex]['child_list']
                                                                              [
                                                                              childReply]
                                                                          [
                                                                          'like_count']--;
                                                                    });
                                                                  });
                                                                }
                                                              },
                                                              child: Row(
                                                                children: [
                                                                  Container(
                                                                    margin: const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            4.0),
                                                                    child:
                                                                        SVGBuilder(
                                                                      image: replyList[replyIndex]['child_list'][childReply]['is_like'] ==
                                                                              true
                                                                          ? 'assets/icon/heart-on-disabled-bg.svg'
                                                                          : 'assets/icon/heart-off-disabled-bg.svg',
                                                                      width:
                                                                          16.0.w,
                                                                      height:
                                                                          16.0.w,
                                                                      color: ColorConfig()
                                                                          .gray3(),
                                                                    ),
                                                                  ),
                                                                  CustomTextBuilder(
                                                                    text:
                                                                        '좋아요 ${replyList[replyIndex]['child_list'][childReply]['like_count']}',
                                                                    fontColor:
                                                                        ColorConfig()
                                                                            .gray3(),
                                                                    fontSize:
                                                                        12.0.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            replyList[replyIndex]['child_list']
                                                                            [
                                                                            childReply]
                                                                        [
                                                                        'is_mine'] ==
                                                                    false
                                                                ? Container(
                                                                    margin: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            4.0),
                                                                    child:
                                                                        CustomTextBuilder(
                                                                      text: '·',
                                                                      fontColor:
                                                                          ColorConfig()
                                                                              .gray3(),
                                                                      fontSize:
                                                                          12.0.sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                                  )
                                                                : Container(),
                                                            // 신고 영역
                                                            replyList[replyIndex]['child_list']
                                                                            [
                                                                            childReply]
                                                                        [
                                                                        'is_mine'] ==
                                                                    false
                                                                ? CustomTextBuilder(
                                                                    text: '신고',
                                                                    fontColor:
                                                                        ColorConfig()
                                                                            .gray3(),
                                                                    fontSize:
                                                                        12.0.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                  )
                                                                : Container(),
                                                            replyList[replyIndex]['child_list']
                                                                            [
                                                                            childReply]
                                                                        [
                                                                        'is_mine'] ==
                                                                    true
                                                                ? Container(
                                                                    margin: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            4.0),
                                                                    child:
                                                                        CustomTextBuilder(
                                                                      text: '·',
                                                                      fontColor:
                                                                          ColorConfig()
                                                                              .gray3(),
                                                                      fontSize:
                                                                          12.0.sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                                  )
                                                                : Container(),
                                                            // 수정 영역
                                                            replyList[replyIndex]['child_list']
                                                                            [
                                                                            childReply]
                                                                        [
                                                                        'is_mine'] ==
                                                                    true
                                                                ? CustomTextBuilder(
                                                                    text: '수정',
                                                                    fontColor:
                                                                        ColorConfig()
                                                                            .gray3(),
                                                                    fontSize:
                                                                        12.0.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                  )
                                                                : Container(),
                                                            replyList[replyIndex]['child_list']
                                                                            [
                                                                            childReply]
                                                                        [
                                                                        'is_mine'] ==
                                                                    true
                                                                ? Container(
                                                                    margin: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            4.0),
                                                                    child:
                                                                        CustomTextBuilder(
                                                                      text: '·',
                                                                      fontColor:
                                                                          ColorConfig()
                                                                              .gray3(),
                                                                      fontSize:
                                                                          12.0.sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                                  )
                                                                : Container(),
                                                            // 삭제 영역
                                                            replyList[replyIndex]['child_list']
                                                                            [
                                                                            childReply]
                                                                        [
                                                                        'is_mine'] ==
                                                                    true
                                                                ? InkWell(
                                                                    onTap: () {
                                                                      PopupBuilder(
                                                                            title:
                                                                                TextConstant.deleteReplyTitle,
                                                                            content:
                                                                                TextConstant.deleteReplyContent,
                                                                            actions: [
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  InkWell(
                                                                                    onTap: () {
                                                                                      Navigator.pop(context);
                                                                                    },
                                                                                    splashColor: ColorConfig.transparent,
                                                                                    child: Container(
                                                                                      width: (MediaQuery.of(context).size.width - 120.0.w) / 2,
                                                                                      padding: const EdgeInsets.symmetric(vertical: 16.5),
                                                                                      margin: const EdgeInsets.only(right: 8.0),
                                                                                      decoration: BoxDecoration(
                                                                                        color: ColorConfig().gray3(),
                                                                                        borderRadius: BorderRadius.circular(4.0.r),
                                                                                      ),
                                                                                      child: Center(
                                                                                        child: CustomTextBuilder(
                                                                                          text: TextConstant.close,
                                                                                          fontColor: ColorConfig().white(),
                                                                                          fontSize: 14.0.sp,
                                                                                          fontWeight: FontWeight.w800,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  InkWell(
                                                                                    onTap: () async {
                                                                                      Navigator.pop(context);

                                                                                      ReplyDeleteAPI().replyDelete(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), replyIndex: replyList[replyIndex]['child_list'][childReply]['reply_index']).then((value) {
                                                                                        if (value.result['status'] == 1) {
                                                                                          setState(() {
                                                                                            replyList[replyIndex]['child_list'][childReply].removeAt(childReply);
                                                                                          });
                                                                                        } else {
                                                                                          ToastModel().iconToast(value.result['message'], iconType: 2);
                                                                                        }
                                                                                      });
                                                                                    },
                                                                                    splashColor: ColorConfig.transparent,
                                                                                    child: Container(
                                                                                      width: (MediaQuery.of(context).size.width - 120.0.w) / 2,
                                                                                      padding: const EdgeInsets.symmetric(vertical: 16.5),
                                                                                      decoration: BoxDecoration(
                                                                                        color: ColorConfig().dark(),
                                                                                        borderRadius: BorderRadius.circular(4.0.r),
                                                                                      ),
                                                                                      child: Center(
                                                                                        child: CustomTextBuilder(
                                                                                          text: TextConstant.doDelete,
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
                                                                          ).ig -
                                                                          publicDialog(
                                                                              context);
                                                                    },
                                                                    child:
                                                                        CustomTextBuilder(
                                                                      text:
                                                                          '삭제',
                                                                      fontColor:
                                                                          ColorConfig()
                                                                              .gray3(),
                                                                      fontSize:
                                                                          12.0.sp,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                                  )
                                                                : Container(),
                                                          ],
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
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 16.0),
                            // 영역이 가려지지 않도록 댓글입력폼 높이값만큼 더해줌
                            SizedBox(height: 16.0 + 16.0 + 36.0.w),
                          ],
                        ),
                      ),
                      onEdit == true
                          ? Container(color: ColorConfig().overlay())
                          : Container(),
                      // 댓글 입력폼 영역
                      Positioned(
                        bottom: 0.0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: ColorConfig().white(),
                            border: Border(
                              top: BorderSide(
                                width: 1.0,
                                color: ColorConfig().gray2(),
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  // 프로필 이미지 영역
                                  Container(
                                    width: 36.0.w,
                                    height: 36.0.w,
                                    margin: onEdit == true
                                        ? const EdgeInsets.only(right: 8.0)
                                        : null,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(18.0.r),
                                      image: myProfileData['image'] != null
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                  myProfileData['image']),
                                              fit: BoxFit.cover,
                                              filterQuality: FilterQuality.high,
                                            )
                                          : const DecorationImage(
                                              image: AssetImage(
                                                  'assets/img/profile_default.png'),
                                              fit: BoxFit.cover,
                                              filterQuality: FilterQuality.high,
                                            ),
                                    ),
                                  ),
                                  // 댓글 입력폼 영역
                                  Expanded(
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxHeight: onEdit == true
                                            ? 120.0
                                            : double.infinity,
                                      ),
                                      child: TextFormField(
                                        controller: replyTextController,
                                        focusNode: replyFocusNode,
                                        maxLines: onEdit == true ? null : 1,
                                        expands: onEdit == true ? true : false,
                                        decoration: InputDecoration(
                                          isDense:
                                              onEdit == true ? true : false,
                                          isCollapsed:
                                              onEdit == true ? true : false,
                                          contentPadding:
                                              const EdgeInsets.all(12.0),
                                          // constraints: const BoxConstraints(
                                          //   maxHeight: 100.0,
                                          // ),
                                          hintText: TextConstant.replyHintText,
                                          hintStyle: TextStyle(
                                            color: ColorConfig().gray3(),
                                            fontSize: 14.0.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: onEdit == true
                                                ? BorderSide(
                                                    width: 1.0,
                                                    color:
                                                        ColorConfig().gray2(),
                                                  )
                                                : BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: onEdit == true
                                                ? BorderSide(
                                                    width: 1.0,
                                                    color:
                                                        ColorConfig().gray2(),
                                                  )
                                                : BorderSide.none,
                                          ),
                                        ),
                                        style: TextStyle(
                                          color: ColorConfig().dark(),
                                          fontSize: 14.0.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        keyboardType: onEdit == true
                                            ? TextInputType.multiline
                                            : null,
                                      ),
                                    ),
                                  ),
                                  // 등록버튼 영역
                                  onEdit == false
                                      ? InkWell(
                                          onTap: () async {
                                            if (replyTextController
                                                .text.isNotEmpty) {
                                              if (_debounce?.isActive ?? false)
                                                _debounce!.cancel();

                                              _debounce = Timer(
                                                  const Duration(
                                                      milliseconds: 300),
                                                  () async {
                                                WriteReplyAPI()
                                                    .writeReply(
                                                        accessToken:
                                                            await SecureStorageConfig()
                                                                .storage
                                                                .read(
                                                                    key:
                                                                        'access_token'),
                                                        communityIndex:
                                                            communityIndex,
                                                        content:
                                                            replyTextController
                                                                .text)
                                                    .then((value) async {
                                                  if (value.result['status'] ==
                                                      1) {
                                                    replyFocusNode.unfocus();
                                                    replyTextController.clear();

                                                    ReplyListAPI()
                                                        .replyList(
                                                            accessToken:
                                                                await SecureStorageConfig()
                                                                    .storage
                                                                    .read(
                                                                        key:
                                                                            'access_token'),
                                                            communityIndex:
                                                                communityIndex)
                                                        .then((value) {
                                                      setState(() {
                                                        replyList = value
                                                            .result['data'];
                                                      });
                                                    });
                                                  } else {
                                                    ToastModel().iconToast(
                                                        value.result['message'],
                                                        iconType: 2);
                                                  }
                                                });
                                              });
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 12.0),
                                            decoration: BoxDecoration(
                                              color: replyTextController
                                                      .text.isNotEmpty
                                                  ? ColorConfig().dark()
                                                  : ColorConfig().gray2(),
                                              borderRadius:
                                                  BorderRadius.circular(4.0.r),
                                            ),
                                            child: CustomTextBuilder(
                                              text: TextConstant.regist,
                                              fontColor: replyTextController
                                                      .text.isNotEmpty
                                                  ? ColorConfig().white()
                                                  : ColorConfig().gray3(),
                                              fontSize: 13.0.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                              // 수정하기로 했을 때
                              onEdit == true
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              replyFocusNode.unfocus();
                                              replyTextController.clear();
                                              onEdit = false;
                                              editReplyIndex = -1;
                                            });
                                          },
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                top: 8.0, right: 8.0),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 12.0),
                                            decoration: BoxDecoration(
                                              color: ColorConfig().white(),
                                              border: Border.all(
                                                width: 1.0,
                                                color: ColorConfig().gray2(),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4.0.r),
                                            ),
                                            child: CustomTextBuilder(
                                              text: TextConstant.cancel,
                                              fontColor: ColorConfig().gray5(),
                                              fontSize: 13.0.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            setState(() {
                                              replyRegistStatus = true;
                                            });

                                            if (replyRegistStatus == true) {
                                              if (_debounce?.isActive ?? false)
                                                _debounce!.cancel();

                                              _debounce = Timer(
                                                  const Duration(
                                                      milliseconds: 300),
                                                  () async {
                                                if (replyTextController
                                                    .text.isNotEmpty) {
                                                  PatchReplyAPI()
                                                      .replyPatch(
                                                          accessToken:
                                                              await SecureStorageConfig()
                                                                  .storage
                                                                  .read(
                                                                      key:
                                                                          'access_token'),
                                                          replyIndex:
                                                              editReplyIndex,
                                                          content:
                                                              replyTextController
                                                                  .text)
                                                      .then((value) async {
                                                    if (value
                                                            .result['status'] ==
                                                        1) {
                                                      setState(() {
                                                        replyFocusNode
                                                            .unfocus();
                                                        replyTextController
                                                            .clear();
                                                        onEdit = false;
                                                        editReplyIndex = -1;
                                                        replyRegistStatus =
                                                            false;
                                                      });

                                                      ReplyListAPI()
                                                          .replyList(
                                                              accessToken:
                                                                  await SecureStorageConfig()
                                                                      .storage
                                                                      .read(
                                                                          key:
                                                                              'access_token'),
                                                              communityIndex:
                                                                  communityIndex)
                                                          .then((value) {
                                                        setState(() {
                                                          replyList = value
                                                              .result['data'];
                                                        });
                                                      });
                                                    } else {
                                                      ToastModel().iconToast(
                                                          value.result[
                                                              'message'],
                                                          iconType: 2);
                                                    }
                                                  });
                                                }
                                              });
                                            }
                                          },
                                          child: Container(
                                            margin:
                                                const EdgeInsets.only(top: 8.0),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 12.0),
                                            decoration: BoxDecoration(
                                              color: replyTextController
                                                      .text.isNotEmpty
                                                  ? ColorConfig().dark()
                                                  : ColorConfig().gray2(),
                                              borderRadius:
                                                  BorderRadius.circular(4.0.r),
                                            ),
                                            child: CustomTextBuilder(
                                              text: TextConstant.regist,
                                              fontColor: replyTextController
                                                      .text.isNotEmpty
                                                  ? ColorConfig().white()
                                                  : ColorConfig().gray3(),
                                              fontSize: 13.0.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Container(),
                            ],
                          ),
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
}
