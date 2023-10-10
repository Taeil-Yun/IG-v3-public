import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoadingProgressBuilder extends StatelessWidget {
  const LoadingProgressBuilder({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFf1f1f1),
      child: Center(
        child: Image(
          image: const AssetImage('assets/img/loading-progress.gif'),
          width: 100.0.w,
        ),
      ),
    );
  }
}