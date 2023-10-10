import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/api/community/report_reply.dart';
import 'package:ig-public_v3/api/reply/patch_reply.dart';
import 'package:ig-public_v3/api/reply/reply_add_like.dart';
import 'package:ig-public_v3/api/reply/reply_cancel_like.dart';
import 'package:ig-public_v3/api/reply/reply_delete.dart';
import 'package:ig-public_v3/api/reply/reply_list.dart';
import 'package:ig-public_v3/api/reply/write_reply.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/date_calculator/date_calculator.dart';
import 'package:ig-public_v3/component/popup/popup.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/src/route_argument.dart';
import 'package:ig-public_v3/util/toast.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';

class SubReplyListScreen extends StatefulWidget {
  const SubReplyListScreen({super.key});

  @override
  State<SubReplyListScreen> createState() => _SubReplyListScreenState();
}

class _SubReplyListScreenState extends State<SubReplyListScreen> {
  late TextEditingController replyTextController;
  late TextEditingController reportTextController;
  late FocusNode replyFocusNode;
  late FocusNode reportFocusNode;

  Timer? _debounce;

  int editReplyIndex = -1;
  int subreplyIndex = -1;

  bool onEdit = false;
  bool replyRegistStatus = false;

  List<bool> reportChecked = [false, false, false, false, false];
  List<String> reportTexts = ['영리목적/홍보성', '음란성/선정성', '욕설/인신공격', '도배', '기타'];

  Map<String, dynamic> replyData = {};
  Map<String, dynamic> myProfile = {};

