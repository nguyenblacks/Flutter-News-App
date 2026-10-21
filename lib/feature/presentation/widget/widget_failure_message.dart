import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WidgetFailureMessage extends StatelessWidget {
  final String errorTitle;
  final String errorSubtitle;

  const WidgetFailureMessage({
    super.key,
    this.errorTitle = 'You seem to be offline',
    this.errorSubtitle = 'Check your wi-fi connection or cellular data \nand try again.',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SvgPicture.asset(
          'assets/svg/undraw_newspaper.svg',
          width: 1.sw / 3,
          height: 1.sw / 3,
        ),
        SizedBox(height: 24.h),
        Text(
          errorTitle,
          style: TextStyle(
            fontSize: 48.sp,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          errorSubtitle,
          style: TextStyle(
            fontSize: 36.sp,
          ),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
