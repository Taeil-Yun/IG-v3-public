import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/src/auth/service_access_permission.dart';
import 'package:ig-public_v3/util/url_launcher.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';

class SignupTermsScreen extends StatefulWidget {
  SignupTermsScreen({
    super.key,
    required this.email,
    required this.password,
  });

  String email;
  String password;

  @override
  State<SignupTermsScreen> createState() => _SignupTermsScreenState();
}

class _SignupTermsScreenState extends State<SignupTermsScreen> {
  bool allChecked = false;
  bool marketingChecked = false;

  List<bool> servicesCheck = [false, false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ig-publicAppBar(
        leading: ig-publicAppBarLeading(
          press: () => Navigator.pop(context),
        ),
        title: const ig-publicAppBarTitle(
          title: TextConstant.terms,
        ),
      ),
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: ColorConfig().white(),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 24.0),
                      // 안내 텍스트
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.only(bottom: 16.0),
                        padding:
                            const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 6.0),
                        child: CustomTextBuilder(
                          text: TextConstant.signTermsDescription,
                          fontColor: ColorConfig().dark(),
                          fontSize: 14.0.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      // 모두 확인 체크박스
                      InkWell(
                        onTap: () {
                          setState(() {
                            allChecked = !allChecked;
                            marketingChecked = allChecked;

                            for (int i = 0; i < servicesCheck.length; i++) {
                              servicesCheck[i] = allChecked;
                            }
                          });
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 12.0),
                          child: Row(
                            children: [
                              Container(
                                width: 24.0.w,
                                height: 24.0.w,
                                margin: const EdgeInsets.only(right: 16.0),
                                child: Checkbox(
                                  activeColor: ColorConfig().primary(),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(100.0.r),
                                  ),
                                  value: allChecked,
                                  onChanged: (allCheck) {
                                    allChecked = allCheck!;
                                  },
                                ),
                              ),
                              Expanded(
                                child: CustomTextBuilder(
                                  text: TextConstant.signupTermsAllCheck,
                                  fontColor: ColorConfig().dark(),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 약관 리스트 (필수값)
                      Column(
                        children:
                            List.generate(servicesCheck.length, (checkIndex) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                servicesCheck[checkIndex] =
                                    !servicesCheck[checkIndex];
                              });
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 12.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        margin:
                                            const EdgeInsets.only(right: 16.0),
                                        child: SVGBuilder(
                                          image: 'assets/icon/check.svg',
                                          width: 24.0.w,
                                          height: 24.0.w,
                                          color:
                                              servicesCheck[checkIndex] == false
                                                  ? ColorConfig().gray2()
                                                  : ColorConfig().dark(),
                                        ),
                                      ),
                                      CustomTextBuilder(
                                        text: TextConstant
                                            .signupTermsList[checkIndex],
                                        fontColor: ColorConfig().dark(),
                                        fontSize: 12.0.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ],
                                  ),
                                  checkIndex != servicesCheck.length - 1
                                      ? InkWell(
                                          onTap: () {
                                            UrlLauncherBuilder().launchURL(checkIndex ==
                                                    0
                                                ? 'https://c.ig-public.link/document/terms-of-service.html'
                                                : checkIndex == 1
                                                    ? 'https://c.ig-public.link/document/privacy-policy.html'
                                                    : 'https://c.ig-public.link/document/third-party.html');
                                          },
                                          child: CustomTextBuilder(
                                            text: TextConstant.details,
                                            fontColor: ColorConfig().dark(),
                                            fontSize: 12.0.sp,
                                            fontWeight: FontWeight.w700,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      // 마케팅 정보 수신 및 활용 동의 체크박스 영역
                      InkWell(
                        onTap: () {
                          setState(() {
                            marketingChecked = !marketingChecked;
                          });
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 12.0),
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 16.0),
                                child: SVGBuilder(
                                  image: 'assets/icon/check.svg',
                                  width: 24.0.w,
                                  height: 24.0.w,
                                  color: marketingChecked == false
                                      ? ColorConfig().gray2()
                                      : ColorConfig().dark(),
                                ),
                              ),
                              Expanded(
                                child: CustomTextBuilder(
                                  text: TextConstant.signupMarketingTerms,
                                  fontColor: ColorConfig().dark(),
                                  fontSize: 12.0.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 48.0),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 12.0),
                child: InkWell(
                  onTap: () {
                    if (allChecked == true ||
                        (servicesCheck[0] == true &&
                            servicesCheck[1] == true &&
                            servicesCheck[2] == true &&
                            servicesCheck[3] == true)) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceAccessPermissionScreen(
                                email: widget.email,
                                password: widget.password,
                                isMarketing: marketingChecked == true ? 1 : 0),
                          ));
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18.0),
                    decoration: BoxDecoration(
                      color: allChecked == true ||
                              (servicesCheck[0] == true &&
                                  servicesCheck[1] == true &&
                                  servicesCheck[2] == true &&
                                  servicesCheck[3] == true)
                          ? ColorConfig().primary()
                          : ColorConfig().gray2(),
                      borderRadius: BorderRadius.circular(4.0.r),
                    ),
                    child: Center(
                      child: CustomTextBuilder(
                        text: TextConstant.next,
                        fontColor: allChecked == true ||
                                (servicesCheck[0] == true &&
                                    servicesCheck[1] == true &&
                                    servicesCheck[2] == true &&
                                    servicesCheck[3] == true)
                            ? ColorConfig().white()
                            : ColorConfig().gray3(),
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
    );
  }
}
