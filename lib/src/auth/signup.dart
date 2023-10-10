import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/api/auth/email_check.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';

import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/src/auth/sign_terms.dart';
import 'package:ig-public_v3/util/toast.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late TextEditingController emailTextController;
  late TextEditingController passwordTextController;
  late TextEditingController passwordCheckTextController;
  late FocusNode emailFocusNode;
  late FocusNode passwordFocusNode;
  late FocusNode passwordCheckFocusNode;

  @override
  void initState() {
    super.initState();

    emailTextController = TextEditingController()..addListener(() {
      setState(() {});
    });
    passwordTextController = TextEditingController()..addListener(() {
      setState(() {});
    });
    passwordCheckTextController = TextEditingController()..addListener(() {
      setState(() {});
    });

    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    passwordCheckFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool isValidEmailFormat(String email) {
    return email.isNotEmpty && RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (emailFocusNode.hasFocus) {
          emailFocusNode.unfocus();
        }

        if (passwordFocusNode.hasFocus) {
          passwordFocusNode.unfocus();
        }

        if (passwordCheckFocusNode.hasFocus) {
          passwordCheckFocusNode.unfocus();
        }
      },
      child: Scaffold(
        appBar: ig-publicAppBar(
          leading: ig-publicAppBarLeading(
            press: () => Navigator.pop(context),
          ),
          title: const ig-publicAppBarTitle(
            title: TextConstant.registMemberInfo,
          ),
        ),
        body: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: ColorConfig().white(),
            child: Column(
              children: [
                const Spacer(
                  flex: 1,
                ),
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // 아이디 정보 텍스트 영역
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                          child: CustomTextBuilder(
                            text: TextConstant.idInfo,
                            fontColor: ColorConfig().dark(),
                            fontSize: 14.0.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        // 이메일 입력폼 영역
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          child: TextFormField(
                            controller: emailTextController,
                            focusNode: emailFocusNode,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(' ')),
                            ],
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                              hintText: TextConstant.emailID,
                              hintStyle: TextStyle(
                                color: ColorConfig().gray3(),
                                fontSize: 14.0.sp,
                                fontWeight: FontWeight.w700,
                              ),
                              errorText: emailTextController.text.isNotEmpty && isValidEmailFormat(emailTextController.text) == false ? TextConstant.emailRegExpErrorText : null,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1.0,
                                  color: emailTextController.text.isNotEmpty ? ColorConfig().dark() : ColorConfig().gray3(),
                                ),
                              ),
                              suffixIcon: emailTextController.text.isNotEmpty ? IconButton(
                                onPressed: () {
                                  emailTextController.clear();
                                },
                                icon: SVGBuilder(
                                  image: 'assets/icon/close_normal.svg',
                                  width: 16.0.w,
                                  height: 16.0.w,
                                  color: ColorConfig().gray3(),
                                ),
                              ) : null,
                            ),
                            style: TextStyle(
                              color: ColorConfig().dark(),
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        // 비밀번호 입력폼 영역
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          child: TextFormField(
                            controller: passwordTextController,
                            focusNode: passwordFocusNode,
                            obscureText: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(' ')),
                            ],
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                              hintText: '${TextConstant.password} (8자리 이상)',
                              hintStyle: TextStyle(
                                color: ColorConfig().gray3(),
                                fontSize: 14.0.sp,
                                fontWeight: FontWeight.w700,
                              ),
                              errorText: passwordTextController.text.isNotEmpty && passwordTextController.text.length < 8 ? '비밀번호를 8자리 이상 입력해주세요' : null,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1.0,
                                  color: passwordTextController.text.isNotEmpty ? ColorConfig().dark() : ColorConfig().gray3(),
                                ),
                              ),
                              suffixIcon: passwordTextController.text.isNotEmpty ? IconButton(
                                onPressed: () {
                                  passwordTextController.clear();
                                },
                                icon: SVGBuilder(
                                  image: 'assets/icon/close_normal.svg',
                                  width: 16.0.w,
                                  height: 16.0.w,
                                  color: ColorConfig().gray3(),
                                ),
                              ) : null,
                            ),
                            style: TextStyle(
                              color: ColorConfig().dark(),
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        // 비밀번호 확인 입력폼 영역
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          child: TextFormField(
                            controller: passwordCheckTextController,
                            focusNode: passwordCheckFocusNode,
                            obscureText: true,
                            inputFormatters: [
                              FilteringTextInputFormatter.deny(RegExp(' ')),
                            ],
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                              hintText: TextConstant.passwordCheck,
                              hintStyle: TextStyle(
                                color: ColorConfig().gray3(),
                                fontSize: 14.0.sp,
                                fontWeight: FontWeight.w700,
                              ),
                              errorText: passwordCheckTextController.text.isNotEmpty && passwordCheckTextController.text != passwordTextController.text ? '비밀번호가 일치하지 않습니다.' : null,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1.0,
                                  color: passwordCheckTextController.text.isNotEmpty ? ColorConfig().dark() : ColorConfig().gray3(),
                                ),
                              ),
                              suffixIcon: passwordCheckTextController.text.isNotEmpty ? IconButton(
                                onPressed: () {
                                  passwordCheckTextController.clear();
                                },
                                icon: SVGBuilder(
                                  image: 'assets/icon/close_normal.svg',
                                  width: 16.0.w,
                                  height: 16.0.w,
                                  color: ColorConfig().gray3(),
                                ),
                              ) : null,
                            ),
                            style: TextStyle(
                              color: ColorConfig().dark(),
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: InkWell(
                    onTap: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => PhoneCertification(),));
                      if (isValidEmailFormat(emailTextController.text) == true && passwordTextController.text.length >= 6 && passwordCheckTextController.text == passwordTextController.text) {
                        EmailCheckAPI().emailCheck(email: emailTextController.text).then((value) {
                          if (value.result['status'] == 1) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SignupTermsScreen(email: emailTextController.text, password: passwordTextController.text)));
                          } else {
                            ToastModel().iconToast(value.result['message'], iconType: 2);
                          }
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      decoration: BoxDecoration(
                        color: isValidEmailFormat(emailTextController.text) == true && passwordTextController.text.length >= 6 && passwordCheckTextController.text == passwordTextController.text ? ColorConfig().primary() : ColorConfig().gray2(),
                        borderRadius: BorderRadius.circular(4.0.r),
                      ),
                      child: Center(
                        child: CustomTextBuilder(
                          text: TextConstant.next,
                          fontColor: isValidEmailFormat(emailTextController.text) == true && passwordTextController.text.length >= 6 && passwordCheckTextController.text == passwordTextController.text ? ColorConfig().white() : ColorConfig().gray3(),
                          fontSize: 16.0.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}