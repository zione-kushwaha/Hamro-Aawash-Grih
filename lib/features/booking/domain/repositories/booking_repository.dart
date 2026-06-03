import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/booking_entity.dart';

abstract class BookingRepository {
  Future<Either<Failure, BookingEntity>> createBooking({
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guestCount,
    String? specialRequests,
  });
  Future<Either<Failure, List<BookingEntity>>> getUserBookings(String userId);
  Future<Either<Failure, BookingEntity>> getBookingById(String id);
  Future<Either<Failure, void>> cancelBooking(String bookingId);
  Future<Either<Failure, void>> updateBookingStatus(String bookingId, BookingStatus status);
}
