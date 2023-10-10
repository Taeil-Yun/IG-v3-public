import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  late TextEditingController resetPasswordTextController;
  late TextEditingController resetPasswordCheckTextController;
  late FocusNode resetPasswordFocusNode;
  late FocusNode resetPasswordCheckFocusNode;

  bool resetPasswordObscure = true;
  bool resetPasswordCheckObscure = true;

  @override
  void initState() {
    super.initState();

    resetPasswordTextController = TextEditingController();
    resetPasswordCheckTextController = TextEditingController();
    resetPasswordFocusNode = FocusNode();
    resetPasswordCheckFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();

    resetPasswordTextController.dispose();
    resetPasswordCheckTextController.dispose();
    resetPasswordFocusNode.dispose();
    resetPasswordCheckFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (resetPasswordFocusNode.hasFocus) {
          resetPasswordFocusNode.unfocus();
        }

        if (resetPasswordCheckFocusNode.hasFocus) {
          resetPasswordCheckFocusNode.unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: ig-publicAppBar(
          leading: ig-publicAppBarLeading(
            press: () => Navigator.pop(context),
          ),
          title: const ig-publicAppBarTitle(
            title: TextConstant.resetPassword,
          ),
        ),
        body: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: ColorConfig().white(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(
                  flex: 1,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: CustomTextBuilder(
                    text: TextConstant.changePassword,
                    fontColor: ColorConfig().dark(),
                    fontSize: 18.0.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  margin: const EdgeInsets.only(top: 20.0),
                  child: CustomTextBuilder(
                    text: TextConstant.changePasswordDescription,
                    fontColor: ColorConfig().gray5(),
                    fontSize: 14.0.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: TextFormField(
                    controller: resetPasswordTextController,
                    focusNode: resetPasswordFocusNode,
                    obscureText: resetPasswordObscure,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.5),
                      hintText: TextConstant.inputNewPassword,
                      hintStyle: TextStyle(
                        color: ColorConfig().gray3(),
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w700,
                      ),
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
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            resetPasswordObscure = !resetPasswordObscure;
                          });
                        },
                        icon: SVGBuilder(
                          image: resetPasswordObscure == true ? 'assets/icon/state=hide.svg' : 'assets/icon/state=show.svg',
                          width: 16.0.w,
                          height: 16.0.w,
                          color: ColorConfig().gray5(),
                        ),
                      ),
                    ),
                    style: TextStyle(
                      color: ColorConfig().dark(),
                      fontSize: 14.0.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    cursorColor: ColorConfig().primary(),
                    keyboardType: TextInputType.text,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: TextFormField(
                    controller: resetPasswordCheckTextController,
                    focusNode: resetPasswordCheckFocusNode,
                    obscureText: resetPasswordObscure,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.5),
                      hintText: TextConstant.checkNewPassword,
                      hintStyle: TextStyle(
                        color: ColorConfig().gray3(),
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w700,
                      ),
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
                      suffixIcon: SVGBuilder(
                        image: resetPasswordCheckObscure == true ? 'assets/icon/state=hide.svg' : 'assets/icon/state=show.svg',
                        width: 16.0.w,
                        height: 16.0.w,
                        color: ColorConfig.transparent,
                      ),
                    ),
                    style: TextStyle(
                      color: ColorConfig().dark(),
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
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16.5),
                      decoration: BoxDecoration(
                        color: ColorConfig().dark(),
                        borderRadius: BorderRadius.circular(4.0.r),
                      ),
                      child: Center(
                        child: CustomTextBuilder(
                          text: TextConstant.changing,
                          fontColor: ColorConfig().white(),
                          fontSize: 14.0.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(
                  flex: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}