import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/usecase.dart';
import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class CreateBooking extends UseCase<BookingEntity, CreateBookingParams> {
  final BookingRepository repository;
  CreateBooking(this.repository);

  @override
  Future<Either<Failure, BookingEntity>> call(CreateBookingParams p) =>
      repository.createBooking(
        roomId: p.roomId, checkIn: p.checkIn, checkOut: p.checkOut,
        guestCount: p.guestCount, specialRequests: p.specialRequests,
      );
}

class CreateBookingParams extends Equatable {
  final String roomId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guestCount;
  final String? specialRequests;

  const CreateBookingParams({
    required this.roomId, required this.checkIn,
    required this.checkOut, required this.guestCount, this.specialRequests,
  });

  @override
  List<Object?> get props => [roomId, checkIn, checkOut, guestCount];
}

class GetUserBookings extends UseCase<List<BookingEntity>, String> {
  final BookingRepository repository;
  GetUserBookings(this.repository);

  @override
  Future<Either<Failure, List<BookingEntity>>> call(String userId) =>
      repository.getUserBookings(userId);
}

class GetBookingById extends UseCase<BookingEntity, String> {
  final BookingRepository repository;
  GetBookingById(this.repository);

  @override
  Future<Either<Failure, BookingEntity>> call(String id) => repository.getBookingById(id);
}

class CancelBooking extends UseCase<void, String> {
  final BookingRepository repository;
  CancelBooking(this.repository);

  @override
  Future<Either<Failure, void>> call(String bookingId) => repository.cancelBooking(bookingId);
}
