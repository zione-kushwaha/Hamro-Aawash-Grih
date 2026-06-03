import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/usecases/booking_usecases.dart';

// Events
abstract class BookingEvent extends Equatable {
  const BookingEvent();
  @override
  List<Object?> get props => [];
}

class CreateBookingRequested extends BookingEvent {
  final String roomId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guestCount;
  final String? specialRequests;
  const CreateBookingRequested({
    required this.roomId, required this.checkIn, required this.checkOut,
    required this.guestCount, this.specialRequests,
  });
  @override
  List<Object?> get props => [roomId, checkIn, checkOut, guestCount];
}

class LoadUserBookings extends BookingEvent {
  final String userId;
  const LoadUserBookings(this.userId);
  @override
  List<Object> get props => [userId];
}

class LoadBookingById extends BookingEvent {
  final String id;
  const LoadBookingById(this.id);
  @override
  List<Object> get props => [id];
}

class CancelBookingRequested extends BookingEvent {
  final String bookingId;
  const CancelBookingRequested(this.bookingId);
  @override
  List<Object> get props => [bookingId];
}

// States
abstract class BookingState extends Equatable {
  const BookingState();
  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}
class BookingLoading extends BookingState {}

class BookingCreated extends BookingState {
  final BookingEntity booking;
  const BookingCreated(this.booking);
  @override
  List<Object> get props => [booking];
}

class BookingsLoaded extends BookingState {
  final List<BookingEntity> bookings;
  const BookingsLoaded(this.bookings);
  @override
  List<Object> get props => [bookings];
}

class BookingDetailLoaded extends BookingState {
  final BookingEntity booking;
  const BookingDetailLoaded(this.booking);
  @override
  List<Object> get props => [booking];
}

class BookingCancelled extends BookingState {}

class BookingError extends BookingState {
  final String message;
  const BookingError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final CreateBooking createBooking;
  final GetUserBookings getUserBookings;
  final GetBookingById getBookingById;
  final CancelBooking cancelBooking;

  BookingBloc({
    required this.createBooking, required this.getUserBookings,
    required this.getBookingById, required this.cancelBooking,
  }) : super(BookingInitial()) {
    on<CreateBookingRequested>(_onCreate);
    on<LoadUserBookings>(_onLoadUserBookings);
    on<LoadBookingById>(_onLoadById);
    on<CancelBookingRequested>(_onCancel);
  }

  Future<void> _onCreate(CreateBookingRequested e, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    final result = await createBooking(CreateBookingParams(
      roomId: e.roomId, checkIn: e.checkIn, checkOut: e.checkOut,
      guestCount: e.guestCount, specialRequests: e.specialRequests,
    ));
    result.fold((f) => emit(BookingError(f.message)), (b) => emit(BookingCreated(b)));
  }

  Future<void> _onLoadUserBookings(LoadUserBookings e, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    final result = await getUserBookings(e.userId);
    result.fold((f) => emit(BookingError(f.message)), (b) => emit(BookingsLoaded(b)));
  }

  Future<void> _onLoadById(LoadBookingById e, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    final result = await getBookingById(e.id);
    result.fold((f) => emit(BookingError(f.message)), (b) => emit(BookingDetailLoaded(b)));
  }

  Future<void> _onCancel(CancelBookingRequested e, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    final result = await cancelBooking(e.bookingId);
    result.fold((f) => emit(BookingError(f.message)), (_) => emit(BookingCancelled()));
  }
}
