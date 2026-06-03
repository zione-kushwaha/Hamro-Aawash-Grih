import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/network_info.dart';
import '../theme/theme_cubit.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/rooms/data/datasources/room_remote_datasource.dart';
import '../../features/rooms/data/repositories/room_repository_impl.dart';
import '../../features/rooms/domain/repositories/room_repository.dart';
import '../../features/rooms/domain/usecases/room_usecases.dart';
import '../../features/rooms/presentation/bloc/room_bloc.dart';
import '../../features/booking/data/datasources/booking_remote_datasource.dart';
import '../../features/booking/data/repositories/booking_repository_impl.dart';
import '../../features/booking/domain/repositories/booking_repository.dart';
import '../../features/booking/domain/usecases/booking_usecases.dart';
import '../../features/booking/presentation/bloc/booking_bloc.dart';
import '../../features/payment/data/repositories/esewa_payment_repository.dart';
import '../../features/payment/domain/repositories/payment_repository.dart';
import '../../features/payment/domain/usecases/payment_usecases.dart';
import '../../features/payment/presentation/bloc/payment_bloc.dart';
import '../../features/food/presentation/bloc/food_bloc.dart';
import '../../features/room_service/presentation/pages/room_service_page.dart';
import '../../features/profile/presentation/pages/profile_and_support_pages.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  // External
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  sl.registerSingleton<GoogleSignIn>(GoogleSignIn.instance);
  sl.registerSingleton<Connectivity>(Connectivity());

  // Core
  sl.registerSingleton<NetworkInfo>(NetworkInfoImpl(sl()));
  sl.registerSingleton<ThemeCubit>(ThemeCubit(sl()));

  // Auth
  sl.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(auth: sl(), firestore: sl(), googleSignIn: sl()),
  );
  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerSingleton(SignInWithEmail(sl()));
  sl.registerSingleton(SignInWithGoogle(sl()));
  sl.registerSingleton(Register(sl()));
  sl.registerSingleton(SignOut(sl()));
  sl.registerSingleton(SendPasswordResetEmail(sl()));
  sl.registerSingleton(SendEmailVerification(sl()));
  sl.registerFactory(() => AuthBloc(
    signInWithEmail: sl(), signInWithGoogle: sl(), register: sl(),
    signOut: sl(), sendPasswordResetEmail: sl(), sendEmailVerification: sl(),
    authStateChanges: sl<AuthRepository>().authStateChanges,
  ));

  // Rooms
  sl.registerSingleton<RoomRemoteDataSource>(RoomRemoteDataSourceImpl(sl()));
  sl.registerSingleton<RoomRepository>(
    RoomRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerSingleton(GetRooms(sl()));
  sl.registerSingleton(GetRoomById(sl()));
  sl.registerSingleton(GetFeaturedRooms(sl()));
  sl.registerSingleton(CheckRoomAvailability(sl()));
  sl.registerFactory(() => RoomBloc(
    getRooms: sl(), getRoomById: sl(),
    getFeaturedRooms: sl(), checkRoomAvailability: sl(),
  ));

  // Booking
  sl.registerSingleton<BookingRemoteDataSource>(
    BookingRemoteDataSourceImpl(sl(), sl()),
  );
  sl.registerSingleton<BookingRepository>(
    BookingRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerSingleton(CreateBooking(sl()));
  sl.registerSingleton(GetUserBookings(sl()));
  sl.registerSingleton(GetBookingById(sl()));
  sl.registerSingleton(CancelBooking(sl()));
  sl.registerFactory(() => BookingBloc(
    createBooking: sl(), getUserBookings: sl(),
    getBookingById: sl(), cancelBooking: sl(),
  ));

  // Payment (eSewa)
  sl.registerSingleton<PaymentRepository>(EsewaPaymentRepository(sl(), sl()));
  sl.registerSingleton(InitiatePayment(sl()));
  sl.registerSingleton(VerifyPayment(sl()));
  sl.registerSingleton(GetUserPayments(sl()));
  sl.registerFactory(() => PaymentBloc(
    initiatePayment: sl(), verifyPayment: sl(), getUserPayments: sl(),
  ));

  // Food
  sl.registerFactory(() => FoodBloc(sl()));

  // Room Service
  sl.registerFactory(() => RoomServiceBloc(sl(), sl()));

  // Notifications
  sl.registerFactory(() => NotificationBloc(sl()));

  // Support
  sl.registerFactory(() => SupportBloc(sl(), sl()));
}
