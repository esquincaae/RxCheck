import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppColors {
  static const background = Color(0xFFF1F4F8);
  static const primary = Colors.blue;
  static const success = Colors.green;
  static const error = Colors.red;
  static const white = Colors.white;
  static const grey = Colors.grey;
}

class AppTextStyles {
  static final logo = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
  );

  static final error = TextStyle(
    color: AppColors.error,
    fontSize: 14.sp,
  );

  static final defaultText = TextStyle(
    fontSize: 14.sp,
    color: AppColors.grey,
  );

  static final linkText = TextStyle(
    fontSize: 14.sp,
    color: AppColors.primary,
    fontWeight: FontWeight.w500,
  );
}

class AppDecorations {
  static final card = BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(20.r),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 4.r,
        offset: Offset(0, 2.h),
      ),
    ],
  );
}
