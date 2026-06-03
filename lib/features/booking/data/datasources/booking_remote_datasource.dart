import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/booking_entity.dart';
import '../models/booking_model.dart';

abstract class BookingRemoteDataSource {
  Future<BookingModel> createBooking({
    required String roomId, required DateTime checkIn,
    required DateTime checkOut, required int guestCount, String? specialRequests,
  });
  Future<List<BookingModel>> getUserBookings(String userId);
  Future<BookingModel> getBookingById(String id);
  Future<void> cancelBooking(String bookingId);
  Future<void> updateBookingStatus(String bookingId, BookingStatus status);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  BookingRemoteDataSourceImpl(this._firestore, this._auth);

  @override
  Future<BookingModel> createBooking({
    required String roomId, required DateTime checkIn,
    required DateTime checkOut, required int guestCount, String? specialRequests,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException('Not authenticated');

    try {
      return await _firestore.runTransaction<BookingModel>((txn) async {
        final roomDoc = await txn.get(_firestore.collection(AppConstants.roomsCollection).doc(roomId));
        if (!roomDoc.exists) throw const NotFoundException('Room not found');

        final roomData = roomDoc.data()!;
        if (!(roomData['is_available'] ?? true)) throw const ServerException('Room is not available');

        // Check for overlapping bookings
        final overlapping = await _firestore
            .collection(AppConstants.bookingsCollection)
            .where('room_id', isEqualTo: roomId)
            .where('status', whereIn: ['confirmed', 'checkedIn'])
            .get();

        for (final doc in overlapping.docs) {
          final d = doc.data();
          final bookedIn = (d['check_in'] as Timestamp).toDate();
          final bookedOut = (d['check_out'] as Timestamp).toDate();
          if (checkIn.isBefore(bookedOut) && checkOut.isAfter(bookedIn)) {
            throw const ServerException('Room is already booked for these dates');
          }
        }

        final nights = checkOut.difference(checkIn).inDays;
        final pricePerNight = (roomData['price_per_night'] ?? 0).toDouble();
        final totalAmount = nights * pricePerNight;
        final bookingId = const Uuid().v4();

        final booking = BookingModel(
          id: bookingId,
          userId: user.uid,
          roomId: roomId,
          roomNumber: roomData['room_number'] ?? '',
          roomTypeName: roomData['type_name'] ?? '',
          roomImageUrl: (roomData['image_urls'] as List?)?.isNotEmpty == true
              ? roomData['image_urls'][0]
              : AppConstants.roomPlaceholder,
          checkIn: checkIn,
          checkOut: checkOut,
          guestCount: guestCount,
          totalAmount: totalAmount,
          status: BookingStatus.pending,
          createdAt: DateTime.now(),
          specialRequests: specialRequests,
        );

        txn.set(
          _firestore.collection(AppConstants.bookingsCollection).doc(bookingId),
          booking.toFirestore(),
        );

        return booking;
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Booking failed');
    }
  }

  @override
  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.bookingsCollection)
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .get();
      return snapshot.docs.map(BookingModel.fromFirestore).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<BookingModel> getBookingById(String id) async {
    final doc = await _firestore.collection(AppConstants.bookingsCollection).doc(id).get();
    if (!doc.exists) throw const NotFoundException('Booking not found');
    return BookingModel.fromFirestore(doc);
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await _firestore.collection(AppConstants.bookingsCollection).doc(bookingId).update({
      'status': BookingStatus.cancelled.name,
    });
  }

  @override
  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    await _firestore.collection(AppConstants.bookingsCollection).doc(bookingId).update({
      'status': status.name,
    });
  }
}
