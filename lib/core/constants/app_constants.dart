class AppConstants {
  AppConstants._();

  static const String appName = 'Hamro Aawash Grihaa';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String roomsCollection = 'rooms';
  static const String roomTypesCollection = 'room_types';
  static const String bookingsCollection = 'bookings';
  static const String paymentsCollection = 'payments';
  static const String foodCategoriesCollection = 'food_categories';
  static const String foodItemsCollection = 'food_items';
  static const String ordersCollection = 'orders';
  static const String orderItemsCollection = 'order_items';
  static const String favoritesCollection = 'favorites';
  static const String reviewsCollection = 'reviews';
  static const String notificationsCollection = 'notifications';
  static const String supportTicketsCollection = 'support_tickets';
  static const String roomServiceCollection = 'room_service_requests';
  static const String promotionsCollection = 'promotions';
  static const String settingsCollection = 'settings';

  // Hive Boxes
  static const String themeBox = 'theme_box';
  static const String userBox = 'user_box';
  static const String cacheBox = 'cache_box';
  static const String sessionBox = 'session_box';

  // SharedPreferences Keys
  static const String themeKey = 'app_theme';
  static const String onboardingKey = 'onboarding_done';
  static const String languageKey = 'app_language';

  // Pagination
  static const int pageSize = 10;

  // eSewa
  static const String esewaProductionUrl = 'https://esewa.com.np/epay/main';
  static const String esewaTestUrl = 'https://uat.esewa.com.np/epay/main';
  static const String esewaMerchantId = 'EPAYTEST';

  // Image Placeholders
  static const String hotelPlaceholder =
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800';
  static const String roomPlaceholder =
      'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800';
  static const String foodPlaceholder =
      'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800';
  static const String avatarPlaceholder =
      'https://ui-avatars.com/api/?name=User&background=random';
}
