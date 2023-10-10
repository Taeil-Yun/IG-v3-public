import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/component/appbar/appbar.dart';
import 'package:ig-public_v3/component/appbar/appbar_leading.dart';
import 'package:ig-public_v3/component/appbar/appbar_title.dart';
import 'package:ig-public_v3/component/svg/svg_builder.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';

class FindPasswordScreen extends StatefulWidget {
  const FindPasswordScreen({super.key});

  @override
  State<FindPasswordScreen> createState() => _FindPasswordScreenState();
}

class _FindPasswordScreenState extends State<FindPasswordScreen> {
  late TextEditingController emailTextController;
  late FocusNode emailFocusNode;

  bool emailNullCheck = false;

  @override
  void initState() {
    super.initState();

    emailTextController = TextEditingController()..addListener(() {
      setState(() {
        emailNullCheck = emailTextController.text.trim().isNotEmpty ? true : false;
      });
    });

    emailFocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();

    emailTextController.dispose();
    emailFocusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (emailFocusNode.hasFocus) {
          emailFocusNode.unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: ig-publicAppBar(
          leading: ig-publicAppBarLeading(
            press: () => Navigator.pop(context),
          ),
          title: const ig-publicAppBarTitle(
            title: TextConstant.findPassword,
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
                    text: TextConstant.findPasswordContentTitle,
                    fontColor: ColorConfig().dark(),
                    fontSize: 18.0.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  margin: const EdgeInsets.only(top: 20.0),
                  child: CustomTextBuilder(
                    text: TextConstant.findPasswordContentDescription,
                    fontColor: ColorConfig().gray5(),
                    fontSize: 14.0.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 84.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: TextFormField(
                    controller: emailTextController,
                    focusNode: emailFocusNode,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.5),
                      hintText: TextConstant.emailID,
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
                      suffixIcon: emailNullCheck ? InkWell(
                        onTap: () {
                          emailTextController.clear();
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
                          text: TextConstant.sendMailToReset,
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