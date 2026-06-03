import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../di/injection.dart';
import 'app_routes.dart';

GoRouter createRouter(BuildContext context) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) {
      final authState = sl<AuthBloc>().state;
      final isAuth = authState is Authenticated;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.forgotPassword;

      if (!isAuth && !isAuthRoute) {
        final protectedRoutes = [
          AppRoutes.booking,
          AppRoutes.payment,
          AppRoutes.profile,
          AppRoutes.bookingHistory,
          AppRoutes.foodCart,
          AppRoutes.roomService,
        ];
        if (protectedRoutes.any((r) => state.matchedLocation.startsWith(r.split(':')[0]))) {
          return AppRoutes.login;
        }
      }
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginPage()),
      GoRoute(path: AppRoutes.register, builder: (_, __) => const RegisterPage()),
      GoRoute(path: AppRoutes.forgotPassword, builder: (_, __) => const ForgotPasswordPage()),
      GoRoute(path: AppRoutes.home, builder: (_, __) => const HomePage()),
      GoRoute(
        path: AppRoutes.roomList,
        builder: (_, __) => const Scaffold(body: Center(child: Text('Rooms - Coming Soon'))),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (_, __) => const Scaffold(body: Center(child: Text('Profile - Coming Soon'))),
      ),
      GoRoute(
        path: AppRoutes.bookingHistory,
        builder: (_, __) => const Scaffold(body: Center(child: Text('Bookings - Coming Soon'))),
      ),
      GoRoute(
        path: AppRoutes.foodMenu,
        builder: (_, __) => const Scaffold(body: Center(child: Text('Food - Coming Soon'))),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('Notifications - Coming Soon'))),
      ),
    ],
    errorBuilder: (_, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
}
