import 'package:equatable/equatable.dart';

enum BookingStatus { pending, confirmed, checkedIn, checkedOut, cancelled }

class BookingEntity extends Equatable {
  final String id;
  final String userId;
  final String roomId;
  final String roomNumber;
  final String roomTypeName;
  final String roomImageUrl;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guestCount;
  final double totalAmount;
  final BookingStatus status;
  final DateTime createdAt;
  final String? paymentId;
  final String? specialRequests;

  const BookingEntity({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.roomNumber,
    required this.roomTypeName,
    required this.roomImageUrl,
    required this.checkIn,
    required this.checkOut,
    required this.guestCount,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    this.paymentId,
    this.specialRequests,
  });

  int get nights => checkOut.difference(checkIn).inDays;

  @override
  List<Object?> get props => [id, userId, roomId, status];
}
