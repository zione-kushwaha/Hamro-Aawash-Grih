import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id, required super.userId, required super.roomId,
    required super.roomNumber, required super.roomTypeName, required super.roomImageUrl,
    required super.checkIn, required super.checkOut, required super.guestCount,
    required super.totalAmount, required super.status, required super.createdAt,
    super.paymentId, super.specialRequests,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      userId: d['user_id'] ?? '',
      roomId: d['room_id'] ?? '',
      roomNumber: d['room_number'] ?? '',
      roomTypeName: d['room_type_name'] ?? '',
      roomImageUrl: d['room_image_url'] ?? '',
      checkIn: (d['check_in'] as Timestamp).toDate(),
      checkOut: (d['check_out'] as Timestamp).toDate(),
      guestCount: d['guest_count'] ?? 1,
      totalAmount: (d['total_amount'] ?? 0).toDouble(),
      status: BookingStatus.values.firstWhere(
        (s) => s.name == (d['status'] ?? 'pending'),
        orElse: () => BookingStatus.pending,
      ),
      createdAt: (d['created_at'] as Timestamp).toDate(),
      paymentId: d['payment_id'],
      specialRequests: d['special_requests'],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'user_id': userId, 'room_id': roomId, 'room_number': roomNumber,
        'room_type_name': roomTypeName, 'room_image_url': roomImageUrl,
        'check_in': Timestamp.fromDate(checkIn), 'check_out': Timestamp.fromDate(checkOut),
        'guest_count': guestCount, 'total_amount': totalAmount,
        'status': status.name, 'created_at': Timestamp.fromDate(createdAt),
        'payment_id': paymentId, 'special_requests': specialRequests,
      };
}
