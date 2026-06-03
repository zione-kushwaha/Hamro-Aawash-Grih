class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  static const String home = '/home';
  static const String roomList = '/rooms';
  static const String roomDetail = '/rooms/:id';
  static const String booking = '/booking/:roomId';
  static const String bookingConfirmation = '/booking/confirmation/:bookingId';
  static const String bookingHistory = '/booking/history';
  static const String bookingDetail = '/booking/detail/:bookingId';

  static const String payment = '/payment/:bookingId';
  static const String paymentSuccess = '/payment/success';
  static const String paymentHistory = '/payment/history';

  static const String foodMenu = '/food';
  static const String foodCart = '/food/cart';
  static const String foodOrders = '/food/orders';

  static const String roomService = '/room-service';
  static const String roomServiceHistory = '/room-service/history';

  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';
  static const String settings = '/profile/settings';

  static const String notifications = '/notifications';
  static const String favorites = '/favorites';
  static const String reviews = '/reviews';
  static const String support = '/support';
  static const String supportTicket = '/support/ticket/:ticketId';

  static const String adminDashboard = '/admin';
}
