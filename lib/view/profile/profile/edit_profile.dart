import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/api/profile/edit_profile.dart';
import 'package:ig-public_v3/api/profile/withdrawal.dart';
import 'package:ig-public_v3/component/popup/popup.dart';
import 'package:ig-public_v3/costant/build_config.dart';

import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/image_picker/image_picker.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/src/auth/login.dart';
import 'package:ig-public_v3/src/route_argument.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nicknameController;
  late TextEditingController descriptionController;
  late FocusNode nicknameFocusNode;
  late FocusNode descriptionFocusNode;

  dynamic backgroundImage;
  dynamic profileImage;

  bool dragPositionStatus = false;
  bool smsMarketing = false;
  bool emailMarketing = false;

  Map<String, dynamic> profileInfo = {};

  @override
  void initState() {
    super.initState();

    nicknameController = TextEditingController()..addListener(() {
      setState(() {});
    });
    descriptionController = TextEditingController()..addListener(() {
      setState(() {});
    });

    nicknameFocusNode = FocusNode();
    descriptionFocusNode = FocusNode();

    Future.delayed(Duration.zero, () {
      if (RouteGetArguments().getArgs(context)['profile_info'] != null) {
        setState(() {
          profileInfo = RouteGetArguments().getArgs(context)['profile_info'];

          if (profileInfo['description'] == null) {
            profileInfo['description'] = '';
          }
        });
      }
    }).then((_) {
      setState(() {
        nicknameController.text = profileInfo['nick'];
        descriptionController.text = profileInfo['description'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onHorizontalDragDown: (details) {
          if (details.localPosition.dx < 30.0) {
            setState(() {
              dragPositionStatus = true;
            });
          }
        },
        onHorizontalDragUpdate: dragPositionStatus == true ? (details) {
          if(details.primaryDelta! < 0) {
            // drag from right to left
          } else {
            // drag from left to right
            if (details.delta.dx > 2.5) {
              Navigator.pop(context, profileInfo);
            }
          }
        } : null,
        onTap: () {
          if (nicknameFocusNode.hasFocus) {
            nicknameFocusNode.unfocus();
          }
    
          if (descriptionFocusNode.hasFocus) {
            descriptionFocusNode.unfocus();
          }
        },
        child: Scaffold(
          appBar: ig-publicAppBar(
            leading: ig-publicAppBarLeading(
              press: () {
                Navigator.pop(context, profileInfo);
              }
            ),
            title: const ig-publicAppBarTitle(
              title: TextConstant.editProfile,
            ),
            actions: [
              TextButton(
                onPressed: nicknameController.text != profileInfo['nick'] || (descriptionController.text != profileInfo['description']) ? () async {
                  EditProfileAPI().edit(
                    accessToken: await SecureStorageConfig().storage.read(key: 'access_token'),
                    nickname: nicknameController.text,
                    description: descriptionController.text,
                    backgroundImage: backgroundImage,
                    profileImage: profileImage,
                    sms: 0,
                    email: 0,
                  ).then((value) {
                    setState(() {
                      profileInfo['nick'] = value.result['data']['nick'];
                      profileInfo['image'] = value.result['data']['profile'];
                      profileInfo['background'] = value.result['data']['background'];
                      profileInfo['description'] = value.result['data']['description'];
                      profileInfo['agreement_sms'] = value.result['data']['sms'];
                      profileInfo['agreement_email'] = value.result['data']['email'];

                      Navigator.pop(context, profileInfo);
                    });
                  });
                } : null,
                child: CustomTextBuilder(
                  text: TextConstant.change,
                  fontColor: nicknameController.text != profileInfo['nick'] || (descriptionController.text != profileInfo['description']) ? ColorConfig().primary() : ColorConfig().gray3(),
                  fontSize: 12.0.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: ColorConfig().gray1(),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 배경이미지, 프로필 이미지, 닉네임, 자기소개 영역
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 386.0.w,
                      margin: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                      decoration: BoxDecoration(
                        color: backgroundImage == null ? ColorConfig().gray2() : null,
                        image: backgroundImage != null
                          ? DecorationImage(
                              image: FileImage(File(backgroundImage)),
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.high,
                            )
                          : profileInfo['background'] != null
                            ? DecorationImage(
                                image: NetworkImage(profileInfo['background']),
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                              )
                            : null,
                      ),
                      child: Stack(
                        children: [
                          Container(
                            color: ColorConfig().overlay(opacity: 0.8),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    // 프로필 이미지 영역
                                    InkWell(
                                      onTap: () {
                                        ImagePickerSelector().imagePicker().then((img) {
                                          setState(() {
                                            profileImage = img.path;
                                          });
                                        });
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 96.0.w,
                                            height: 96.0.w,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(48.0.r),
                                              image: profileImage == null
                                              ? profileInfo['image'] != null
                                                ? DecorationImage(
                                                    image: NetworkImage(profileInfo['image']),
                                                    fit: BoxFit.cover,
                                                    filterQuality: FilterQuality.high,
                                                  )
                                                : const DecorationImage(
                                                    image: AssetImage('assets/img/profile_default.png'),
                                                    fit: BoxFit.cover,
                                                    filterQuality: FilterQuality.high,
                                                  )
                                              : DecorationImage(
                                                  image: FileImage(File(profileImage)),
                                                  fit: BoxFit.cover,
                                                  filterQuality: FilterQuality.high,
                                                ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 0.0,
                                            right: 0.0,
                                            child: Container(
                                              width: 28.0.w,
                                              height: 28.0.w,
                                              decoration: BoxDecoration(
                                                color: ColorConfig().white(),
                                                borderRadius: BorderRadius.circular(14.0.r),
                                                boxShadow: [
                                                  BoxShadow(
                                                    offset: const Offset(-1.0, 0.0),
                                                    color: ColorConfig().overlay(opacity: 0.16),
                                                    blurRadius: 4.0,
                                                  ),
                                                ],
                                              ),
                                              child: Center(
                                                child: SVGBuilder(
                                                  image: 'assets/icon/edit.svg',
                                                  width: 16.0.w,
                                                  height: 16.0.w,
                                                  color: ColorConfig().dark(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // 닉네임 영역
                                    Container(
                                      margin: EdgeInsets.only(top: 24.0.w),
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                      child: TextFormField(
                                        controller: nicknameController,
                                        focusNode: nicknameFocusNode,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0.w),
                                          hintText: TextConstant.nickname,
                                          hintStyle: TextStyle(
                                            color: ColorConfig().gray3(),
                                            fontSize: 16.0.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              width: 1.0,
                                              color: ColorConfig().white(),
                                            ),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              width: 1.0,
                                              color: ColorConfig().gray3(),
                                            ),
                                          ),
                                          suffixIcon: InkWell(
                                            onTap: () {
                                              // emailTextController.clear();
                                            },
                                            child: SVGBuilder(
                                              image: 'assets/icon/edit.svg',
                                              width: 16.0.w,
                                              height: 16.0.w,
                                              color: ColorConfig().white(),
                                            ),
                                          ),
                                          suffixIconConstraints: BoxConstraints(
                                            maxWidth: 16.0.w,
                                            maxHeight: 16.0.w,
                                          ),
                                        ),
                                        style: TextStyle(
                                          color: ColorConfig().white(),
                                          fontSize: 16.0.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        cursorColor: ColorConfig().white(),
                                        keyboardType: TextInputType.text,
                                      ),
                                    ),
                                    // 자기소개 영역
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                      child: TextFormField(
                                        controller: descriptionController,
                                        focusNode: descriptionFocusNode,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0.w),
                                          // counterText: '',
                                          counterStyle: TextStyle(
                                            color: ColorConfig().white(),
                                            fontSize: 12.0.sp,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          hintText: TextConstant.selfIntroducePlaceholder,
                                          hintStyle: TextStyle(
                                            color: ColorConfig().gray3(),
                                            fontSize: 12.0.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          hintMaxLines: 2,
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              width: 1.0,
                                              color: ColorConfig().white(),
                                            ),
                                          ),
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              width: 1.0,
                                              color: ColorConfig().gray3(),
                                            ),
                                          ),
                                          suffixIcon: InkWell(
                                            onTap: () {
                                              // emailTextController.clear();
                                            },
                                            child: SVGBuilder(
                                              image: 'assets/icon/edit.svg',
                                              width: 16.0.w,
                                              height: 16.0.w,
                                              color: ColorConfig().white(),
                                            ),
                                          ),
                                          suffixIconConstraints: BoxConstraints(
                                            maxWidth: 16.0.w,
                                            maxHeight: 16.0.w,
                                          ),
                                        ),
                                        style: TextStyle(
                                          color: ColorConfig().white(),
                                          fontSize: 12.0.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 2,
                                        maxLength: 35,
                                        cursorColor: ColorConfig().white(),
                                        keyboardType: TextInputType.text,
                                      ),
                                    ),
                                    // 배경이미지 변경 버튼 영역
                                    TextButton(
                                      style: ButtonStyle(
                                        overlayColor: MaterialStateProperty.all(ColorConfig.transparent),
                                        foregroundColor: MaterialStateProperty.all(ColorConfig.transparent),
                                        padding: MaterialStateProperty.all(EdgeInsets.all(12.0.w)),
                                      ),
                                      onPressed: () {
                                        ImagePickerSelector().imagePicker().then((img) {
                                          setState(() {
                                            backgroundImage = img.path;
                                          });
                                        });
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CustomTextBuilder(
                                            text: TextConstant.changeBackgroundImage,
                                            fontColor: ColorConfig().white(),
                                            fontSize: 14.0.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(left: 4.0),
                                            child: SVGBuilder(
                                              image: 'assets/icon/album.svg',
                                              width: 16.0.w,
                                              height: 16.0.w,
                                              color: ColorConfig().white(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    // 이메일 아이디 영역
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: ColorConfig().white(),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomTextBuilder(
                            text: TextConstant.emailID,
                            fontColor: ColorConfig().dark(),
                            fontSize: 14.0.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          CustomTextBuilder(
                            text: '${profileInfo['email']}',
                            fontColor: ColorConfig().gray5(),
                            fontSize: 14.0.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ],
                      ),
                    ),
                    // 마케팅 정보 수신 및 활용 동의 영역
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: ColorConfig().white(),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 4.0),
                            child: CustomTextBuilder(
                              text: TextConstant.marketingInfoAgreementTitle,
                              fontColor: ColorConfig().dark(),
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          CustomTextBuilder(
                            text: TextConstant.marketingInfoAgreementDescription,
                            fontColor: ColorConfig().gray5(),
                            fontSize: 12.0.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                          ),
                        ],
                      ),
                    ),
                    // 문자메시지 체크박스 영역
                    InkWell(
                      onTap: () {
                        setState(() {
                          smsMarketing = !smsMarketing;
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: ColorConfig().white(),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 24.0.w,
                              height: 24.0.w,
                              margin: const EdgeInsets.only(right: 16.0),
                              child: Checkbox(
                                value: smsMarketing,
                                activeColor: ColorConfig().primary(),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3.0.r),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    smsMarketing = value!;
                                  });
                                },
                              ),
                            ),
                            CustomTextBuilder(
                              text: TextConstant.smsMarketing,
                              fontColor: ColorConfig().dark(),
                              fontSize: 12.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 이메일 체크박스 영역
                    InkWell(
                      onTap: () {
                        setState(() {
                          emailMarketing = !emailMarketing;
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: ColorConfig().white(),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 24.0.w,
                              height: 24.0.w,
                              margin: const EdgeInsets.only(right: 16.0),
                              child: Checkbox(
                                value: emailMarketing,
                                activeColor: ColorConfig().primary(),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3.0.r),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    emailMarketing = value!;
                                  });
                                },
                              ),
                            ),
                            CustomTextBuilder(
                              text: TextConstant.emailMarketing,
                              fontColor: ColorConfig().dark(),
                              fontSize: 12.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 마케팅 정보 수신 및 활용 동의 안내문구 영역
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: ColorConfig().white(),
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 4.0.w,
                            height: 4.0.w,
                            margin: const EdgeInsets.only(right: 10.0),
                            decoration: BoxDecoration(
                              color: ColorConfig().gray5(),
                              borderRadius: BorderRadius.circular(4.0.r),
                            ),
                          ),
                          Expanded(
                            child: CustomTextBuilder(
                              text: TextConstant.marketingInfoAgreementText,
                              fontColor: ColorConfig().gray5(),
                              fontSize: 12.0.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 8.0,
                      color: ColorConfig().white(),
                    ),
                    const SizedBox(height: 8.0),
                    // 로그아웃 영역
                    InkWell(
                      onTap: () {
                        PopupBuilder(
                          title: TextConstant.logout,
                          content: TextConstant.logoutContent,
                          actions: [
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    width: (MediaQuery.of(context).size.width - 120.0.w) / 2,
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    margin: const EdgeInsets.only(right: 8.0),
                                    decoration: BoxDecoration(
                                      color: ColorConfig().white(),
                                      border: Border.all(
                                        width: 1.0,
                                        color: ColorConfig().gray3(),
                                      ),
                                      borderRadius: BorderRadius.circular(4.0.r),
                                    ),
                                    child: Center(
                                      child: CustomTextBuilder(
                                        text: TextConstant.cancel,
                                        fontColor: ColorConfig().dark(),
                                        fontSize: 14.0.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    Navigator.pop(context);

                                    await SecureStorageConfig().storage.delete(key: 'login_type');
                                    await SecureStorageConfig().storage.delete(key: 'token_status');
                                    await SecureStorageConfig().storage.delete(key: 'access_token');
                                    await SecureStorageConfig().storage.delete(key: 'refresh_token');
                                    await SecureStorageConfig().storage.delete(key: 'is_auth');

                                    // ignore: use_build_context_synchronously
                                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const ig-publicLoginScreen()), (route) => false);
                                  },
                                  child: Container(
                                    width: (MediaQuery.of(context).size.width - 120.0.w) / 2,
                                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                                    decoration: BoxDecoration(
                                      color: ColorConfig().accent(),
                                      borderRadius: BorderRadius.circular(4.0.r),
                                    ),
                                    child: Center(
                                      child: CustomTextBuilder(
                                        text: TextConstant.logout,
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
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: ColorConfig().white(),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomTextBuilder(
                              text: TextConstant.logout,
                              fontColor: ColorConfig().dark(),
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                            SVGBuilder(
                              image: 'assets/icon/arrow_right_light.svg',
                              width: 20.0.w,
                              height: 20.0.w,
                              color: ColorConfig().gray3(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // 회원탈퇴 영역
                    InkWell(
                      onTap: () {
                        PopupBuilder(
                          title: TextConstant.withdrawalPopupTitle,
                          content: TextConstant.withdrawalPopupDescription,
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
                                        text: TextConstant.cancel,
                                        fontColor: ColorConfig().white(),
                                        fontSize: 14.0.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () async {
                                    WithDrawalAPI().withdrawal(accessToken: await SecureStorageConfig().storage.read(key: 'access_token')).then((value) async {
                                      if (value.result['status'] == 1) {
                                        await SecureStorageConfig().storage.deleteAll();

                                        // ignore: use_build_context_synchronously
                                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const ig-publicLoginScreen()), (route) => false);
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
                                        text: TextConstant.withdrawal,
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
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: ColorConfig().white(),
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomTextBuilder(
                              text: TextConstant.withdrawal,
                              fontColor: ColorConfig().dark(),
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                            SVGBuilder(
                              image: 'assets/icon/arrow_right_light.svg',
                              width: 20.0.w,
                              height: 20.0.w,
                              color: ColorConfig().gray3(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40.0),
                  ],
                ),
              )
            ),
          ),
        ),
      ),
    );
  }
}