import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/api/auth/email_login.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/iamport/certification.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/costant/build_config.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/main.dart';
import 'package:ig-public_v3/src/auth/component/bottom_widget.dart';
import 'package:ig-public_v3/util/toast.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  late TextEditingController idTextController;
  late TextEditingController passwordTextController;
  late FocusNode idFocusNode;
  late FocusNode passwordFocusNode;

  bool existIDCheck = false;
  bool matchPasswordCheck = false;
  bool idNullCheck = false;
  bool passwordNullCheck = false;

  @override
  void initState() {
    super.initState();

    idTextController = TextEditingController()..addListener(() {
      setState(() {
        idNullCheck = idTextController.text.trim().isNotEmpty ? true : false;
      });
    });
    passwordTextController = TextEditingController()..addListener(() {
      setState(() {
        passwordNullCheck = passwordTextController.text.trim().isNotEmpty ? true : false;
      });
    });

    idFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();

    idTextController.dispose();
    passwordTextController.dispose();
    idFocusNode.dispose();
    passwordFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (idFocusNode.hasFocus) {
          idFocusNode.unfocus();
        }

        if(passwordFocusNode.hasFocus) {
          passwordFocusNode.unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: ig-publicAppBar(
          leading: ig-publicAppBarLeading(
            press: () => Navigator.pop(context),
          ),
          title: const ig-publicAppBarTitle(
            title: TextConstant.loginByEmail,
          ),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          color: ColorConfig().white(),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                        child: TextFormField(
                          controller: idTextController,
                          focusNode: idFocusNode,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(' ')),
                          ],
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.5),
                            hintText: TextConstant.emailID,
                            hintStyle: TextStyle(
                              color: ColorConfig().gray3(),
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                            errorText: existIDCheck ? TextConstant.isNotExistID : null,
                            errorStyle: existIDCheck ? TextStyle(
                              color: ColorConfig().accent(),
                              fontSize: 12.0.sp,
                              fontWeight: FontWeight.w400,
                            ) : null,
                            errorBorder: existIDCheck ? UnderlineInputBorder(
                              borderSide: BorderSide(
                                width: 1.0,
                                color: ColorConfig().accent(),
                              ),
                            ) : null,
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                width: 1.0,
                                color: ColorConfig().primary(),
                              ),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                width: 1.0,
                                color: ColorConfig().gray3(),
                              ),
                            ),
                            suffixIcon: idNullCheck ? InkWell(
                              onTap: () {
                                idTextController.clear();
                              },
                              child: SVGBuilder(
                                image: 'assets/icon/close_normal.svg',
                                width: 16.0.w,
                                height: 16.0.w,
                                color: ColorConfig().gray3(),
                              ),
                            ) : null,
                            suffixIconConstraints: BoxConstraints(
                              maxWidth: 16.0.w,
                              maxHeight: 16.0.w,
                            ),
                          ),
                          style: TextStyle(
                            color: !existIDCheck ? ColorConfig().dark() : ColorConfig().accent(),
                            fontSize: 14.0.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          cursorColor: ColorConfig().primary(),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                        child: TextFormField(
                          controller: passwordTextController,
                          focusNode: passwordFocusNode,
                          obscureText: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(' ')),
                          ],
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.5),
                            hintText: TextConstant.password,
                            hintStyle: TextStyle(
                              color: ColorConfig().gray3(),
                              fontSize: 14.0.sp,
                              fontWeight: FontWeight.w700,
                            ),
                            errorText: matchPasswordCheck ? TextConstant.isNotMatchPassword : null,
                            errorStyle: matchPasswordCheck ? TextStyle(
                              color: ColorConfig().accent(),
                              fontSize: 12.0.sp,
                              fontWeight: FontWeight.w400,
                            ) : null,
                            errorBorder: matchPasswordCheck ? UnderlineInputBorder(
                              borderSide: BorderSide(
                                width: 1.0,
                                color: ColorConfig().accent(),
                              ),
                            ) : null,
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                width: 1.0,
                                color: ColorConfig().primary(),
                              ),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                width: 1.0,
                                color: ColorConfig().gray3(),
                              ),
                            ),
                            suffixIcon: passwordNullCheck ? InkWell(
                              onTap: () {
                                passwordTextController.clear();
                              },
                              child: SVGBuilder(
                                image: 'assets/icon/close_normal.svg',
                                width: 16.0.w,
                                height: 16.0.w,
                                color: ColorConfig().gray3(),
                              ),
                            ) : null,
                            suffixIconConstraints: BoxConstraints(
                              maxWidth: 16.0.w,
                              maxHeight: 16.0.w,
                            ),
                          ),
                          style: TextStyle(
                            color: !matchPasswordCheck ? ColorConfig().dark() : ColorConfig().accent(),
                            fontSize: 14.0.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          cursorColor: ColorConfig().primary(),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      const SizedBox(height: 24.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: InkWell(
                          onTap: () async {
                            if (idTextController.text.isNotEmpty && passwordTextController.text.isNotEmpty) {  
                              String? fcmToken = await SecureStorageConfig().storage.read(key: 'fcm_token');

                              EmailLoginAPI().login(email: idTextController.text, password: passwordTextController.text, fcmToken: fcmToken!).then((value) {
                                if (value.result['access_token'] != null && value.result['refresh_token'] != null) {
                                  Future.wait([
                                    SecureStorageConfig().storage.write(key: 'is_auth', value: '${value.result['is_auth']}'),
                                    SecureStorageConfig().storage.write(key: 'access_token', value: value.result['access_token']),
                                    SecureStorageConfig().storage.write(key: 'refresh_token', value: value.result['refresh_token']),
                                    SecureStorageConfig().storage.write(key: 'token_status', value: 'false'),
                                    SecureStorageConfig().storage.write(key: 'login_type', value: 'google'),
                                  ]).then((_) {
                                    if (value.result['is_auth'] == 0) {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PhoneCertification()));
                                    } else {
                                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainBuilder()), (route) => false);
                                    }
                                  });
                                } else {
                                  ToastModel().iconToast(value.result['message'], iconType: 2);

                                  setState(() {
                                    existIDCheck = false;
                                    matchPasswordCheck = false;
                                  });
                                }
                              });
                            } else {
                              setState(() {
                                existIDCheck = false;
                                matchPasswordCheck = false;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16.5),
                            decoration: BoxDecoration(
                              color: ColorConfig().dark(),
                              borderRadius: BorderRadius.circular(4.0.r),
                            ),
                            child: Center(
                              child: CustomTextBuilder(
                                text: TextConstant.loginByEmail1,
                                fontColor: ColorConfig().white(),
                                fontSize: 14.0.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SignupORFindPassword(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}