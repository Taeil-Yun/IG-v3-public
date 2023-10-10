import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ig-public_v3/costant/colors.dart';
import 'package:ig-public_v3/costant/text.dart';
import 'package:ig-public_v3/widget/custom_text_widget.dart';

class SignupORFindPassword extends StatelessWidget {
  const SignupORFindPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(40.0, 14.0, 40.0, 32.0),
      padding: const EdgeInsets.symmetric(horizontal: 34.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(ColorConfig.transparent),
              foregroundColor:
                  MaterialStateProperty.all(ColorConfig.transparent),
              padding: MaterialStateProperty.all(const EdgeInsets.all(8.0)),
            ),
            onPressed: () {
              Navigator.pushNamed(context, 'signup');
            },
            child: CustomTextBuilder(
              text: TextConstant.goToSignup,
              fontColor: ColorConfig().gray3(),
              fontSize: 14.0.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 16.0),
          TextButton(
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(ColorConfig.transparent),
              foregroundColor:
                  MaterialStateProperty.all(ColorConfig.transparent),
              padding: MaterialStateProperty.all(const EdgeInsets.all(8.0)),
            ),
            onPressed: () {
              Navigator.pushNamed(context, 'find_password');
            },
            child: CustomTextBuilder(
              text: TextConstant.findPassword,
              fontColor: ColorConfig().gray3(),
              fontSize: 14.0.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