  @override
  void initState() {
    super.initState();

    replyTextController = TextEditingController()..addListener(() {
      setState(() {});
    });
    reportTextController = TextEditingController()..addListener(() {
      setState(() {});
    });
    
    replyFocusNode = FocusNode();
    reportFocusNode = FocusNode();

    Future.delayed(Duration.zero, () {
      if (RouteGetArguments().getArgs(context)['reply_data'] != null) {
        setState(() {
          replyData = RouteGetArguments().getArgs(context)['reply_data'];
        });
      }
      if (RouteGetArguments().getArgs(context)['my_profile'] != null) {
        setState(() {
          myProfile = RouteGetArguments().getArgs(context)['my_profile'];
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (replyFocusNode.hasFocus) {
          replyFocusNode.unfocus();

          if (onEdit == true) {
            setState(() {
              onEdit = false;
              editReplyIndex = -1;
              subreplyIndex = -1;
            });
          }
        }
      },
      child: Scaffold(
        appBar: ig-publicAppBar(
          leading: ig-publicAppBarLeading(
            press: () => Navigator.pop(context),
          ),
          title: const ig-publicAppBarTitle(
            title: TextConstant.subReply,
          )
        ),
        body: replyData.isNotEmpty ? Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: ColorConfig().white(),
          child: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 프로필 이미지 영역
                            Container(
                              width: 36.0.w,
                              height: 36.0.w,
                              margin: const EdgeInsets.only(right: 12.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18.0.r),
                                image: replyData['image'] != null
                                  ? DecorationImage(
                                      image: NetworkImage(replyData['image']),
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
                            // 댓글 내용 영역
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 사용자 아이디, 댓글등록날짜 영역
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // 사용자 아이디 영역
                                        Expanded(
                                          child: CustomTextBuilder(
                                            text: '${replyData['nick']}',
                                            fontColor: replyData['is_mine'] == true ? ColorConfig().primary() : ColorConfig().gray5(),
                                            fontSize: 12.0.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        // 댓글등록날짜 영역
                                        Container(
                                          margin: const EdgeInsets.only(left: 12.0),
                                          child: CustomTextBuilder(
                                            text: replyData['create_dt'] == replyData['modify_dt']
                                              ? DateCalculatorWrapper().daysCalculator(replyData['create_dt'])
                                              : '${DateCalculatorWrapper().daysCalculator(replyData['modify_dt'])} (수정됨)',
                                            fontColor: ColorConfig().gray3(),
                                            fontSize: 10.0.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // 댓글내용 영역
                                  CustomTextBuilder(
                                    text: '${replyData['content']}',
                                    fontColor: ColorConfig().gray5(),
                                    fontSize: 12.0.sp,
                                    fontWeight: FontWeight.w400,
                                    height: 1.2,
                                  ),
                                  // 좋아요 수, 답글달기, 신고 영역
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      children: [
                                        // 좋아요 수 영역
                                        InkWell(
                                          onTap: () async {
                                            if (replyData['is_like'] == false) {
                                              ReplyAddLikeAPI().replyAddLike(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), replyIndex: replyData['reply_index']).then((value) {
                                                setState(() {
                                                  replyData['is_like'] = true;
                                                  replyData['like_count']++;
                                                });
                                              });
                                            } else {
                                              ReplyCancelLikeAPI().replyCancelLike(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), replyIndex: replyData['reply_index']).then((value) {
                                                setState(() {
                                                  replyData['is_like'] = false;
                                                  replyData['like_count']--;
                                                });
                                              });
                                            }
                                          },
                                          child: Row(
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(right: 4.0),
                                                child: SVGBuilder(
                                                  image: replyData['is_like'] == true ? 'assets/icon/heart-on-disabled-bg.svg' : 'assets/icon/heart-off-disabled-bg.svg',
                                                  width: 16.0.w,
                                                  height: 16.0.w,
                                                  color: ColorConfig().gray3(),
                                                ),
                                              ),
                                              CustomTextBuilder(
                                                text: '좋아요 ${replyData['like_count']}',
                                                fontColor: ColorConfig().gray3(),
                                                fontSize: 12.0.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: CustomTextBuilder(
                                            text: '·',
                                            fontColor: ColorConfig().gray3(),
                                            fontSize: 12.0.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        // 답글달기 영역
                                        InkWell(
                                          onTap: () {
                                            
                                          },
                                          child: CustomTextBuilder(
                                            text: '답글달기',
                                            fontColor: ColorConfig().gray3(),
                                            fontSize: 12.0.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        replyData['is_mine'] == false ? Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: CustomTextBuilder(
                                            text: '·',
                                            fontColor: ColorConfig().gray3(),
                                            fontSize: 12.0.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ) : Container(),
                                        // 신고 영역
                                        replyData['is_mine'] == false ? CustomTextBuilder(
                                          text: '신고',
                                          fontColor: ColorConfig().gray3(),
                                          fontSize: 12.0.sp,
                                          fontWeight: FontWeight.w700,
                                        ) : Container(),
                                        replyData['is_mine'] == true ? Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: CustomTextBuilder(
                                            text: '·',
                                            fontColor: ColorConfig().gray3(),
                                            fontSize: 12.0.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ) : Container(),
                                        // 수정 영역
                                        replyData['is_mine'] == true ? InkWell(
                                          onTap: () {
                                            setState(() {
                                              replyFocusNode.requestFocus();

                                              replyTextController.text = replyData['content'];
                                              onEdit = true;
                                              editReplyIndex = replyData['reply_index'];
                                            });
                                          },
                                          child: CustomTextBuilder(
                                            text: '수정',
                                            fontColor: ColorConfig().gray3(),
                                            fontSize: 12.0.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ) : Container(),
                                        replyData['is_mine'] == true ? Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                          child: CustomTextBuilder(
                                            text: '·',
                                            fontColor: ColorConfig().gray3(),
                                            fontSize: 12.0.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ) : Container(),
                                        // 삭제 영역
                                        replyData['is_mine'] == true ? InkWell(
                                          onTap: () {
                                            PopupBuilder(
                                              title: TextConstant.deleteReplyTitle,
                                              content: TextConstant.deleteReplyContent,
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
                
                                                        // ReplyDeleteAPI().replyDelete(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), replyIndex: replyData['reply_index']).then((value) {
                                                        //   if (value.result['status'] == 1) {
                                                        //     setState(() {
                                                        //       replyList.removeAt(replyIndex);
                                                        //     });
                                                        //   } else {
                                                        //     ToastModel().iconToast(value.result['message'], iconType: 2);
                                                        //   }
                                                        // });
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
                                            ).ig-publicDialog(context);
                                          },
                                          child: CustomTextBuilder(
                                            text: '삭제',
                                            fontColor: ColorConfig().gray3(),
                                            fontSize: 12.0.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ) : Container(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(replyData['child_list'].length, (childReply) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                            color: ColorConfig().gray1(),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image(
                                  image: const AssetImage('assets/img/child-reply-arrow.png'),
                                  width: 20.0.w,
                                  height: 36.0.w,
                                  filterQuality: FilterQuality.high,
                                ),
                                // 대댓글 프로필 이미지 영역
                                Container(
                                  width: 36.0.w,
                                  height: 36.0.w,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1.0,
                                      color: ColorConfig().borderGray1(opacity: 0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(18.0.r),
                                    image: replyData['child_list'][childReply]['image'] != null
                                      ? DecorationImage(
                                          image: NetworkImage(replyData['child_list'][childReply]['image']),
                                          fit: BoxFit.cover,
                                          filterQuality: FilterQuality.high,
                                        )
                                      : const DecorationImage(
                                          image: AssetImage('assets/img/profile_default.png'),
                                          fit: BoxFit.cover,
                                          filterQuality: FilterQuality.high
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 12.0),
                                // 대댓글 내용 영역
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // 사용자 닉네임, 업로드/수정날짜 영역
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // 사용자 닉네임 영역
                                            CustomTextBuilder(
                                              text: '${replyData['child_list'][childReply]['nick']}',
                                              fontColor: ColorConfig().gray5(),
                                              fontSize: 12.0.sp,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            // 업로드/수정날짜 영역
                                            CustomTextBuilder(
                                              text: replyData['child_list'][childReply]['create_dt'] == replyData['child_list'][childReply]['modify_dt']
                                              ? DateCalculatorWrapper().daysCalculator(replyData['create_dt'])
                                              : '${DateCalculatorWrapper().daysCalculator(replyData['modify_dt'])} (수정됨)',
                                              fontColor: ColorConfig().gray3(),
                                              fontSize: 10.0.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // 대댓글 내용 영역
                                      CustomTextBuilder(
                                        text: '${replyData['child_list'][childReply]['content']}',
                                        fontColor: ColorConfig().gray5(),
                                        fontSize: 12.0.sp,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      // 좋아요, 신고 영역
                                      Container(
                                        margin: const EdgeInsets.only(top: 8.0),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                if (replyData['child_list'][childReply]['is_like'] == false) {
                                                  ReplyAddLikeAPI().replyAddLike(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), replyIndex: replyData['child_list'][childReply]['reply_index']).then((value) {
                                                    setState(() {
                                                      replyData['child_list'][childReply]['is_like'] = true;
                                                      replyData['child_list'][childReply]['like_count']++;
                                                    });
                                                  });
                                                } else {
                                                  ReplyCancelLikeAPI().replyCancelLike(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), replyIndex: replyData['child_list'][childReply]['reply_index']).then((value) {
                                                    setState(() {
                                                      replyData['child_list'][childReply]['is_like'] = false;
                                                      replyData['child_list'][childReply]['like_count']--;
                                                    });
                                                  });
                                                }
                                              },
                                              child: Row(
                                                children: [
                                                  Container(
                                                    margin: const EdgeInsets.only(right: 4.0),
                                                    child: SVGBuilder(
                                                      image: replyData['child_list'][childReply]['is_like'] == true ? 'assets/icon/heart-on-disabled-bg.svg' : 'assets/icon/heart-off-disabled-bg.svg',
                                                      width: 16.0.w,
                                                      height: 16.0.w,
                                                      color: ColorConfig().gray3(),
                                                    ),
                                                  ),
                                                  CustomTextBuilder(
                                                    text: '좋아요 ${replyData['child_list'][childReply]['like_count']}',
                                                    fontColor: ColorConfig().gray3(),
                                                    fontSize: 12.0.sp,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            replyData['child_list'][childReply]['is_mine'] == false ? Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                              child: CustomTextBuilder(
                                                text: '·',
                                                fontColor: ColorConfig().gray3(),
                                                fontSize: 12.0.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ) : Container(),
                                            // 신고 영역
                                            replyData['child_list'][childReply]['is_mine'] == false ? InkWell(
                                              onTap: () {
                                                reportTextController.clear();
                                                setState(() {
                                                  reportChecked = [false, false, false, false, false];
                                                });
                                                
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(4.0.r),
                                                  ),
                                                  builder: (context) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        if (reportFocusNode.hasFocus) {
                                                          reportFocusNode.unfocus();
                                                        }
                                                      },
                                                      child: StatefulBuilder(
                                                        builder: (context, state) {
                                                          return Container(
                                                            margin: EdgeInsets.only(bottom: reportFocusNode.hasFocus ? MediaQuery.of(context).viewInsets.bottom : 0.0),
                                                            child: SafeArea(
                                                              child: SingleChildScrollView(
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
                                                                                reportChecked = [false, false, false, false, false];
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
                                                                                          reportChecked = [false, false, false, false, false];
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
    
                                                                                            ReportReply().reportReply(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), replyIndex: replyData['reply_index'], type: reportChecked.indexOf(true), description: reportTextController.text).then((value) {
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
                                                                                ).ig-publicDialog(context);
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
                                                        }
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: CustomTextBuilder(
                                                text: '신고',
                                                fontColor: ColorConfig().gray3(),
                                                fontSize: 12.0.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ) : Container(),
                                            replyData['child_list'][childReply]['is_mine'] == true ? Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                              child: CustomTextBuilder(
                                                text: '·',
                                                fontColor: ColorConfig().gray3(),
                                                fontSize: 12.0.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ) : Container(),
                                            // 수정 영역
                                            replyData['child_list'][childReply]['is_mine'] == true ? InkWell(
                                              onTap: () {
                                                setState(() {
                                                  replyFocusNode.requestFocus();

                                                  replyTextController.text = replyData['child_list'][childReply]['content'];
                                                  onEdit = true;
                                                  editReplyIndex = replyData['child_list'][childReply]['reply_index'];
                                                  subreplyIndex = childReply;
                                                });
                                              },
                                              child: CustomTextBuilder(
                                                text: '수정',
                                                fontColor: ColorConfig().gray3(),
                                                fontSize: 12.0.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ) : Container(),
                                            replyData['child_list'][childReply]['is_mine'] == true ? Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                              child: CustomTextBuilder(
                                                text: '·',
                                                fontColor: ColorConfig().gray3(),
                                                fontSize: 12.0.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ) : Container(),
                                            // 삭제 영역
                                            replyData['child_list'][childReply]['is_mine'] == true ? InkWell(
                                              onTap: () {
                                                PopupBuilder(
                                                  title: TextConstant.deleteReplyTitle,
                                                  content: TextConstant.deleteReplyContent,
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
                      
                                                            ReplyDeleteAPI().replyDelete(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), replyIndex: replyData['child_list'][childReply]['reply_index']).then((value) {
                                                              if (value.result['status'] == 1) {
                                                                setState(() {
                                                                  replyData['child_list'].removeAt(childReply);
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
                                                ).ig-publicDialog(context);
                                              },
                                              child: CustomTextBuilder(
                                                text: '삭제',
                                                fontColor: ColorConfig().gray3(),
                                                fontSize: 12.0.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ) : Container(),
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
                      const SizedBox(height: 16.0),
                      // 영역이 가려지지 않도록 댓글입력폼 높이값만큼 더해줌
                      SizedBox(height: 16.0 + 16.0 + 36.0.w),
                    ],
                  ),
                ),
                // 댓글 입력폼 영역
                onEdit == false
                  ? Positioned(
                    bottom: 0.0,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: ColorConfig().white(),
                        border: Border(
                          top: BorderSide(
                            width: 1.0,
                            color: ColorConfig().gray2(),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // 프로필 이미지 영역
                          Container(
                            width: 36.0.w,
                            height: 36.0.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18.0.r),
                              image: myProfile['image'] != null
                                ? DecorationImage(
                                    image: NetworkImage(myProfile['image']),
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
                          // 댓글 입력폼 영역
                          Expanded(
                            child: TextFormField(
                              controller: replyTextController,
                              focusNode: replyFocusNode,
                              // maxLines: null,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(12.0),
                                // constraints: const BoxConstraints(
                                //   maxHeight: 100.0,
                                // ),
                                hintText: TextConstant.replyHintText,
                                hintStyle: TextStyle(
                                  color: ColorConfig().gray3(),
                                  fontSize: 14.0.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: TextStyle(
                                color: ColorConfig().dark(),
                                fontSize: 14.0.sp,
                                fontWeight: FontWeight.w700,
                              ),
                              // keyboardType: TextInputType.multiline,
                            ),
                          ),
                          // 등록버튼 영역
                          InkWell(
                            onTap: () async {
                              if (_debounce?.isActive ?? false) _debounce!.cancel();

                              _debounce = Timer(const Duration(milliseconds: 300), () async {
                                WriteReplyAPI().writeReply(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), communityIndex: replyData['community_index'], parentIndex: replyData['parent_index'], content: replyTextController.text).then((value) async {
                                  if (value.result['status'] == 1) {
                                    replyFocusNode.unfocus();
                                    replyTextController.clear();
        
                                    ReplyListAPI().replyList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), communityIndex: replyData['community_index']).then((value) {
                                      setState(() {
                                        for (int i=0; i<value.result['data'].length; i++) {
                                          if (value.result['data'][i]['reply_index'] == replyData['reply_index']) {
                                            replyData = value.result['data'][i];
                                          }
                                        }
                                      });
                                    });
                                  } else {
                                    ToastModel().iconToast(value.result['message'], iconType: 2);
                                  }
                                });
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                              decoration: BoxDecoration(
                                color: replyTextController.text.isNotEmpty ? ColorConfig().dark() : ColorConfig().gray2(),
                                borderRadius: BorderRadius.circular(4.0.r),
                              ),
                              child: CustomTextBuilder(
                                text: TextConstant.regist,
                                fontColor: replyTextController.text.isNotEmpty ? ColorConfig().white() : ColorConfig().gray3(),
                                fontSize: 13.0.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : Positioned(
                    bottom: 0.0,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
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
                                margin: onEdit == true ? const EdgeInsets.only(right: 8.0) : null,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18.0.r),
                                  image: myProfile['image'] != null
                                    ? DecorationImage(
                                        image: NetworkImage(myProfile['image']),
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
                              // 댓글 입력폼 영역
                              Expanded(
                                child: Container(
                                  constraints: BoxConstraints(
                                    maxHeight: onEdit == true ? 120.0 : double.infinity,
                                  ),
                                  child: TextFormField(
                                    controller: replyTextController,
                                    focusNode: replyFocusNode,
                                    maxLines: onEdit == true ? null : 1,
                                    expands: onEdit == true ? true : false,
                                    decoration: InputDecoration(
                                      isDense: onEdit == true ? true : false,
                                      isCollapsed: onEdit == true ? true : false,
                                      contentPadding: const EdgeInsets.all(12.0),
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
                                        borderSide: onEdit == true ? BorderSide(
                                          width: 1.0,
                                          color: ColorConfig().gray2(),
                                        ) : BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: onEdit == true ? BorderSide(
                                          width: 1.0,
                                          color: ColorConfig().gray2(),
                                        ) : BorderSide.none,
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: ColorConfig().dark(),
                                      fontSize: 14.0.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    keyboardType: onEdit == true ? TextInputType.multiline : null,
                                  ),
                                ),
                              ),
                              // 등록버튼 영역
                              onEdit == false ? InkWell(
                                onTap: () async {
                                  if (_debounce?.isActive ?? false) _debounce!.cancel();

                                  _debounce = Timer(const Duration(milliseconds: 300), () async {
                                    if (replyTextController.text.isNotEmpty) {
                                      WriteReplyAPI().writeReply(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), communityIndex: replyData['community_index'], parentIndex: replyData['parent_index'], content: replyTextController.text).then((value) async {
                                        if (value.result['status'] == 1) {
                                          replyFocusNode.unfocus();
                                          replyTextController.clear();
              
                                          ReplyListAPI().replyList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), communityIndex: replyData['community_index']).then((value) {
                                            setState(() {
                                              for (int i=0; i<value.result['data'].length; i++) {
                                                if (value.result['data'][i]['reply_index'] == replyData['reply_index']) {
                                                  replyData = value.result['data'][i];
                                                }
                                              }
                                            });
                                          });
                                        } else {
                                          ToastModel().iconToast(value.result['message'], iconType: 2);
                                        }
                                      });
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                  decoration: BoxDecoration(
                                    color: replyTextController.text.isNotEmpty ? ColorConfig().dark() : ColorConfig().gray2(),
                                    borderRadius: BorderRadius.circular(4.0.r),
                                  ),
                                  child: CustomTextBuilder(
                                    text: TextConstant.regist,
                                    fontColor: replyTextController.text.isNotEmpty ? ColorConfig().white() : ColorConfig().gray3(),
                                    fontSize: 13.0.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ) : Container(),
                            ],
                          ),
                          // 수정하기로 했을 때
                          onEdit == true ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    replyFocusNode.unfocus();
                                    replyTextController.clear();
                                    onEdit = false;
                                    editReplyIndex = -1;
                                    subreplyIndex = -1;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(top: 8.0, right: 8.0),
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                  decoration: BoxDecoration(
                                    color: ColorConfig().white(),
                                    border: Border.all(
                                      width: 1.0,
                                      color: ColorConfig().gray2(),
                                    ),
                                    borderRadius: BorderRadius.circular(4.0.r),
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
                                    if (replyTextController.text.isNotEmpty) {
                                      PatchReplyAPI().replyPatch(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), replyIndex: editReplyIndex, content: replyTextController.text).then((value) async {
                                        if (value.result['status'] == 1) {
                                          ReplyListAPI().replyList(accessToken: await SecureStorageConfig().storage.read(key: 'access_token'), communityIndex: replyData['community_index']).then((value) {
                                            setState(() {
                                              if (subreplyIndex != -1) {
                                                replyData['child_list'][subreplyIndex]['content'] = replyTextController.text;
                                              } else {
                                                replyData['content'] = replyTextController.text;
                                              }

                                              replyFocusNode.unfocus();
                                              replyTextController.clear();
                                              onEdit = false;
                                              editReplyIndex = -1;
                                              subreplyIndex = -1;
                                              replyRegistStatus = false;
                                            });
                                          });
                                        } else {
                                          ToastModel().iconToast(value.result['message'], iconType: 2);
                                        }
                                      });
                                    }
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(top: 8.0),
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                  decoration: BoxDecoration(
                                    color: replyTextController.text.isNotEmpty ? ColorConfig().dark() : ColorConfig().gray2(),
                                    borderRadius: BorderRadius.circular(4.0.r),
                                  ),
                                  child: CustomTextBuilder(
                                    text: TextConstant.regist,
                                    fontColor: replyTextController.text.isNotEmpty ? ColorConfig().white() : ColorConfig().gray3(),
                                    fontSize: 13.0.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ) : Container(),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ) : Container(),
      ),
    );
  }
}