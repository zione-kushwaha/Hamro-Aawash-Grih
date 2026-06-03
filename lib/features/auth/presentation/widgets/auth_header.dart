import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hamro Aawash Grihaa',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 8.h),
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          SizedBox(height: 8.h),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey600)),
        ],
      );
}
