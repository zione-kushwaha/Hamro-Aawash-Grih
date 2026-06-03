import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) => SizedBox(
        width: double.infinity,
        height: 52.h,
        child: OutlinedButton(
          onPressed: state is AuthLoading
              ? null
              : () => context.read<AuthBloc>().add(SignInWithGoogleRequested()),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'https://www.google.com/favicon.ico',
                height: 20.h,
                width: 20.w,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.g_mobiledata, size: 24.w, color: AppColors.primary),
              ),
              SizedBox(width: 12.w),
              const Text('Continue with Google'),
            ],
          ),
        ),
      ),
    );
  }
}
